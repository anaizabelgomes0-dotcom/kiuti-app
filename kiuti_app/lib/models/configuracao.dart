import 'json.dart';

/// As sete configurações globais da aplicação.
class Configuracao {
  Configuracao(this.valores);

  /// Chaves na ordem da tela.
  static const chaves = [
    'perc_taxa_shopee',
    'taxa_fixa_shopee',
    'embalagem_padrao',
    'brinde_padrao',
    'envio_padrao',
    'despesas_variaveis_padrao',
    'perc_lucro_padrao',
  ];

  final Map<String, double> valores;

  double get percTaxaShopee => valores['perc_taxa_shopee']!;
  double get taxaFixaShopee => valores['taxa_fixa_shopee']!;
  double get percLucroPadrao => valores['perc_lucro_padrao']!;
  double get embalagemPadrao => valores['embalagem_padrao']!;
  double get envioPadrao => valores['envio_padrao']!;
  double get brindePadrao => valores['brinde_padrao']!;
  double get despesasVariaveisPadrao =>
      valores['despesas_variaveis_padrao']!;

  factory Configuracao.fromJson(Map<String, dynamic> json) =>
      Configuracao({
        for (final chave in chaves) chave: lerDouble(json[chave]),
      });
}