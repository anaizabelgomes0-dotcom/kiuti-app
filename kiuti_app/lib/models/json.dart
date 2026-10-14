double lerDouble(Object? valor) => (valor as num).toDouble();

double? lerDoubleOuNulo(Object? valor) =>
    valor == null ? null : (valor as num).toDouble();