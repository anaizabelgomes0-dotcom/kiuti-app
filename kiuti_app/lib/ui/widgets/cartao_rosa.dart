import 'package:flutter/material.dart';

import 'package:kiuti_app/theme/cores.dart';

/// Cartão de fundo rosa claro e cantos arredondados, usado em quase todas as telas.
class CartaoRosa extends StatelessWidget {
  const CartaoRosa({super.key, required this.child, this.padding = const EdgeInsets.all(16)});

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    // Material (e não Container) para o efeito de toque das ListTile aparecer por cima do rosa.
    return Material(
      color: Cores.rosaClaro,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: Padding(padding: padding, child: SizedBox(width: double.infinity, child: child)),
    );
  }
}

/// Título vermelho em maiúsculas dentro dos cartões ("TAXAS DA SHOPEE", "COMPOSIÇÃO").
class TituloSecao extends StatelessWidget {
  const TituloSecao(this.texto, {super.key});

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        texto.toUpperCase(),
        style: const TextStyle(color: Cores.vermelho, fontWeight: FontWeight.w700, letterSpacing: 0.5),
      ),
    );
  }
}
