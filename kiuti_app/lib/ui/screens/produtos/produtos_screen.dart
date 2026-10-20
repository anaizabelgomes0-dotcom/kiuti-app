import 'package:flutter/material.dart';
import 'package:kiuti_app/models/produto.dart';
import 'package:kiuti_app/models/situacao.dart';
import 'package:kiuti_app/providers/produtos_provider.dart';
import 'package:kiuti_app/theme/cores.dart';
import 'package:kiuti_app/theme/tema.dart';
import 'package:kiuti_app/ui/widgets/cabecalho_aba.dart';
import 'package:kiuti_app/ui/widgets/cartao_rosa.dart';
import 'package:kiuti_app/ui/widgets/confirmacao.dart';
import 'package:kiuti_app/ui/widgets/estados.dart';
import 'package:kiuti_app/ui/widgets/formatos.dart';
import 'package:kiuti_app/ui/widgets/selo_situacao.dart';
import 'package:provider/provider.dart';

class ProdutosScreen extends StatefulWidget {
  const ProdutosScreen({super.key});

  @override
  State<ProdutosScreen> createState() => _ProdutosScreenState();
}

class _ProdutosScreenState extends State<ProdutosScreen> {
  @override
  void initState() {
    super.initState();
    // Depois do primeiro desenho: chamar o provider durante o build da tela dá erro.
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<ProdutosProvider>().carregar());
  }

  // Na volta da ficha ou do cadastro, recarrega sempre: o produto pode ter mudado.
  Future<void> _abrirFicha(Produto produto) async {
    avisar(context, 'Em breve (I0-FL-14).');
  }

  /// O cadastro devolve o id do produto novo; aí a ficha dele abre, para a Keila montar.
  Future<void> _novo() async {
    avisar(context, 'Em breve (I0-FL-13).');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _novo,
        backgroundColor: Cores.preto,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
      body: Consumer<ProdutosProvider>(
        builder: (context, provider, child) {
          if (provider.carregando) return const Center(child: CircularProgressIndicator());
          if (provider.erro != null) return ErroComTentar(mensagem: provider.erro!, aoTentar: provider.carregar);

          final produtos = provider.produtos;
          final total = produtos.length;
          return RefreshIndicator(
            onRefresh: provider.carregar,
            child: ListView(
              padding: const EdgeInsets.only(bottom: 96),
              children: [
                CabecalhoAba(
                  titulo: 'Produtos',
                  direita: Text('$total produto${total == 1 ? '' : 's'}', style: const TextStyle(color: Cores.cinza)),
                ),
                if (produtos.isEmpty)
                  EstadoVazio(
                    titulo: 'Nenhum produto ainda',
                    texto: 'Cadastre o primeiro produto e monte a ficha dele.',
                    textoBotao: 'Cadastrar produto',
                    aoTocar: _novo,
                  )
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: CartaoRosa(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          for (final produto in produtos)
                            _LinhaProduto(produto: produto, aoTocar: () => _abrirFicha(produto)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// "Brinco Flor de Resina / R$ 15,45 · lucro R$ 3,89 ........ [Abaixo da meta]"
class _LinhaProduto extends StatelessWidget {
  const _LinhaProduto({required this.produto, required this.aoTocar});

  final Produto produto;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    final preco = formatarReais(produto.precoAtualShopee);
    final detalhe = produto.situacao == Situacao.fichaIncompleta
        ? '$preco · sem ficha'
        : '$preco · lucro ${formatarReais(produto.lucroAtual!)}';
    return ListTile(
      onTap: aoTocar,
      title: Text(produto.nome, style: fredoka(tamanho: 16, peso: FontWeight.w500)),
      subtitle: Text(detalhe),
      trailing: SeloSituacao(produto.situacao),
    );
  }
}