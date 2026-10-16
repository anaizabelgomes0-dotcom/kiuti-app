import 'package:flutter/material.dart';

import 'logo_kiuti.dart';

/// Topo das quatro abas: logo KIUTI, título grande e algo à direita (contador, botão).
class CabecalhoAba extends StatelessWidget {
  const CabecalhoAba({super.key, required this.titulo, this.direita});

  final String titulo;
  final Widget? direita;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const LogoKiuti(),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: Text(titulo, style: Theme.of(context).textTheme.headlineMedium)),
              ?direita, // o "?" só põe o widget na linha se ele não for null
            ],
          ),
        ],
      ),
    );
  }
}
