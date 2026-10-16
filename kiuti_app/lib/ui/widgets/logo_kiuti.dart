import 'package:flutter/material.dart';

import 'package:kiuti_app/theme/cores.dart';

/// A palavra KIUTI no topo das abas.
class LogoKiuti extends StatelessWidget {
  const LogoKiuti({super.key, this.altura = 28});

  final double altura;

  @override
  Widget build(BuildContext context) => Image.asset('assets/logo.png', height: altura);
}

/// O gato: só em estados vazios, confirmações e avisos de exclusão.
class Mascote extends StatelessWidget {
  const Mascote({super.key, this.tamanho = 96});

  final double tamanho;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: tamanho,
      height: tamanho,
      padding: EdgeInsets.all(tamanho * 0.12),
      decoration: const BoxDecoration(color: Cores.rosa, shape: BoxShape.circle),
      child: Image.asset('assets/mascote.png'),
    );
  }
}
