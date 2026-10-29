import 'package:flutter_test/flutter_test.dart';
import 'package:kiuti_app/ui/widgets/campo_busca.dart';

void main() {
  test('combinaComBusca ignora maiúsculas, acentos e espaços nas pontas', () {
    expect(combinaComBusca('Resina Cristal', 'res'), isTrue);
    expect(combinaComBusca('Argola Dourada', 'ARGOLA '), isTrue);
    expect(combinaComBusca('Pingente Coração', 'coracao'), isTrue);
    expect(combinaComBusca('Fio de nylon', 'res'), isFalse);
    expect(combinaComBusca('Qualquer', ''), isTrue);
  });
}
