import 'package:dio/dio.dart';

/// Erro vindo da API (ou falta de conexão), já com a mensagem para mostrar na tela.
class ApiException implements Exception {
  ApiException(this.status, this.mensagem, {this.campo, this.dados = const {}});

  final int status; // 0 = sem conexão; 401, 404, 409, 422...
  final String mensagem; // o "detail" da API
  final String? campo; // campo do formulário com erro ("nome", "qtde_compra"...)
  final Map<String, dynamic> dados; // o JSON inteiro (ex.: lista "produtos" do 409 ao excluir insumo)

  /// Traduz o erro do Dio: sem resposta (internet, API fora do ar) ou resposta de erro da API.
  factory ApiException.doDio(DioException erro) {
    final resposta = erro.response;
    if (resposta == null) {
      final demorou = erro.type == DioExceptionType.connectionTimeout ||
          erro.type == DioExceptionType.sendTimeout ||
          erro.type == DioExceptionType.receiveTimeout;
      return ApiException(
        0,
        demorou
            ? 'A API demorou para responder. Tente de novo.'
            : 'Não foi possível conectar. Confira a internet e tente de novo.',
      );
    }
    final status = resposta.statusCode ?? 0;
    final json = resposta.data;
    if (json is Map<String, dynamic>) {
      return ApiException(
        status,
        json['detail']?.toString() ?? 'Erro inesperado ($status).',
        campo: json['campo'] as String?,
        dados: json,
      );
    }
    return ApiException(status, 'Erro inesperado ($status).');
  }

  @override
  String toString() => mensagem;
}
