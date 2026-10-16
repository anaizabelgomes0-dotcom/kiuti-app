import 'package:dio/dio.dart';
import 'package:kiuti_app/config.dart';
import 'package:kiuti_app/providers/sessao_provider.dart';

import 'api_exception.dart';

/// Cria o Dio do app: endereço da API, tempo de espera e o token em toda requisição.
Dio criarDio(SessaoProvider sessao) {
  final dio = Dio(
    BaseOptions(
      baseUrl: apiUrl,
      // Até 60 s: a API gratuita "dorme" e demora para acordar (I0-API-12).
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
    ),
  );
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (opcoes, handler) {
        final token = sessao.token;
        if (token != null) opcoes.headers['Authorization'] = 'Bearer $token';
        handler.next(opcoes);
      },
      onError: (erro, handler) {
        // Token vencido: apaga a sessão, e o go_router volta para o login sozinho (I0-FL-06).
        if (erro.response?.statusCode == 401 && erro.requestOptions.path != '/auth/login') {
          sessao.sair();
        }
        handler.next(erro);
      },
    ),
  );
  return dio;
}

/// Espera a resposta e devolve o JSON. Qualquer erro vira ApiException, com a mensagem pronta para a tela.
Future<dynamic> chamar(Future<Response<dynamic>> requisicao) async {
  try {
    final resposta = await requisicao;
    return resposta.data;
  } on DioException catch (e) {
    throw ApiException.doDio(e);
  }
}
