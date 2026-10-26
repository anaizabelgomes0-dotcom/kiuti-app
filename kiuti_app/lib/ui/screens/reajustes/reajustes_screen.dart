import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kiuti_app/models/produto.dart';
import 'package:kiuti_app/providers/reajustes_provider.dart';
import 'package:kiuti_app/services/api_exception.dart';
import 'package:kiuti_app/theme/cores.dart';
import 'package:kiuti_app/theme/tema.dart';
import 'package:kiuti_app/ui/widgets/cabecalho_aba.dart';
import 'package:kiuti_app/ui/widgets/cartao_rosa.dart';
import 'package:kiuti_app/ui/widgets/confirmacao.dart';
import 'package:kiuti_app/ui/widgets/estados.dart';
import 'package:kiuti_app/ui/widgets/formatos.dart';
import 'package:provider/provider.dart';

class ReajustesScreen extends StatefulWidget {
  const ReajustesScreen({super.key});

  @override
  State<ReajustesScreen> createState() => _ReajustesScreenState();
}

class _ReajustesScreenState extends State<ReajustesScreen> {
  @override
  void initState() {
    super.initState();
    // Depois do primeiro desenho: chamar o provider durante o build da tela dá erro.
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<ReajustesProvider>().carregar());
  }

  Future<void> _marcar(Produto produto) async {
    try {
      await context.read<ReajustesProvider>().marcarAtualizado(produto);
      if (!mounted) return;
      avisar(context, '${produto.nome}: preço atual agora é ${formatarReais(produto.precoSugerido!)}.');
    } on ApiException catch (e) {
      if (mounted) avisar(context, e.mensagem);
    }
  }

  Future<void> _abrirFicha(Produto produto) async {
    final reajustes = context.read<ReajustesProvider>();
    await context.push('/produtos/${produto.idProduto}');
    reajustes.carregar();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ReajustesProvider>(
      builder: (context, provider, child) {
        if (provider.carregando) return const Center(child: CircularProgressIndicator());
        if (provider.erro != null) return ErroComTentar(mensagem: provider.erro!, aoTentar: provider.carregar);

        return RefreshIndicator(
          onRefresh: provider.carregar,
          child: ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              const CabecalhoAba(titulo: 'Reajustes'),
              if (provider.produtos.isEmpty)
                EstadoVazio(
                  titulo: 'Tudo na meta!',
                  texto: 'Nenhum produto está abaixo da margem. Quando um insumo subir de preço, '
                      'os produtos afetados aparecem aqui.',
                  textoBotao: 'Atualizar um insumo',
                  aoTocar: () => context.go('/insumos'), // troca para a aba Insumos
                )
              else
                for (final produto in provider.produtos)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                    child: _CartaoReajuste(
                      produto: produto,
                      marcando: provider.marcando(produto),
                      aoMarcar: () => _marcar(produto),
                      aoAbrir: () => _abrirFicha(produto),
                    ),
                  ),
            ],
          ),
        );
      },
    );
  }
}

class _CartaoReajuste extends StatelessWidget {
  const _CartaoReajuste({
    required this.produto,
    required this.marcando,
    required this.aoMarcar,
    required this.aoAbrir,
  });

  final Produto produto;
  final bool marcando;
  final VoidCallback aoMarcar;
  final VoidCallback aoAbrir;

  @override
  Widget build(BuildContext context) {
    const rotulo = TextStyle(fontSize: 12, color: Cores.cinza);
    return CartaoRosa(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(onTap: aoAbrir, child: Text(produto.nome, style: fredoka(tamanho: 18, peso: FontWeight.w500))),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Preço atual', style: rotulo),
                    Text(formatarReais(produto.precoAtualShopee), style: fredoka(tamanho: 17)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Lucro agora / meta', style: rotulo),
                    Text.rich(
                      TextSpan(children: [
                        TextSpan(
                          text: formatarValor(produto.lucroAtual!),
                          style: fredoka(tamanho: 17, cor: Cores.vermelho),
                        ),
                        TextSpan(text: ' / ${formatarValor(produto.lucroMeta!)}', style: fredoka(tamanho: 17)),
                      ]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
            child: Row(
              children: [
                const Expanded(child: Text('Novo preço sugerido')),
                Text(formatarReais(produto.precoSugerido!), style: fredoka(tamanho: 24, cor: Cores.vermelho)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: marcando ? null : aoMarcar,
              style: OutlinedButton.styleFrom(
                foregroundColor: Cores.preto,
                side: const BorderSide(color: Cores.preto),
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              icon: marcando
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.check),
              label: const Text('Marcar como atualizado na Shopee'),
            ),
          ),
        ],
      ),
    );
  }
}