import 'package:dio/dio.dart';
import 'package:kiuti_app/models/configuracao.dart';

import 'api.dart';

class ConfiguracaoService {
  ConfiguracaoService(this._dio);

  final Dio _dio;

  /// GET /configuracoes
  Future<Configuracao> obter() async =>
      Configuracao.fromJson(await chamar(_dio.get('/configuracoes')) as Map<String, dynamic>);

  /// PUT /configuracoes, só com as chaves que mudaram: {'perc_taxa_shopee': 20.0}
  Future<Configuracao> atualizar(Map<String, double> valores) async =>
      Configuracao.fromJson(await chamar(_dio.put('/configuracoes', data: valores)) as Map<String, dynamic>);
}
