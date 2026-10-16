import 'json.dart';
import 'situacao.dart';

/// Margem e custos que entraram no cálculo (o próprio do produto ou o padrão).
class Efetivos {
  Efetivos({
    required this.percLucro,
    required this.custoEmbalagem,
    required this.custoEnvio,
    required this.custoBrinde,
    required this.despesasVariaveis,
  });

  final double percLucro;
  final double custoEmbalagem;
  final double custoEnvio;
  final double custoBrinde;
  final double despesasVariaveis;

  factory Efetivos.fromJson(Map<String, dynamic> json) => Efetivos(
        percLucro: lerDouble(json['perc_lucro']),
        custoEmbalagem: lerDouble(json['custo_embalagem']),
        custoEnvio: lerDouble(json['custo_envio']),
        custoBrinde: lerDouble(json['custo_brinde']),
        despesasVariaveis: lerDouble(json['despesas_variaveis']),
      );
}

/// Produto, como a API devolve (contrato-api.md#produto).
class Produto {
  Produto({
    required this.idProduto,
    required this.nome,
    required this.skuReferencia,
    required this.precoAtualShopee,
    required this.percLucro,
    required this.custoEmbalagem,
    required this.custoEnvio,
    required this.custoBrinde,
    required this.despesasVariaveis,
    required this.idProdutoShopee,
    required this.ativo,
    required this.efetivos,
    required this.custoInsumos,
    required this.custoTotal,
    required this.lucroMeta,
    required this.precoSugerido,
    required this.lucroAtual,
    required this.situacao,
  });

  final int idProduto;
  final String nome;
  final String? skuReferencia;
  final double precoAtualShopee;
  // Campos próprios: null = usa o padrão das Configurações (RN02).
  final double? percLucro;
  final double? custoEmbalagem;
  final double? custoEnvio;
  final double? custoBrinde;
  final double? despesasVariaveis;
  final String? idProdutoShopee;
  final bool ativo;
  // Calculados pela API. Os três "?" vêm null quando a ficha está incompleta (RN04).
  final Efetivos efetivos;
  final double custoInsumos;
  final double custoTotal;
  final double? lucroMeta;
  final double? precoSugerido;
  final double? lucroAtual;
  final Situacao situacao;

  factory Produto.fromJson(Map<String, dynamic> json) => Produto(
        idProduto: json['id_produto'] as int,
        nome: json['nome'] as String,
        skuReferencia: json['sku_referencia'] as String?,
        precoAtualShopee: lerDouble(json['preco_atual_shopee']),
        percLucro: lerDoubleOuNulo(json['perc_lucro']),
        custoEmbalagem: lerDoubleOuNulo(json['custo_embalagem']),
        custoEnvio: lerDoubleOuNulo(json['custo_envio']),
        custoBrinde: lerDoubleOuNulo(json['custo_brinde']),
        despesasVariaveis: lerDoubleOuNulo(json['despesas_variaveis']),
        idProdutoShopee: json['id_produto_shopee'] as String?,
        ativo: json['ativo'] as bool,
        efetivos: Efetivos.fromJson(json['efetivos'] as Map<String, dynamic>),
        custoInsumos: lerDouble(json['custo_insumos']),
        custoTotal: lerDouble(json['custo_total']),
        lucroMeta: lerDoubleOuNulo(json['lucro_meta']),
        precoSugerido: lerDoubleOuNulo(json['preco_sugerido']),
        lucroAtual: lerDoubleOuNulo(json['lucro_atual']),
        situacao: Situacao.deTexto(json['situacao'] as String),
      );

  /// Os campos que o PUT /produtos/{id} recebe, com os valores atuais.
  /// Para mudar um campo: {...produto.dadosEditaveis(), 'perc_lucro': 50.0}
  Map<String, dynamic> dadosEditaveis() => {
        'nome': nome,
        'sku_referencia': skuReferencia,
        'preco_atual_shopee': precoAtualShopee,
        'perc_lucro': percLucro,
        'custo_embalagem': custoEmbalagem,
        'custo_envio': custoEnvio,
        'custo_brinde': custoBrinde,
        'despesas_variaveis': despesasVariaveis,
      };
}
