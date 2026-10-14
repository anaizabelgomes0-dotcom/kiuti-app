import 'json.dart';

/// Produto que usa um insumo.
class ProdutoUso {
  ProdutoUso({
    required this.idProduto,
    required this.nome,
    required this.qtde,
  });

  final int idProduto;
  final String nome;
  final double qtde;

  factory ProdutoUso.fromJson(Map<String, dynamic> json) => ProdutoUso(
        idProduto: json['id_produto'] as int,
        nome: json['nome'] as String,
        qtde: lerDouble(json['qtde']),
      );
}