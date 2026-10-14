import 'package:flutter/material.dart';

class Campo extends StatelessWidget {
  final String rotulo;
  final String dica;
  final TextEditingController? controlador;
  final TextInputType tipoTeclado;
  final bool obrigatorio;
  final int maxLinhas;

  const Campo({
    super.key,
    required this.rotulo,
    this.dica = '',
    this.controlador,
    this.tipoTeclado = TextInputType.text,
    this.obrigatorio = false,
    this.maxLinhas = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controlador,
      keyboardType: tipoTeclado,
      maxLines: maxLinhas,
      decoration: InputDecoration(
        labelText: obrigatorio ? '$rotulo *' : rotulo,
        hintText: dica,
        border: const OutlineInputBorder(),
      ),
      validator: (valor) {
        if (obrigatorio &&
            (valor == null || valor.trim().isEmpty)) {
          return 'Preencha este campo';
        }

        return null;
      },
    );
  }
}