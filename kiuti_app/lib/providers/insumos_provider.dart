import 'package:flutter/foundation.dart';
import 'package:kiuti_app/models/insumo.dart';
import 'package:kiuti_app/models/produto_uso.dart';
import 'package:kiuti_app/services/api_exception.dart';
import 'package:kiuti_app/services/insumo_service.dart';

/// A lista de insumos e as ações sobre eles. Depois de salvar ou excluir, recarrega a lista.
class InsumosProvider extends ChangeNotifier {
  InsumosProvider(this._service);

  final InsumoService _service;

  List<Insumo> _insumos = [];
  List<Insumo> get insumos => _insumos;

  bool _carregando = true;
  bool get carregando => _carregando;

  String? _erro;
  String? get erro => _erro;

  Future<void> carregar() async {
    _carregando = true;
    _erro = null;
    notifyListeners();
    try {
      _insumos = await _service.listar();
    } on ApiException catch (e) {
      _erro = e.mensagem;
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  /// Cadastra (idInsumo == null) ou edita. Erro da API chega na tela como ApiException.
  Future<void> salvar({
    int? idInsumo,
    required String nome,
    required double custo,
    required String unidadeCompra,
    required double qtdeCompra,
  }) async {
    if (idInsumo == null) {
      await _service.criar(nome: nome, custo: custo, unidadeCompra: unidadeCompra, qtdeCompra: qtdeCompra);
    } else {
      await _service.atualizar(idInsumo,
          nome: nome, custo: custo, unidadeCompra: unidadeCompra, qtdeCompra: qtdeCompra);
    }
    await carregar();
  }

  /// Em uso: ApiException 409, com a lista em e.dados['produtos'] (RN11).
  Future<void> excluir(int idInsumo) async {
    await _service.excluir(idInsumo);
    await carregar();
  }

  Future<Insumo> obter(int idInsumo) => _service.obter(idInsumo);

  Future<List<ProdutoUso>> produtosQueUsam(int idInsumo) => _service.produtosQueUsam(idInsumo);
}
