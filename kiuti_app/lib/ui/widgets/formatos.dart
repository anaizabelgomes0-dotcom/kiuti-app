import 'package:intl/intl.dart';

final _reais = NumberFormat.currency(locale: 'pt_BR', symbol: r'R$', decimalDigits: 2);
final _reaisUnitario = NumberFormat(r'#,##0.00#', 'pt_BR');
final _numero = NumberFormat(r'#,##0.###', 'pt_BR');
final _valor = NumberFormat(r'#,##0.00', 'pt_BR');

/// 15.45 → "R$ 15,45"; 1234.5 → "R$ 1.234,50".
String formatarReais(double valor) => _reais.format(valor).replaceAll(' ', ' ');

/// Custo por unidade, com até 3 casas: 0.12 → "R$ 0,12"; 0.156 → "R$ 0,156".
String formatarReaisUnitario(double valor) => 'R\$ ${_reaisUnitario.format(valor)}';

/// Valor em dinheiro sem o "R$", para campos e colunas: 60.0 → "60,00"; 3.892 → "3,89".
String formatarValor(double valor) => _valor.format(valor);

/// Quantidades e percentuais: 8.0 → "8"; 0.5 → "0,5"; 1500.0 → "1.500".
String formatarNumero(double valor) => _numero.format(valor);

/// Lê o que a pessoa digitou: "1.234,50" → 1234.5; "0,5" → 0.5; "0.5" → 0.5; "" ou "abc" → null.
double? lerNumero(String texto) {
  var t = texto.replaceAll(r'R$', '').trim();
  if (t.contains(',')) t = t.replaceAll('.', '').replaceAll(',', '.');
  return double.tryParse(t);
}
