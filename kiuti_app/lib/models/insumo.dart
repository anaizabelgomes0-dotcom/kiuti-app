import 'json.dart';

/// Insumo, como a API devolve (contrato-api.md#insumo).
class Insumo {
  Insumo({
    required this.idInsumo,
    required this.nome,
    required this.custo,
    required this.unidadeCompra,
    required this.qtdeCompra,
    required this.custoUnitario,
    required this.qtdProdutos,
  });

  final int idInsumo;
  final String nome;
  final double custo;
  final String unidadeCompra;
  final double qtdeCompra;
  final double custoUnitario;
  final int qtdProdutos;

  factory Insumo.fromJson(Map<String, dynamic> json) => Insumo(
        idInsumo: json['id_insumo'] as int,
        nome: json['nome'] as String,
        custo: lerDouble(json['custo']),
        unidadeCompra: json['unidade_compra'] as String,
        qtdeCompra: lerDouble(json['qtde_compra']),
        custoUnitario: lerDouble(json['custo_unitario']),
        qtdProdutos: json['qtd_produtos'] as int,
      );
}

/// Unidades aceitas pela API.
const unidadesDeCompra = ['g', 'kg', 'm', 'cm', 'ml', 'l', 'un', 'pct'];

/// A unidade escrita por extenso, para frases como "Custo por grama".
const unidadePorExtenso = {
  'g': 'grama',
  'kg': 'quilo',
  'm': 'metro',
  'cm': 'centímetro',
  'ml': 'mililitro',
  'l': 'litro',
  'un': 'unidade',
  'pct': 'pacote',
};