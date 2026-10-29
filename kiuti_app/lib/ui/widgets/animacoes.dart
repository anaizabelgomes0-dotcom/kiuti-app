import 'package:flutter/material.dart';

import 'formatos.dart';

/// Linha de lista que entra com fade e sobe um pouco. Quanto maior o [indice], mais tarde termina (efeito escalonado).
/// Só anima quando a linha nasce: dar a ela uma `key` com o id evita repetir a animação ao filtrar ou recarregar.
class EntradaEscalonada extends StatelessWidget {
  const EntradaEscalonada({super.key, required this.indice, required this.child});

  final int indice;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 250 + (indice < 8 ? indice : 8) * 45),
      curve: Curves.easeOutCubic,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(offset: Offset(0, 16 * (1 - t)), child: child),
      ),
      child: child,
    );
  }
}

/// Anima a altura quando linhas entram ou saem (excluir, desfazer, filtrar a busca).
class AjusteDeAltura extends StatelessWidget {
  const AjusteDeAltura({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => AnimatedSize(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        alignment: Alignment.topCenter,
        child: child,
      );
}

/// Valor em reais que "conta" até o novo número quando muda (a primeira exibição não anima).
class ReaisAnimado extends StatelessWidget {
  const ReaisAnimado(this.valor, {super.key, this.estilo});

  final double valor;
  final TextStyle? estilo;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(end: valor),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      builder: (context, v, _) => Text(formatarReais(v), style: estilo),
    );
  }
}
