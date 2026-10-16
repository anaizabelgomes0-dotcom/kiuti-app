import 'package:dio/dio.dart';
import 'package:kiuti_app/models/item_ficha.dart';

import 'api.dart';

class ItemService {
  ItemService(this._dio);

  final Dio _dio;

  /// GET /produtos/{id}/itens
  Future<List<ItemFicha>> listar(int idProduto) async {
    final lista = await chamar(_dio.get('/produtos/$idProduto/itens')) as List;
    return lista.map((json) => ItemFicha.fromJson(json as Map<String, dynamic>)).toList();
  }

  /// POST /produtos/{id}/itens
  Future<void> adicionar(int idProduto, {required int idInsumo, required double qtde}) async {
    await chamar(_dio.post('/produtos/$idProduto/itens', data: {'id_insumo': idInsumo, 'qtde': qtde}));
  }

  /// PUT /produtos/{id}/itens/{id_item}
  Future<void> mudarQuantidade(int idProduto, int idItem, double qtde) async {
    await chamar(_dio.put('/produtos/$idProduto/itens/$idItem', data: {'qtde': qtde}));
  }

  /// DELETE /produtos/{id}/itens/{id_item}
  Future<void> remover(int idProduto, int idItem) async {
    await chamar(_dio.delete('/produtos/$idProduto/itens/$idItem'));
  }
}
