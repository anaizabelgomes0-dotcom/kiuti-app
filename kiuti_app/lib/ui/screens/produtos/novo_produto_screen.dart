import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kiuti_app/providers/produtos_provider.dart';
import 'package:kiuti_app/services/api_exception.dart';
import 'package:kiuti_app/ui/widgets/botoes.dart';
import 'package:kiuti_app/ui/widgets/campo.dart';
import 'package:kiuti_app/ui/widgets/cartao_rosa.dart';
import 'package:kiuti_app/ui/widgets/confirmacao.dart';
import 'package:kiuti_app/ui/widgets/formatos.dart';
import 'package:provider/provider.dart';

class NovoProdutoScreen extends StatefulWidget {
  const NovoProdutoScreen({super.key});

  @override
  State<NovoProdutoScreen> createState() => _NovoProdutoScreenState();
}

class _NovoProdutoScreenState extends State<NovoProdutoScreen> {
  final _nome = TextEditingController();
  final _sku = TextEditingController();
  final _preco = TextEditingController();
  Map<String, String> _erros = {};
  bool _salvando = false;

  @override
  void dispose() {
    _nome.dispose();
    _sku.dispose();
    _preco.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    final preco = lerNumero(_preco.text);
    final erros = <String, String>{};
    if (_nome.text.trim().isEmpty) erros['nome'] = 'Informe o nome.';
    if (preco == null) {
      erros['preco_atual_shopee'] = 'Informe o preço.';
    } else if (preco < 0) {
      erros['preco_atual_shopee'] = 'Não pode ser negativo.';
    }
    setState(() => _erros = erros);
    if (erros.isNotEmpty) return;

    setState(() => _salvando = true);
    try {
      final sku = _sku.text.trim();
      final produto = await context.read<ProdutosProvider>().criar(
            nome: _nome.text.trim(),
            skuReferencia: sku.isEmpty ? null : sku,
            precoAtualShopee: preco!,
          );
      if (!mounted) return;
      // Fecha devolvendo o id: a lista de produtos abre a ficha do produto novo.
      context.pop(produto.idProduto);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Novo produto')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          CartaoRosa(
            child: Column(
              children: [
                Campo(controller: _nome, rotulo: 'Nome', erro: _erros['nome']),
                const SizedBox(height: 12),
                Campo(
                  controller: _sku,
                  rotulo: 'SKU de referência (opcional)',
                  ajuda: 'O mesmo SKU que você usa na Shopee.',
                  erro: _erros['sku_referencia'],
                ),
                const SizedBox(height: 12),
                Campo(
                  controller: _preco,
                  rotulo: r'Preço atual na Shopee (R$)',
                  numero: true,
                  erro: _erros['preco_atual_shopee'],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          BotaoPrincipal(texto: 'Salvar e montar a ficha', carregando: _salvando, aoTocar: _salvar),
        ],
      ),
    );
  }
}