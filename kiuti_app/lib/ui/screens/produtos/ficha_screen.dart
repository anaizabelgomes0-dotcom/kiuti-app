import 'package:flutter/material.dart';
import 'package:kiuti_app/models/item_ficha.dart';
import 'package:kiuti_app/models/configuracao.dart';
import 'package:kiuti_app/models/produto.dart';
import 'package:kiuti_app/providers/configuracao_provider.dart';
import 'package:kiuti_app/providers/ficha_provider.dart';
import 'package:kiuti_app/providers/produtos_provider.dart';
import 'package:kiuti_app/services/api_exception.dart';
import 'package:kiuti_app/theme/cores.dart';
import 'package:kiuti_app/theme/tema.dart';
import 'package:kiuti_app/ui/widgets/animacoes.dart';
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
import 'package:kiuti_app/ui/screens/produtos/adicionar_insumo_sheet.dart';
import 'package:kiuti_app/ui/screens/produtos/editar_item_sheet.dart';

class FichaScreen extends StatefulWidget {
  const FichaScreen({super.key, required this.idProduto});

  final int idProduto;

  @override
  State<FichaScreen> createState() => _FichaScreenState();
}

class _FichaScreenState extends State<FichaScreen> {
  final _margem = TextEditingController();
  final _focoMargem = FocusNode();
  final _lucro = TextEditingController(); // lucro desejado em R$: só espelha a margem, que é o que a API guarda
  final _focoLucro = FocusNode();

  @override
  void initState() {
    super.initState();
    // Depois do primeiro desenho: chamar o provider durante o build da tela dá erro.
    WidgetsBinding.instance.addPostFrameCallback((_) => _carregar());
    // Grava a margem quando o campo perde o foco (a pessoa tocou fora ou fechou o teclado).
    _focoMargem.addListener(() {
      if (!_focoMargem.hasFocus) _salvarMargem();
    });
    _focoLucro.addListener(() {
      if (!_focoLucro.hasFocus) _salvarMargem();
    });
  }

  @override
  void dispose() {
    _margem.dispose();
    _focoMargem.dispose();
    _lucro.dispose();
    _focoLucro.dispose();
    super.dispose();
  }

  Future<void> _carregar() async {
    final ficha = context.read<FichaProvider>();
    context.read<ConfiguracaoProvider>().carregar(); // taxas da Shopee na composição; a ficha não espera por elas
    await ficha.carregar(widget.idProduto);
    final produto = ficha.produto;
    if (mounted && produto != null) _preencherMargem(produto);
  }

  /// Margem e lucro desejado como a API devolveu. Na ficha incompleta não há lucro-meta (RN04).
  void _preencherMargem(Produto produto) {
    _margem.text = formatarNumero(produto.efetivos.percLucro);
    _lucro.text = produto.lucroMeta == null ? '' : formatarValor(produto.lucroMeta!);
  }

  /// Digitou a margem: o lucro acompanha (lucro_meta = custo_total × margem / 100, ADR 001).
  void _margemMudou(String texto) {
    final margem = lerNumero(texto);
    final custo = context.read<FichaProvider>().produto!.custoTotal;
    _lucro.text = margem == null ? '' : formatarValor(custo * margem / 100);
  }

  /// Digitou o lucro: a margem acompanha, em 2 casas como a coluna (DECIMAL(5,2)).
  void _lucroMudou(String texto) {
    final lucro = lerNumero(texto);
    final custo = context.read<FichaProvider>().produto!.custoTotal;
    if (custo <= 0) return; // sem custo não há margem que dê esse lucro
    _margem.text = lucro == null ? '' : formatarNumero((lucro / custo * 100 * 100).round() / 100);
  }

  Future<void> _salvarMargem() async {
    if (!mounted) return; // o campo também perde o foco quando a tela fecha
    final ficha = context.read<FichaProvider>();
    final produto = ficha.produto;
    if (produto == null) return;
    final texto = _margem.text.trim(); // o lucro em R$ já foi convertido para a margem ao digitar
    if (texto == formatarNumero(produto.efetivos.percLucro)) return; // não mudou
    final nova = texto.isEmpty ? null : lerNumero(texto); // em branco = volta ao padrão (RN02)
    if (texto.isNotEmpty && (nova == null || nova < 0)) {
      avisar(context, 'Margem inválida.');
      _preencherMargem(produto);
      return;
    }
    if (nova != null && nova > 999.99) {
      avisar(context, 'Lucro muito alto para este custo: a margem passa de 999,99%.');
      _preencherMargem(produto);
      return;
    }
    try {
      await ficha.atualizarProduto({...produto.dadosEditaveis(), 'perc_lucro': nova});
      if (mounted) _preencherMargem(ficha.produto!);
    } on ApiException catch (e) {
      if (mounted) avisar(context, e.mensagem);
    }
  }

/// Abre uma folha que sobe de baixo. A folha salva pelo FichaProvider, e a ficha se redesenha sozinha.
Future<void> _abrirFolha(Widget folha) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true, // deixa a folha crescer e subir com o teclado
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
      child: folha,
    ),
  );
}

// Insumos e Dados do produto mudam o custo, então o lucro em R$ é preenchido de novo ao voltar.
Future<void> _adicionarInsumo() async {
  await _abrirFolha(const AdicionarInsumoSheet());
  _depoisDeMudarCusto();
}

Future<void> _editarItem(ItemFicha item) async {
  await _abrirFolha(EditarItemSheet(item: item));
  _depoisDeMudarCusto();
}

 Future<void> _abrirDados() async {
  await context.push('/produtos/${widget.idProduto}/dados');
  _depoisDeMudarCusto();
}

void _depoisDeMudarCusto() {
  final produto = mounted ? context.read<FichaProvider>().produto : null;
  if (produto != null) _preencherMargem(produto);
}

 Future<void> _excluir() async {
  final ficha = context.read<FichaProvider>();
  final produto = ficha.produto!;
  final n = ficha.itens.length;
  final confirmou = await confirmarExclusao(
    context,
    titulo: 'Excluir este produto?',
    texto: 'O ${produto.nome} e a ficha dele ($n insumo${n == 1 ? '' : 's'}) serão apagados. '
        'Você ainda poderá desfazer por alguns segundos.',
    textoBotao: 'Excluir produto',
  );
  if (!confirmou || !mounted) return;
  // Pega tudo antes do pop: depois dele esta tela deixa de existir.
  final produtos = context.read<ProdutosProvider>();
  final messenger = ScaffoldMessenger.of(context);
  final id = produto.idProduto;
  produtos.ocultar(id);
  context.pop(); // volta para a lista, que já não mostra o produto
  avisarComDesfazer(
    messenger,
    '${produto.nome} excluído',
    onDesfazer: () => produtos.restaurar(id),
    onConfirmar: () async {
      try {
        await produtos.confirmarExclusao(id);
      } on ApiException catch (e) {
        messenger.showSnackBar(SnackBar(content: Text(e.mensagem)));
      }
    },
  );
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
    final config = context.watch<ConfiguracaoProvider>().config;

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
        if (incompleta) _composicaoVazia(produto) else _composicao(produto, itens, config),

        
        const SizedBox(height: 12),
        CartaoRosa(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('Margem desejada', style: fredoka(tamanho: 16, peso: FontWeight.w500)),
                  const Spacer(),
                  SizedBox(
                    width: 100,
                    child: TextField(
                      controller: _margem,
                      focusNode: _focoMargem,
                      onChanged: _margemMudou,
                      textAlign: TextAlign.right,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(suffixText: '%', isDense: true),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text('Lucro desejado', style: fredoka(tamanho: 16, peso: FontWeight.w500)),
                  const Spacer(),
                  SizedBox(
                    width: 100,
                    child: TextField(
                      controller: _lucro,
                      focusNode: _focoLucro,
                      onChanged: _lucroMudou,
                      enabled: !incompleta, // sem insumos não há lucro-meta (RN04)
                      textAlign: TextAlign.right,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(prefixText: 'R\$ ', hintText: '—', isDense: true),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'O app guarda a margem: se o custo subir, o lucro em reais sobe junto.',
                style: TextStyle(fontSize: 12, color: Cores.cinza),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        if (incompleta) _precoIncompleto() else _preco(produto),
        const SizedBox(height: 24),
        BotaoContorno(texto: 'Excluir', icone: Icons.delete_outline, cor: Cores.vermelho, aoTocar: _excluir),
      ],
    );
  }

  /// Cartão "Composição": itens, custos fixos maiores que zero, o custo total e as taxas da Shopee.
  Widget _composicao(Produto produto, List<ItemFicha> itens, Configuracao? config) {
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
                  ReaisAnimado(produto.custoTotal, estilo: fredoka(tamanho: 17)),
                ],
              ),
              if (config != null) ..._taxasShopee(produto, config),
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

  /// Taxas da Shopee sobre o preço sugerido: custo + lucro + taxas fecha (quase) o preço, que sobe de 10 em 10 centavos.
  List<Widget> _taxasShopee(Produto produto, Configuracao config) {
    final preco = produto.precoSugerido!;
    final taxa = preco * config.percTaxaShopee / 100;
    return [
      const SizedBox(height: 8),
      const Text('Shopee · sobre o preço sugerido', style: TextStyle(fontSize: 12, color: Cores.cinza)),
      _LinhaComposicao(
        nome: 'Taxa Shopee',
        detalhe: '${formatarNumero(config.percTaxaShopee)}% de ${formatarReais(preco)}',
        valor: taxa,
      ),
      _LinhaComposicao(nome: 'Taxa fixa Shopee', detalhe: 'por venda', valor: config.taxaFixaShopee),
      const Divider(color: Cores.preto),
      Row(
        children: [
          Text('Custo + taxas', style: fredoka(tamanho: 17)),
          const Spacer(),
          ReaisAnimado(produto.custoTotal + taxa + config.taxaFixaShopee, estilo: fredoka(tamanho: 17)),
        ],
      ),
    ];
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
              ReaisAnimado(produto.precoSugerido!, estilo: fredoka(tamanho: 30, cor: Cores.rosa)),
            ],
          ),
          
          if (produto.precoSugerido! > 79.99)
            const Text('Acima de R\$ 79,99 a Shopee cobra outra taxa: confira o preço.', style: branco),
          const SizedBox(height: 8),
          Row(
            children: [
              const Expanded(child: Text('Lucro com o preço atual', style: branco)),
              ReaisAnimado(produto.lucroAtual!, estilo: fredoka(tamanho: 18, cor: Colors.white)),
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

/// "Resina epóxi · 8 g × 0,12 ........ 0,96 >". Sem aoTocar (taxas da Shopee), sem a seta.
class _LinhaComposicao extends StatelessWidget {
  const _LinhaComposicao({required this.nome, this.detalhe, required this.valor, this.aoTocar});

  final String nome;
  final String? detalhe;
  final double valor;
  final VoidCallback? aoTocar;

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
            Icon(Icons.chevron_right, size: 20, color: aoTocar == null ? Colors.transparent : null),
          ],
        ),
      ),
    );
  }
}