import 'package:dio/dio.dart';
import 'package:kiuti_app/models/produto.dart';

import 'api.dart';

class ProdutoService {
  ProdutoService(this._dio);

  final Dio _dio;

  /// GET /produtos (só os ativos)
  Future<List<Produto>> listar() async {
    final lista = await chamar(_dio.get('/produtos')) as List;
    return lista.map((json) => Produto.fromJson(json as Map<String, dynamic>)).toList();
  }

  /// GET /produtos/{id}
  Future<Produto> obter(int idProduto) async =>
      Produto.fromJson(await chamar(_dio.get('/produtos/$idProduto')) as Map<String, dynamic>);

  /// POST /produtos
  Future<Produto> criar({required String nome, String? skuReferencia, required double precoAtualShopee}) async {
    final json = await chamar(_dio.post('/produtos', data: {
      'nome': nome,
      'sku_referencia': skuReferencia,
      'preco_atual_shopee': precoAtualShopee,
    }));
    return Produto.fromJson(json as Map<String, dynamic>);
  }

  /// PUT /produtos/{id}. Mande sempre todos os campos: {...produto.dadosEditaveis(), 'campo': novoValor}
  Future<Produto> atualizar(int idProduto, Map<String, dynamic> dados) async =>
      Produto.fromJson(await chamar(_dio.put('/produtos/$idProduto', data: dados)) as Map<String, dynamic>);

  /// DELETE /produtos/{id} (a ficha vai junto)
  Future<void> excluir(int idProduto) async {
    await chamar(_dio.delete('/produtos/$idProduto'));
  }
}
