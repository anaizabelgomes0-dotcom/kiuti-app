import 'package:flutter_test/flutter_test.dart';
import 'package:kiuti_app/models/insumo.dart';
import 'package:kiuti_app/models/produto_uso.dart';
import 'package:kiuti_app/models/situacao.dart';

void main() {
  test('Insumo converte números para double', () {
    final insumo = Insumo.fromJson({
      'id_insumo': 1,
      'nome': 'Resina epóxi',
      'custo': 60,
      'unidade_compra': 'g',
      'qtde_compra': 500,
      'custo_unitario': 0.12,
      'qtd_produtos': 1,
    });

    expect(insumo.custo, 60.0);
    expect(insumo.custoUnitario, 0.12);
  });

  test('Situação reconhece ficha incompleta', () {
    expect(
      Situacao.deTexto('ficha_incompleta'),
      Situacao.fichaIncompleta,
    );
  });

  test('ProdutoUso lê os dados do JSON', () {
    final produto = ProdutoUso.fromJson({
      'id_produto': 2,
      'nome': 'Pulseira',
      'qtde': 3,
    });

    expect(produto.idProduto, 2);
    expect(produto.nome, 'Pulseira');
    expect(produto.qtde, 3.0);
  });
}