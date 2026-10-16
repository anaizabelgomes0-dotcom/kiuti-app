import 'package:flutter_test/flutter_test.dart';
import 'package:kiuti_app/ui/widgets/formatos.dart';

void main() {
  test('formatarReais', () {
    expect(formatarReais(15.45), 'R\$ 15,45');
    expect(formatarReais(1234.5), 'R\$ 1.234,50');
  });

  test('formatarReaisUnitario', () {
    expect(formatarReaisUnitario(0.12), 'R\$ 0,12');
    expect(formatarReaisUnitario(0.156), 'R\$ 0,156');
  });

  test('formatarNumero e formatarValor', () {
    expect(formatarNumero(8.0), '8');
    expect(formatarNumero(0.5), '0,5');
    expect(formatarValor(60), '60,00');
  });

  test('lerNumero', () {
    expect(lerNumero('1.234,50'), 1234.5);
    expect(lerNumero('0,5'), 0.5);
    expect(lerNumero('0.5'), 0.5);
    expect(lerNumero(''), null);
    expect(lerNumero('abc'), null);
  });
}
