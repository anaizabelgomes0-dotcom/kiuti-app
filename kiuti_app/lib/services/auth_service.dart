import 'package:dio/dio.dart';
import 'package:kiuti_app/providers/sessao_provider.dart';

import 'api.dart';

class AuthService {
  AuthService(this._dio, this._sessao);

  final Dio _dio;
  final SessaoProvider _sessao;

  /// POST /auth/login. Guarda o token se der certo; senão, lança ApiException.
  Future<void> entrar(String login, String senha) async {
    final json = await chamar(_dio.post('/auth/login', data: {'login': login, 'senha': senha}));
    await _sessao.guardar(json['access_token'] as String);
  }

  Future<void> sair() => _sessao.sair();
}
