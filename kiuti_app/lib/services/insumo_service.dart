import 'package:dio/dio.dart';
import 'package:kiuti_app/models/insumo.dart';
import 'package:kiuti_app/models/produto_uso.dart';

import 'api.dart';

class InsumoService {
  InsumoService(this._dio);

  final Dio _dio;

  /// GET /insumos
  Future<List<Insumo>> listar() async {
    final lista = await chamar(_dio.get('/insumos')) as List;
    return lista.map((json) => Insumo.fromJson(json as Map<String, dynamic>)).toList();
  }

  /// GET /insumos/{id}
  Future<Insumo> obter(int idInsumo) async =>
      Insumo.fromJson(await chamar(_dio.get('/insumos/$idInsumo')) as Map<String, dynamic>);

  /// POST /insumos
  Future<Insumo> criar({
    required String nome,
    required double custo,
    required String unidadeCompra,
    required double qtdeCompra,
  }) async {
    final json = await chamar(_dio.post('/insumos', data: {
      'nome': nome,
      'custo': custo,
      'unidade_compra': unidadeCompra,
      'qtde_compra': qtdeCompra,
    }));
    return Insumo.fromJson(json as Map<String, dynamic>);
  }

  /// PUT /insumos/{id}
  Future<Insumo> atualizar(
    int idInsumo, {
    required String nome,
    required double custo,
    required String unidadeCompra,
    required double qtdeCompra,
  }) async {
    final json = await chamar(_dio.put('/insumos/$idInsumo', data: {
      'nome': nome,
      'custo': custo,
      'unidade_compra': unidadeCompra,
      'qtde_compra': qtdeCompra,
    }));
    return Insumo.fromJson(json as Map<String, dynamic>);
  }

  /// DELETE /insumos/{id}. Em uso: ApiException 409, com a lista em e.dados['produtos'].
  Future<void> excluir(int idInsumo) async {
    await chamar(_dio.delete('/insumos/$idInsumo'));
  }

  /// GET /insumos/{id}/produtos
  Future<List<ProdutoUso>> produtosQueUsam(int idInsumo) async {
    final lista = await chamar(_dio.get('/insumos/$idInsumo/produtos')) as List;
    return lista.map((json) => ProdutoUso.fromJson(json as Map<String, dynamic>)).toList();
  }
}
