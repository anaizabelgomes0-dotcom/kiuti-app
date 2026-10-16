import 'package:flutter_test/flutter_test.dart';
import 'package:kiuti_app/models/insumo.dart';
import 'package:kiuti_app/models/produto.dart';
import 'package:kiuti_app/models/produto_uso.dart';
import 'package:kiuti_app/models/situacao.dart';

void main() {
  test('Insumo.fromJson (exemplo do contrato)', () {
    final insumo = Insumo.fromJson({
      'id_insumo': 1,
      'nome': 'Resina epóxi',
      'custo': 60, // int no JSON: precisa virar double
      'unidade_compra': 'g',
      'qtde_compra': 500.0,
      'custo_unitario': 0.12,
      'qtd_produtos': 1,
    });
    expect(insumo.custo, 60.0);
    expect(insumo.custoUnitario, 0.12);
  });

  test('Produto.fromJson com ficha incompleta', () {
    final produto = Produto.fromJson({
      'id_produto': 2,
      'nome': 'Pulseira Miçanga',
      'sku_referencia': null,
      'preco_atual_shopee': 12.9,
      'perc_lucro': null,
      'custo_embalagem': null,
      'custo_envio': null,
      'custo_brinde': null,
      'despesas_variaveis': null,
      'id_produto_shopee': null,
      'ativo': true,
      'efetivos': {
        'perc_lucro': 100.0,
        'custo_embalagem': 1.5,
        'custo_envio': 0.0,
        'custo_brinde': 0.5,
        'despesas_variaveis': 0.0,
      },
      'custo_insumos': 0.0,
      'custo_total': 2.0,
      'lucro_meta': null,
      'preco_sugerido': null,
      'lucro_atual': null,
      'situacao': 'ficha_incompleta',
    });
    expect(produto.precoSugerido, isNull);
    expect(produto.situacao, Situacao.fichaIncompleta);
    expect(produto.efetivos.custoEmbalagem, 1.5);
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
