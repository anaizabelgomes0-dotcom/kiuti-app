import 'package:flutter/material.dart';
import 'package:kiuti_app/models/item_ficha.dart';
import 'package:kiuti_app/models/produto.dart';
import 'package:kiuti_app/providers/ficha_provider.dart';
import 'package:kiuti_app/services/api_exception.dart';
import 'package:kiuti_app/theme/cores.dart';
import 'package:kiuti_app/theme/tema.dart';
import 'package:kiuti_app/ui/widgets/botoes.dart';
import 'package:kiuti_app/ui/widgets/cartao_rosa.dart';
import 'package:kiuti_app/ui/widgets/confirmacao.dart';
import 'package:kiuti_app/ui/widgets/estados.dart';
import 'package:kiuti_app/ui/widgets/formatos.dart';
import 'package:kiuti_app/ui/widgets/selo_situacao.dart';
import 'package:provider/provider.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:kiuti_app/models/situacao.dart';
import 'package:kiuti_app/ui/widgets/logo_kiuti.dart';
import 'package:go_router/go_router.dart';


class FichaScreen extends StatefulWidget {
  const FichaScreen({super.key, required this.idProduto});

  final int idProduto;

  @override
  State<FichaScreen> createState() => _FichaScreenState();
}

class _FichaScreenState extends State<FichaScreen> {
  final _margem = TextEditingController();
  final _focoMargem = FocusNode();

  @override
  void initState() {
    super.initState();
    // Depois do primeiro desenho: chamar o provider durante o build da tela dá erro.
    WidgetsBinding.instance.addPostFrameCallback((_) => _carregar());
    // Grava a margem quando o campo perde o foco (a pessoa tocou fora ou fechou o teclado).
    _focoMargem.addListener(() {
      if (!_focoMargem.hasFocus) _salvarMargem();
    });
  }

  @override
  void dispose() {
    _margem.dispose();
    _focoMargem.dispose();
    super.dispose();
  }

  Future<void> _carregar() async {
    final ficha = context.read<FichaProvider>();
    await ficha.carregar(widget.idProduto);
    final produto = ficha.produto;
    if (mounted && produto != null) _margem.text = formatarNumero(produto.efetivos.percLucro);
  }

  Future<void> _salvarMargem() async {
    if (!mounted) return; // o campo também perde o foco quando a tela fecha
    final ficha = context.read<FichaProvider>();
    final produto = ficha.produto;
    if (produto == null) return;
    final texto = _margem.text.trim();
    if (texto == formatarNumero(produto.efetivos.percLucro)) return; // não mudou
    final nova = texto.isEmpty ? null : lerNumero(texto); // em branco = volta ao padrão (RN02)
    if (texto.isNotEmpty && (nova == null || nova < 0)) {
      avisar(context, 'Margem inválida.');
      _margem.text = formatarNumero(produto.efetivos.percLucro);
      return;
    }
    try {
      await ficha.atualizarProduto({...produto.dadosEditaveis(), 'perc_lucro': nova});
      if (mounted) _margem.text = formatarNumero(ficha.produto!.efetivos.percLucro);
    } on ApiException catch (e) {
      if (mounted) avisar(context, e.mensagem);
    }
  }

  Future<void> _adicionarInsumo() async {
    avisar(context, 'Em breve (I0-FL-16).');
  }

  Future<void> _editarItem(ItemFicha item) async {
    avisar(context, 'Em breve (I0-FL-17).');
  }

 Future<void> _abrirDados() async {
  await context.push('/produtos/${widget.idProduto}/dados');
}

 Future<void> _excluir() async {
  final ficha = context.read<FichaProvider>();
  final produto = ficha.produto!;
  final n = ficha.itens.length;
  final confirmou = await confirmarExclusao(
    context,
    titulo: 'Excluir este produto?',
    texto: 'O ${produto.nome} e a ficha dele ($n insumo${n == 1 ? '' : 's'}) serão apagados. '
        'Não dá para desfazer.',
    textoBotao: 'Excluir produto',
  );
  if (!confirmou || !mounted) return;
  try {
    await ficha.excluirProduto();
    if (!mounted) return;
    context.pop(); // volta para a lista, que recarrega sozinha
  } on ApiException catch (e) {
    if (mounted) avisar(context, e.mensagem);
  }
}
/// Ficha incompleta (RN04): mascote e botão no lugar da composição.
Widget _composicaoVazia(Produto produto) {
  return CartaoRosa(
    child: Column(
      children: [
        const Align(alignment: Alignment.centerLeft, child: TituloSecao('Composição')),
        const Mascote(tamanho: 110, pose: Pose.convite),
        const SizedBox(height: 12),
        Text('Nenhum insumo ainda', style: fredoka(tamanho: 18)),
        const SizedBox(height: 6),
        Text(
          'Adicione o que vai em ${produto.nome} para o app calcular o custo, o preço sugerido e o lucro.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        BotaoPrincipal(texto: 'Adicionar o primeiro insumo', icone: Icons.add, aoTocar: _adicionarInsumo),
      ],
    ),
  );
}
/// Ficha incompleta: preço e lucro "—", contorno tracejado.
Widget _precoIncompleto() {
  return DottedBorder(
    options: const RoundedRectDottedBorderOptions(
      radius: Radius.circular(20),
      dashPattern: [6, 4],
      strokeWidth: 1.5,
      color: Cores.cinza,
      padding: EdgeInsets.all(20),
    ),
    child: const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [Text('Preço sugerido'), Spacer(), Text('—')]),
        SizedBox(height: 8),
        Row(children: [Text('Lucro com o preço atual'), Spacer(), Text('—')]),
        SizedBox(height: 12),
        SeloSituacao(Situacao.fichaIncompleta),
        SizedBox(height: 8),
        Text('Fora dos reajustes por enquanto.', style: TextStyle(fontSize: 12, color: Cores.cinza)),
      ],
    ),
  );
}
  @override
  Widget build(BuildContext context) {
    final ficha = context.watch<FichaProvider>();
    // O provider pode ainda ter a ficha de outro produto (a que foi aberta antes).
    final produto = ficha.produto?.idProduto == widget.idProduto ? ficha.produto : null;
    return Scaffold(
      appBar: AppBar(
        title: Text(produto?.nome ?? ''),
        actions: [
          if (produto != null)
            IconButton(icon: const Icon(Icons.edit_outlined), tooltip: 'Dados do produto', onPressed: _abrirDados),
        ],
      ),
      body: _corpo(ficha, produto),
    );
  }

  Widget _corpo(FichaProvider ficha, Produto? produto) {
    if (ficha.erro != null) return ErroComTentar(mensagem: ficha.erro!, aoTentar: _carregar);
    if (produto == null) return const Center(child: CircularProgressIndicator());
    final itens = ficha.itens;
    final incompleta = itens.isEmpty;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text.rich(
          TextSpan(children: [
            const TextSpan(text: 'Preço atual na Shopee: '),
            TextSpan(
              text: formatarReais(produto.precoAtualShopee),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ]),
        ),
        const SizedBox(height: 12),
        if (incompleta) _composicaoVazia(produto) else _composicao(produto, itens),

        
        const SizedBox(height: 12),
        CartaoRosa(
          child: Row(
            children: [
              Text('Margem desejada', style: fredoka(tamanho: 16, peso: FontWeight.w500)),
              const Spacer(),
              SizedBox(
                width: 100,
                child: TextField(
                  controller: _margem,
                  focusNode: _focoMargem,
                  textAlign: TextAlign.right,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(suffixText: '%', isDense: true),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        if (incompleta) _precoIncompleto() else _preco(produto),
        // a ficha incompleta ganha o seu bloco na I0-FL-15
        const SizedBox(height: 24),
        BotaoContorno(texto: 'Excluir', icone: Icons.delete_outline, cor: Cores.vermelho, aoTocar: _excluir),
      ],
    );
  }

  /// Cartão "Composição": itens, custos fixos maiores que zero e o custo total.
  Widget _composicao(Produto produto, List<ItemFicha> itens) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CartaoRosa(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Expanded(child: TituloSecao('Composição')),
                  BotaoContorno(texto: 'Insumo', icone: Icons.add, aoTocar: _adicionarInsumo),
                ],
              ),
              for (final item in itens)
                _LinhaComposicao(
                  nome: item.nomeInsumo,
                  detalhe: '${formatarNumero(item.qtde)} ${item.unidadeCompra} × '
                      '${formatarNumero(item.custoUnitario)}',
                  valor: item.custoItem,
                  aoTocar: () => _editarItem(item),
                ),
              for (final custo in _custosFixos(produto))
                _LinhaComposicao(
                  nome: custo.nome,
                  detalhe: custo.padrao ? 'padrão' : null,
                  valor: custo.valor,
                  aoTocar: _abrirDados,
                ),
              const Divider(color: Cores.preto),
              Row(
                children: [
                  Text('Custo total', style: fredoka(tamanho: 17)),
                  const Spacer(),
                  Text(formatarReais(produto.custoTotal), style: fredoka(tamanho: 17)),
                ],
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(top: 6, left: 4),
          child: Text(
            'Toque em um insumo para mudar a quantidade ou remover.',
            style: TextStyle(fontSize: 12, color: Cores.cinza),
          ),
        ),
      ],
    );
  }

  /// Embalagem, envio, brinde e despesas: só os maiores que zero, com "padrão" quando o produto não tem valor próprio.
  List<_CustoFixo> _custosFixos(Produto p) {
    final todos = [
      _CustoFixo('Embalagem', p.efetivos.custoEmbalagem, p.custoEmbalagem == null),
      _CustoFixo('Envio', p.efetivos.custoEnvio, p.custoEnvio == null),
      _CustoFixo('Brinde', p.efetivos.custoBrinde, p.custoBrinde == null),
      _CustoFixo('Despesas variáveis', p.efetivos.despesasVariaveis, p.despesasVariaveis == null),
    ];
    return todos.where((custo) => custo.valor > 0).toList();
  }

  /// Bloco preto com preço sugerido, lucro e selo.
  Widget _preco(Produto produto) {
    const branco = TextStyle(color: Colors.white);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Cores.preto, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(child: Text('Preço sugerido', style: branco)),
              Text(formatarReais(produto.precoSugerido!), style: fredoka(tamanho: 30, cor: Cores.rosa)),
            ],
          ),
          // A taxa cadastrada só vale até R$ 79,99 (ADR 001, faixas da Shopee).
          if (produto.precoSugerido! > 79.99)
            const Text('Acima de R\$ 79,99 a Shopee cobra outra taxa: confira o preço.', style: branco),
          const SizedBox(height: 8),
          Row(
            children: [
              const Expanded(child: Text('Lucro com o preço atual', style: branco)),
              Text(formatarReais(produto.lucroAtual!), style: fredoka(tamanho: 18, cor: Colors.white)),
            ],
          ),
          const SizedBox(height: 12),
          SeloSituacao(produto.situacao),
        ],
      ),
    );
  }

}

class _CustoFixo {
  _CustoFixo(this.nome, this.valor, this.padrao);

  final String nome;
  final double valor;
  final bool padrao; // true = veio das Configurações
}

/// "Resina epóxi · 8 g × 0,12 ........ 0,96 >"
class _LinhaComposicao extends StatelessWidget {
  const _LinhaComposicao({required this.nome, this.detalhe, required this.valor, required this.aoTocar});

  final String nome;
  final String? detalhe;
  final double valor;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: aoTocar,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Text.rich(
                TextSpan(children: [
                  TextSpan(text: nome),
                  if (detalhe != null) TextSpan(text: ' · $detalhe', style: const TextStyle(color: Cores.cinza)),
                ]),
              ),
            ),
            Text(formatarValor(valor), style: const TextStyle(fontWeight: FontWeight.w600)),
            const Icon(Icons.chevron_right, size: 20),
          ],
        ),
      ),
    );
  }
}