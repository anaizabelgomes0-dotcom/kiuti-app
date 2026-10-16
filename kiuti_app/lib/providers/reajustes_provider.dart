import 'package:flutter/foundation.dart';
import 'package:kiuti_app/models/produto.dart';
import 'package:kiuti_app/services/api_exception.dart';
import 'package:kiuti_app/services/reajuste_service.dart';

/// Os produtos abaixo da meta (RN06) e o "Marcar como atualizado na Shopee" (RN08).
class ReajustesProvider extends ChangeNotifier {
  ReajustesProvider(this._service);

  final ReajusteService _service;

  List<Produto> _produtos = [];
  List<Produto> get produtos => _produtos;

  final Set<int> _marcando = {}; // ids com o botão carregando
  bool marcando(Produto produto) => _marcando.contains(produto.idProduto);

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

  /// Grava o preço sugerido como preço atual e tira o produto da lista, sem recarregar.
  Future<void> marcarAtualizado(Produto produto) async {
    _marcando.add(produto.idProduto);
    notifyListeners();
    try {
      await _service.marcarAtualizado(produto.idProduto);
      _produtos = _produtos.where((p) => p.idProduto != produto.idProduto).toList();
    } finally {
      _marcando.remove(produto.idProduto);
      notifyListeners();
    }
  }
}
