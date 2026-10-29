import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';

import 'package:kiuti_app/models/situacao.dart';
import 'package:kiuti_app/theme/cores.dart';

/// "Abaixo da meta" (vermelho), "Na meta" (rosa com ✓) e "Ficha incompleta" (tracejado).
class SeloSituacao extends StatelessWidget {
  const SeloSituacao(this.situacao, {super.key});

  final Situacao situacao;

  @override
  Widget build(BuildContext context) => AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: KeyedSubtree(key: ValueKey(situacao), child: _selo()),
      );

  Widget _selo() {
    const estiloTexto = TextStyle(fontSize: 13, fontWeight: FontWeight.w600);
    switch (situacao) {
      case Situacao.abaixoDaMeta:
        return _pilula(Cores.vermelho, Text('Abaixo da meta', style: estiloTexto.copyWith(color: Colors.white)));
      case Situacao.naMeta:
        return _pilula(
          Cores.rosa,
          const Row(
            mainAxisSize: MainAxisSize.min,
            children: [Icon(Icons.check, size: 14), SizedBox(width: 4), Text('Na meta', style: estiloTexto)],
          ),
        );
      case Situacao.fichaIncompleta:
        return DottedBorder(
          options: const RoundedRectDottedBorderOptions(
            radius: Radius.circular(20),
            dashPattern: [4, 3],
            color: Cores.cinza,
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          ),
          child: Text('Ficha incompleta', style: estiloTexto.copyWith(color: Cores.cinza)),
        );
    }
  }

  Widget _pilula(Color fundo, Widget conteudo) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: fundo, borderRadius: BorderRadius.circular(20)),
      child: conteudo,
    );
  }
}
