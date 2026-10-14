import 'json.dart';

/// Linha da ficha técnica.
class ItemFicha {
  ItemFicha({
    required this.idItem,
    required this.idInsumo,
    required this.nomeInsumo,
    required this.unidadeCompra,
    required this.custoUnitario,
    required this.qtde,
    required this.custoItem,
  });

  final int idItem;
  final int idInsumo;
  final String nomeInsumo;
  final String unidadeCompra;
  final double custoUnitario;
  final double qtde;
  final double custoItem;

  factory ItemFicha.fromJson(Map<String, dynamic> json) => ItemFicha(
        idItem: json['id_item'] as int,
        idInsumo: json['id_insumo'] as int,
        nomeInsumo: json['nome_insumo'] as String,
        unidadeCompra: json['unidade_compra'] as String,
        custoUnitario: lerDouble(json['custo_unitario']),
        qtde: lerDouble(json['qtde']),
        custoItem: lerDouble(json['custo_item']),
      );
}