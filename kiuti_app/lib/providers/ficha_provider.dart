import 'package:flutter/foundation.dart';
import 'package:kiuti_app/models/item_ficha.dart';
import 'package:kiuti_app/models/produto.dart';
import 'package:kiuti_app/services/api_exception.dart';
import 'package:kiuti_app/services/item_service.dart';
import 'package:kiuti_app/services/produto_service.dart';

/// A ficha aberta: o produto, os itens e as ações sobre eles. Os valores (custo, preço, lucro) vêm sempre da API.
class FichaProvider extends ChangeNotifier {
  FichaProvider(this._produtos, this._itens);

  final ProdutoService _produtos;
  final ItemService _itens;

  Produto? _produto;
  Produto? get produto => _produto;

  List<ItemFicha> _itensDaFicha = [];
  List<ItemFicha> get itens => _itensDaFicha;

  bool _carregando = true;
  bool get carregando => _carregando;

  String? _erro;
  String? get erro => _erro;

  Future<void> carregar(int idProduto) async {
    _carregando = true;
    _erro = null;
    notifyListeners();
    try {
      _produto = await _produtos.obter(idProduto);
      _itensDaFicha = await _itens.listar(idProduto);
    } on ApiException catch (e) {
      _erro = e.mensagem;
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  /// PUT do produto. Mande todos os campos: {...produto.dadosEditaveis(), 'campo': novoValor}
  Future<void> atualizarProduto(Map<String, dynamic> dados) async {
    _produto = await _produtos.atualizar(_produto!.idProduto, dados);
    notifyListeners();
  }

  Future<void> adicionarItem({required int idInsumo, required double qtde}) async {
    await _itens.adicionar(_produto!.idProduto, idInsumo: idInsumo, qtde: qtde);
    await carregar(_produto!.idProduto);
  }

  Future<void> mudarQuantidade(ItemFicha item, double qtde) async {
    await _itens.mudarQuantidade(_produto!.idProduto, item.idItem, qtde);
    await carregar(_produto!.idProduto);
  }

  Future<void> removerItem(ItemFicha item) async {
    await _itens.remover(_produto!.idProduto, item.idItem);
    await carregar(_produto!.idProduto);
  }

  /// Apaga o produto e a ficha dele (RN13).
  Future<void> excluirProduto() => _produtos.excluir(_produto!.idProduto);
}
