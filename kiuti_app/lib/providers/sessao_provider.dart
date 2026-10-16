import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// O token do login: fica na memória (para o Dio) e no armazenamento seguro do celular (para a próxima vez).
/// Quando muda, avisa o go_router, que leva para o login ou para as abas (I0-FL-06).
class SessaoProvider extends ChangeNotifier {
  static const _armazenamento = FlutterSecureStorage();

  String? _token;
  String? get token => _token;
  bool get logado => _token != null;

  /// Lê o token guardado. Chamado uma vez, no main(), antes de abrir o app.
  Future<void> carregar() async {
    _token = await _armazenamento.read(key: 'token');
    notifyListeners();
  }

  Future<void> guardar(String token) async {
    await _armazenamento.write(key: 'token', value: token);
    _token = token;
    notifyListeners();
  }

  Future<void> sair() async {
    await _armazenamento.delete(key: 'token');
    _token = null;
    notifyListeners();
  }
}
