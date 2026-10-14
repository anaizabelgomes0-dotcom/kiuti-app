import 'package:flutter/material.dart';


class EstadoVazio extends StatelessWidget {
  final String mensagem;
  final IconData icone;

  const EstadoVazio({
    super.key,
    required this.mensagem,
    this.icone = Icons.inbox_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icone,
              size: 48,
              color: Colors.grey,
            ),
            const SizedBox(height: 12),
            Text(
              mensagem,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class ErroComTentar extends StatelessWidget {
  final String mensagem;
  final VoidCallback aoTentar;

  const ErroComTentar({
    super.key,
    required this.mensagem,
    required this.aoTentar,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red,
            ),
            const SizedBox(height: 12),
            Text(
              mensagem,
              textAlign: TextAlign.center,
            ),
         
          ],
        ),
      ),
    );
  }
}