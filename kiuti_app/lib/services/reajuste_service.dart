import 'package:dio/dio.dart';
import 'package:kiuti_app/models/produto.dart';

import 'api.dart';

class ReajusteService {
  ReajusteService(this._dio);

  final Dio _dio;

  /// GET /reajustes (produtos ativos abaixo da meta)
  Future<List<Produto>> listar() async {
    final lista = await chamar(_dio.get('/reajustes')) as List;
    return lista.map((json) => Produto.fromJson(json as Map<String, dynamic>)).toList();
  }

  /// POST /produtos/{id}/marcar-atualizado
  Future<Produto> marcarAtualizado(int idProduto) async => Produto.fromJson(
      await chamar(_dio.post('/produtos/$idProduto/marcar-atualizado')) as Map<String, dynamic>);
}
