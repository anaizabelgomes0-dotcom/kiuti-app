import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kiuti_app/models/insumo.dart';
import 'package:kiuti_app/models/produto_uso.dart';
import 'package:kiuti_app/providers/insumos_provider.dart';
import 'package:kiuti_app/services/api_exception.dart';
import 'package:kiuti_app/theme/cores.dart';
import 'package:kiuti_app/theme/tema.dart';
import 'package:kiuti_app/ui/widgets/botoes.dart';
import 'package:kiuti_app/ui/widgets/campo.dart';
import 'package:kiuti_app/ui/widgets/cartao_rosa.dart';
import 'package:kiuti_app/ui/widgets/confirmacao.dart';
import 'package:kiuti_app/ui/widgets/formatos.dart';
import 'package:kiuti_app/ui/widgets/logo_kiuti.dart';
import 'package:provider/provider.dart';

class InsumoFormScreen extends StatefulWidget {
  const InsumoFormScreen({super.key, this.insumo});

  final Insumo? insumo;

  @override
  State<InsumoFormScreen> createState() => _InsumoFormScreenState();
}

class _InsumoFormScreenState extends State<InsumoFormScreen> {
  late final _nome = TextEditingController(text: widget.insumo?.nome ?? '');
  late final _custo = TextEditingController(text: _textoInicial(widget.insumo?.custo, formatarValor));
  late final _qtde = TextEditingController(text: _textoInicial(widget.insumo?.qtdeCompra, formatarNumero));
  late String _unidade = widget.insumo?.unidadeCompra ?? 'g';
  List<ProdutoUso> _usadoEm = [];
  Map<String, String> _erros = {}; 
  bool _salvando = false;

  int? _idExistente;

  bool get _editando => widget.insumo != null;

  static String _textoInicial(double? valor, String Function(double) formatar) =>
      valor == null ? '' : formatar(valor);

  @override
  void initState() {
    super.initState();
    if (_editando) _carregarUso();
  }

  @override
  void dispose() {
    _nome.dispose();
    _custo.dispose();
    _qtde.dispose();
    super.dispose();
  }

  Future<void> _carregarUso() async {
    try {
      final lista = await context.read<InsumosProvider>().produtosQueUsam(widget.insumo!.idInsumo);
      if (mounted) setState(() => _usadoEm = lista);
    } on ApiException {
      
    }
  }

  double? get _custoPorUnidade {
    final custo = lerNumero(_custo.text);
    final qtde = lerNumero(_qtde.text);
    if (custo == null || qtde == null || custo < 0 || qtde <= 0) return null;
    return custo / qtde;
  }

  Map<String, String> _validar() {
    final erros = <String, String>{};
    final custo = lerNumero(_custo.text);
    final qtde = lerNumero(_qtde.text);
    if (_nome.text.trim().isEmpty) erros['nome'] = 'Informe o nome.';
    if (custo == null) {
      erros['custo'] = 'Informe quanto pagou.';
    } else if (custo < 0) {
      erros['custo'] = 'Não pode ser negativo.';
    }
    if (qtde == null) {
      erros['qtde_compra'] = 'Informe a quantidade.';
    } else if (qtde <= 0) {
      erros['qtde_compra'] = 'Precisa ser maior que zero.';
    }
    return erros;
  }

  Future<void> _salvar() async {
  final erros = _validar();
  setState(() {
    _erros = erros;
    _idExistente = null;
  });
  if (erros.isNotEmpty) return;

  setState(() => _salvando = true);
  try {
    await context.read<InsumosProvider>().salvar(
          idInsumo: widget.insumo?.idInsumo,
          nome: _nome.text.trim(),
          custo: lerNumero(_custo.text)!,
          unidadeCompra: _unidade,
          qtdeCompra: lerNumero(_qtde.text)!,
        );
    if (!mounted) return;
    context.pop(true); 
  } on ApiException catch (e) {
    if (!mounted) return;
    if (e.campo != null) {
      setState(() {
        _erros = {e.campo!: e.mensagem}; 
        _idExistente = e.dados['id_insumo_existente'] as int?; 
      });
    } else {
      avisar(context, e.mensagem);
    }
  } finally {
    if (mounted) setState(() => _salvando = false);
  }
}
 Future<void> _abrirExistente() async {
  try {
    final existente = await context.read<InsumosProvider>().obter(_idExistente!);
    if (!mounted) return;
    context.push('/insumos/editar', extra: existente);
  } on ApiException catch (e) {
    if (mounted) avisar(context, e.mensagem);
  }
}

  @override
  Widget build(BuildContext context) {
    final custoPorUnidade = _custoPorUnidade;
    return Scaffold(
      appBar: AppBar(title: Text(_editando ? widget.insumo!.nome : 'Novo insumo')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Cadastre do jeito que você compra.', style: TextStyle(color: Cores.cinza)),
          const SizedBox(height: 12),
          CartaoRosa(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Campo(controller: _nome, rotulo: 'Nome', erro: _erros['nome']),
                const SizedBox(height: 12),
               
                if (_idExistente != null)
              TextButton.icon(
                onPressed: _abrirExistente,
                icon: const Icon(Icons.chevron_right),
                label: const Text('Abrir o insumo que já existe'),
              ),
                 Campo(
                  controller: _custo,
                  rotulo: r'Quanto paguei (R$)',
                  numero: true,
                  erro: _erros['custo'],
                  ajuda: _editando ? 'Antes: ${formatarReais(widget.insumo!.custo)}' : null,
                  aoMudar: (_) => setState(() {}),
                ),
              
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Campo(
                        controller: _qtde,
                        rotulo: 'Por quanto',
                        numero: true,
                        erro: _erros['qtde_compra'],
                        aoMudar: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 110,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Unidade', style: TextStyle(fontSize: 13)),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            initialValue: _unidade,
                            isDense: true,
                            items: [
                              for (final unidade in unidadesDeCompra)
                                DropdownMenuItem(value: unidade, child: Text(unidade)),
                            ],
                            onChanged: (valor) => setState(() => _unidade = valor!),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: Cores.rosa, borderRadius: BorderRadius.circular(14)),
                  child: Row(
                    children: [
                      Text('Custo por ${unidadePorExtenso[_unidade] ?? _unidade}'),
                      const Spacer(),
                      Text(
                        custoPorUnidade == null ? '—' : formatarReaisUnitario(custoPorUnidade),
                        style: fredoka(tamanho: 20),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (_editando && _usadoEm.isNotEmpty)
            CartaoRosa(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TituloSecao('Usado em ${_usadoEm.length} produto${_usadoEm.length == 1 ? '' : 's'}'),
                  for (final produto in _usadoEm)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Expanded(child: Text(produto.nome)),
                          Text('${formatarNumero(produto.qtde)} ${widget.insumo!.unidadeCompra}'),
                        ],
                      ),
                    ),
                ],
              ),
            )
          else if (!_editando)
            const Row(
              children: [
                Mascote(tamanho: 64, pose: Pose.dica),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Quando o preço mudar, é só atualizar aqui. Os produtos que usam este insumo são recalculados.',
                  ),
                ),
              ],
            ),
          const SizedBox(height: 24),
          BotaoPrincipal(texto: 'Salvar insumo', carregando: _salvando, aoTocar: _salvar),
        ],
      ),
    );
  }
}