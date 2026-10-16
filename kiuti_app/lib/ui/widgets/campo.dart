import 'package:flutter/material.dart';

/// Campo de formulário com o rótulo em cima, como no protótipo. O erro aparece embaixo, em vermelho.
class Campo extends StatelessWidget {
  const Campo({
    super.key,
    required this.controller,
    required this.rotulo,
    this.numero = false,
    this.erro,
    this.dica,
    this.sufixo,
    this.ajuda,
    this.aoMudar,
  });

  final TextEditingController controller;
  final String rotulo;
  final bool numero; // true: teclado numérico com vírgula
  final String? erro; // texto vermelho embaixo
  final String? dica; // texto cinza dentro do campo vazio ("0,50 · padrão")
  final String? sufixo; // unidade no fim do campo ("g", "%")
  final String? ajuda; // texto cinza embaixo ("Padrão: 1,50")
  final ValueChanged<String>? aoMudar;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(rotulo, style: const TextStyle(fontSize: 13)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: numero ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
          onChanged: aoMudar,
          decoration: InputDecoration(
            hintText: dica,
            suffixText: sufixo,
            helperText: ajuda,
            errorText: erro,
            errorMaxLines: 2,
            isDense: true,
          ),
        ),
      ],
    );
  }
}
