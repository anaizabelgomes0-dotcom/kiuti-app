import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kiuti_app/models/configuracao.dart';
import 'package:kiuti_app/models/produto.dart';
import 'package:kiuti_app/providers/configuracao_provider.dart';
import 'package:kiuti_app/providers/ficha_provider.dart';
import 'package:kiuti_app/services/api_exception.dart';
import 'package:kiuti_app/theme/cores.dart';
import 'package:kiuti_app/ui/widgets/botoes.dart';
import 'package:kiuti_app/ui/widgets/campo.dart';
import 'package:kiuti_app/ui/widgets/cartao_rosa.dart';
import 'package:kiuti_app/ui/widgets/confirmacao.dart';
import 'package:kiuti_app/ui/widgets/formatos.dart';
import 'package:provider/provider.dart';

/// Nome, SKU, preço atual e os custos próprios do produto aberto na ficha (RN02, RN09).
class DadosProdutoScreen extends StatefulWidget {
  const DadosProdutoScreen({super.key});

  @override
  State<DadosProdutoScreen> createState() => _DadosProdutoScreenState();
}

class _DadosProdutoScreenState extends State<DadosProdutoScreen> {
  // Campo próprio do produto -> chave do padrão nas Configurações.
  static const _padraoDe = {
    'custo_embalagem': 'embalagem_padrao',
    'custo_envio': 'envio_padrao',
    'custo_brinde': 'brinde_padrao',
    'despesas_variaveis': 'despesas_variaveis_padrao',
  };

  late final Produto _produto; // o produto aberto na ficha (esta tela só abre a partir dela)
  late final _nome = TextEditingController(text: _produto.nome);
  late final _sku = TextEditingController(text: _produto.skuReferencia ?? '');
  late final _preco = TextEditingController(text: formatarValor(_produto.precoAtualShopee));
  late final Map<String, TextEditingController> _custos = {
    for (final campo in _padraoDe.keys)
      campo: TextEditingController(text: _textoDoCusto(_produto.dadosEditaveis()[campo] as double?)),
  };
  Map<String, String> _erros = {};
  bool _salvando = false;

  static String _textoDoCusto(double? valor) => valor == null ? '' : formatarValor(valor);

  @override
  void initState() {
    super.initState();
    _produto = context.read<FichaProvider>().produto!;
    // Os padrões vêm das Configurações. Depois do primeiro desenho: chamar o provider durante o build dá erro.
    WidgetsBinding.instance.addPostFrameCallback((_) => _carregarPadroes());
  }

  @override
  void dispose() {
    _nome.dispose();
    _sku.dispose();
    _preco.dispose();
    for (final campo in _custos.values) {
      campo.dispose();
    }
    super.dispose();
  }

  Future<void> _carregarPadroes() async {
    final configuracao = context.read<ConfiguracaoProvider>();
    await configuracao.carregar();
    if (configuracao.erro != null && mounted) avisar(context, configuracao.erro!);
  }

  double _padrao(Configuracao? config, String campo) => config?.valores[_padraoDe[campo]] ?? 0;

  /// Prévia: custo dos insumos + cada custo (o digitado ou o padrão). O valor oficial vem da API ao salvar.
  double? _novoCustoTotal(Configuracao? config) {
    if (config == null) return null;
    var total = _produto.custoInsumos;
    for (final campo in _custos.keys) {
      final texto = _custos[campo]!.text.trim();
      final valor = texto.isEmpty ? _padrao(config, campo) : lerNumero(texto);
      if (valor == null) return null;
      total += valor;
    }
    return total;
  }

  Future<void> _salvar() async {
    final erros = <String, String>{};
    final preco = lerNumero(_preco.text);
    if (_nome.text.trim().isEmpty) erros['nome'] = 'Informe o nome.';
    if (preco == null || preco < 0) erros['preco_atual_shopee'] = 'Informe um preço válido.';
    final custos = <String, double?>{};
    for (final campo in _custos.keys) {
      final texto = _custos[campo]!.text.trim();
      final valor = texto.isEmpty ? null : lerNumero(texto); // em branco = padrão (null)
      if (texto.isNotEmpty && (valor == null || valor < 0)) erros[campo] = 'Valor inválido.';
      custos[campo] = valor;
    }
    setState(() => _erros = erros);
    if (erros.isNotEmpty) return;

    setState(() => _salvando = true);
    try {
      final sku = _sku.text.trim();
      // A ficha se redesenha com o produto que a API devolver.
      await context.read<FichaProvider>().atualizarProduto({
        ..._produto.dadosEditaveis(), // mantém a margem como está
        'nome': _nome.text.trim(),
        'sku_referencia': sku.isEmpty ? null : sku,
        'preco_atual_shopee': preco,
        ...custos,
      });
      if (!mounted) return;
      context.pop();
    } on ApiException catch (e) {
      if (!mounted) return;
      if (e.campo != null) {
        setState(() => _erros = {e.campo!: e.mensagem});
      } else {
        avisar(context, e.mensagem);
      }
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  Widget _campoCusto(Configuracao? config, String campo, String rotulo) {
    final padrao = formatarValor(_padrao(config, campo));
    final vazio = _custos[campo]!.text.trim().isEmpty;
    return Campo(
      controller: _custos[campo]!,
      rotulo: rotulo,
      numero: true,
      dica: '$padrao · padrão',
      ajuda: vazio ? null : 'Padrão: $padrao',
      erro: _erros[campo],
      aoMudar: (_) => setState(() {}),
    );
  }

  Widget _dupla(Widget esquerda, Widget direita) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [Expanded(child: esquerda), const SizedBox(width: 12), Expanded(child: direita)],
      );

  @override
  Widget build(BuildContext context) {
    final config = context.watch<ConfiguracaoProvider>().config; // redesenha quando os padrões chegam
    final novoTotal = _novoCustoTotal(config);
    return Scaffold(
      appBar: AppBar(title: const Text('Dados do produto')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(_produto.nome, style: const TextStyle(color: Cores.cinza)),
          const SizedBox(height: 12),
          CartaoRosa(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Campo(controller: _nome, rotulo: 'Nome', erro: _erros['nome']),
                const SizedBox(height: 12),
                _dupla(
                  Campo(controller: _sku, rotulo: 'SKU'),
                  Campo(
                    controller: _preco,
                    rotulo: r'Preço atual (R$)',
                    numero: true,
                    erro: _erros['preco_atual_shopee'],
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Mudou o preço direto na Shopee? Corrija aqui.',
                  style: TextStyle(fontSize: 12, color: Cores.cinza),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          CartaoRosa(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const TituloSecao('Custos deste produto'),
                const Text('Em branco, vale o padrão das Configurações.', style: TextStyle(fontSize: 12)),
                const SizedBox(height: 12),
                _dupla(
                  _campoCusto(config, 'custo_embalagem', r'Embalagem (R$)'),
                  _campoCusto(config, 'custo_envio', r'Envio (R$)'),
                ),
                const SizedBox(height: 12),
                _dupla(
                  _campoCusto(config, 'custo_brinde', r'Brinde (R$)'),
                  _campoCusto(config, 'despesas_variaveis', r'Desp. variáveis (R$)'),
                ),
                if (novoTotal != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: Cores.rosa, borderRadius: BorderRadius.circular(14)),
                    child: Row(
                      children: [
                        const Expanded(child: Text('Custo total')),
                        Text('${formatarReais(_produto.custoTotal)} → ${formatarReais(novoTotal)}'),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          BotaoPrincipal(texto: 'Salvar', carregando: _salvando, aoTocar: _salvar),
        ],
      ),
    );
  }
}