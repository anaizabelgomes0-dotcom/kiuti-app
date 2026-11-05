import 'package:flutter/material.dart';

import 'package:kiuti_app/theme/cores.dart';

/// Cartão de cantos arredondados, usado em quase todas as telas.
/// Padrão: fundo rosa claro. `branco: true`: fundo branco com borda rosa (listas, composição, reajustes).
class CartaoRosa extends StatelessWidget {
  const CartaoRosa({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.branco = false,
    this.raio = 20,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool branco;
  final double raio;

  @override
  Widget build(BuildContext context) {
    // Material (e não Container) para o efeito de toque das ListTile aparecer por cima do fundo.
    return Material(
      color: branco ? Colors.white : Cores.rosaClaro,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(raio),
        side: branco ? const BorderSide(color: Cores.borda) : BorderSide.none,
      ),
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
