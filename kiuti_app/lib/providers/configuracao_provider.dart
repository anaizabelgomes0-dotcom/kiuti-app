import 'package:flutter/foundation.dart';
import 'package:kiuti_app/models/configuracao.dart';
import 'package:kiuti_app/services/api_exception.dart';
import 'package:kiuti_app/services/configuracao_service.dart';

/// As configurações globais: usadas na aba Configurações e nos padrões de Dados do produto.
class ConfiguracaoProvider extends ChangeNotifier {
  ConfiguracaoProvider(this._service);

  final ConfiguracaoService _service;

  Configuracao? _config;
  Configuracao? get config => _config;

  bool _carregando = true;
  bool get carregando => _carregando;

  String? _erro;
  String? get erro => _erro;

  Future<void> carregar() async {
    _carregando = true;
    _erro = null;
    notifyListeners();
    try {
      _config = await _service.obter();
    } on ApiException catch (e) {
      _erro = e.mensagem;
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  /// Manda só as chaves que mudaram. Se a API recusar, a ApiException chega na tela (erro embaixo do campo).
  Future<void> salvar(Map<String, double> mudancas) async {
    _config = await _service.atualizar(mudancas);
    notifyListeners();
  }
}
