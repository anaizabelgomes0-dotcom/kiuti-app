import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';

import 'package:kiuti_app/theme/cores.dart';

/// A palavra KIUTI no topo das abas.
class LogoKiuti extends StatelessWidget {
  const LogoKiuti({super.key, this.altura = 28});

  final double altura;

  @override
  Widget build(BuildContext context) => Image.asset('assets/logo.png', height: altura);
}

/// As poses do gato (Manual da Marca → Logo), cada uma com o seu arquivo em `assets/`.
enum Pose {
  boasVindas('boas_vindas'),
  convite('convite'),
  esperando('esperando'),
  concluido('concluido'),
  dica('dica'),
  cuidado('cuidado'),
  bloqueado('bloqueado'),
  dormindo('dormindo');

  const Pose(this.arquivo);

  final String arquivo;
}

/// O gato: só em estados vazios, confirmações e avisos de exclusão. Sem pose, usa o mascote base.
class Mascote extends StatelessWidget {
  const Mascote({super.key, this.tamanho = 96, this.pose});

  final double tamanho;
  final Pose? pose;

  @override
  Widget build(BuildContext context) {
    // Entra com um leve efeito elástico. Fundo branco com o mesmo tracejado do preço sugerido da ficha incompleta.
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.6, end: 1),
      duration: const Duration(milliseconds: 600),
      curve: Curves.elasticOut,
      builder: (context, escala, filho) => Transform.scale(scale: escala, child: filho),
      child: _circulo(),
    );
  }

  Widget _circulo() {
    return DottedBorder(
      options: const CircularDottedBorderOptions(
        dashPattern: [6, 4],
        strokeWidth: 1.5,
        color: Cores.cinza,
        padding: EdgeInsets.zero,
      ),
      child: Container(
        width: tamanho,
        height: tamanho,
        padding: EdgeInsets.all(tamanho * 0.12),
        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        child: Image.asset(pose == null ? 'assets/mascote.png' : 'assets/mascote_${pose!.arquivo}.png'),
      ),
    );
  }
}
