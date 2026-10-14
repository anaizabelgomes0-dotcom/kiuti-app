
import 'package:flutter/material.dart';

import 'package:kiuti_app/theme/cores.dart';

class CartaoRosa extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const CartaoRosa({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Cores.rosaClaro,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Cores.borda,
        ),
      ),
      child: child,
    );
  }
}

