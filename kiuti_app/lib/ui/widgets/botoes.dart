
import 'package:flutter/material.dart';

import 'package:kiuti_app/theme/cores.dart';

class BotaoPrincipal extends StatelessWidget {
  final String texto;
  final VoidCallback onPressed;
  final bool carregando;

  const BotaoPrincipal({
    super.key,
    required this.texto,
    required this.onPressed,
    this.carregando = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: carregando ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Cores.rosa,
          foregroundColor: Cores.preto,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: carregando
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
            : Text(
                texto,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
      ),
    );
  }
}

