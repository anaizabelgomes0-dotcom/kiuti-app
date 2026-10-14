import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:kiuti_app/models/situacao.dart';
import 'package:kiuti_app/theme/cores.dart';

class SeloSituacao extends StatelessWidget {
  final Situacao situacao;

  const SeloSituacao({
    super.key,
    required this.situacao,
  });

  @override
  Widget build(BuildContext context) {
    switch (situacao) {
      case Situacao.abaixoDaMeta:
        return _selo(
          texto: 'Abaixo da meta',
          cor: Cores.vermelho,
          textoCor: Colors.white,
        );

      case Situacao.naMeta:
        return _selo(
          texto: 'Na meta',
          cor: Cores.rosa,
          textoCor: Cores.preto,
          icone: Icons.check,
        );

      case Situacao.fichaIncompleta:
        return DottedBorder(
          options: const RoundedRectDottedBorderOptions(
            color: Colors.grey,
            radius: Radius.circular(20),
            dashPattern: [4, 3],
          ),
          child: const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            child: Text('Incompleta'),
          ),
        );
    }
  }

  Widget _selo({
    required String texto,
    required Color cor,
    required Color textoCor,
    IconData? icone,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: cor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icone != null) ...[
            Icon(icone, size: 16, color: textoCor),
            const SizedBox(width: 4),
          ],
          Text(
            texto,
            style: TextStyle(
              color: textoCor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}