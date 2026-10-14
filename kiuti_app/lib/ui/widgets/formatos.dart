
import 'package:intl/intl.dart';

final _reais = NumberFormat.currency(
  locale: 'pt_BR',
  symbol: r'R$',
  decimalDigits: 2,
);

final _reaisUnitario = NumberFormat(r'#,##0.00#', 'pt_BR');
final _numero = NumberFormat(r'#,##0.###', 'pt_BR');
final _valor = NumberFormat(r'#,##0.00', 'pt_BR');

String formatarReais(double valor) =>
    _reais.format(valor).replaceAll(' ', ' ');

String formatarReaisUnitario(double valor) =>
    'R\$ ${_reaisUnitario.format(valor)}';

String formatarValor(double valor) => _valor.format(valor);

String formatarNumero(double valor) => _numero.format(valor);

double? lerNumero(String texto) {
  var t = texto.replaceAll(r'R$', '').trim();

  if (t.contains(',')) {
    t = t.replaceAll('.', '').replaceAll(',', '.');
  }

  return double.tryParse(t);
}
