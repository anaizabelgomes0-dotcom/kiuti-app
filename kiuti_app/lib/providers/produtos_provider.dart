import 'package:flutter/foundation.dart';
import 'package:kiuti_app/models/produto.dart';
import 'package:kiuti_app/services/api_exception.dart';
import 'package:kiuti_app/services/produto_service.dart';

/// A lista de produtos (aba Produtos) e o cadastro de produto novo.
class ProdutosProvider extends ChangeNotifier {
  ProdutosProvider(this._service);

  final ProdutoService _service;

  List<Produto> _produtos = [];
  // Excluídos na tela mas ainda não apagados na API (janela do "Desfazer").
  final Set<int> _pendentesExclusao = {};
  List<Produto> get produtos => [for (final p in _produtos) if (!_pendentesExclusao.contains(p.idProduto)) p];

  /// Some da lista na hora; a API só é chamada em [confirmarExclusao].
  void ocultar(int idProduto) {
    _pendentesExclusao.add(idProduto);
    notifyListeners();
  }

  /// "Desfazer": o produto volta para o mesmo lugar da lista.
  void restaurar(int idProduto) {
    _pendentesExclusao.remove(idProduto);
    notifyListeners();
  }

  /// Apaga de verdade (RN13: leva a ficha junto). Se a API recusar, o produto volta para a lista.
  Future<void> confirmarExclusao(int idProduto) async {
    try {
      await _service.excluir(idProduto);
      _produtos = [for (final p in _produtos) if (p.idProduto != idProduto) p];
    } finally {
      _pendentesExclusao.remove(idProduto);
      notifyListeners();
    }
  }

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
