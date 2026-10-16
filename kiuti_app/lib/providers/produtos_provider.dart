import 'package:flutter/foundation.dart';
import 'package:kiuti_app/models/produto.dart';
import 'package:kiuti_app/services/api_exception.dart';
import 'package:kiuti_app/services/produto_service.dart';

/// A lista de produtos (aba Produtos) e o cadastro de produto novo.
class ProdutosProvider extends ChangeNotifier {
  ProdutosProvider(this._service);

  final ProdutoService _service;

  List<Produto> _produtos = [];
  List<Produto> get produtos => _produtos;

  bool _carregando = true;
  bool get carregando => _carregando;

  String? _erro;
  String? get erro => _erro;

  Future<void> carregar() async {
    _carregando = true;
    _erro = null;
    notifyListeners();
    try {
      _produtos = await _service.listar();
    } on ApiException catch (e) {
      _erro = e.mensagem;
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  /// Cadastra e devolve o produto novo (a tela abre a ficha dele).
  Future<Produto> criar({required String nome, String? skuReferencia, required double precoAtualShopee}) =>
      _service.criar(nome: nome, skuReferencia: skuReferencia, precoAtualShopee: precoAtualShopee);
}
