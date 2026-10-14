import 'package:flutter/material.dart';

Future<bool?> confirmarExclusao(
  BuildContext context, {
  required String titulo,
  required String mensagem,
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(titulo),
      content: Text(mensagem),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text(
            'Excluir',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    ),
  );
}

void avisar(
  BuildContext context,
  String mensagem,
) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(mensagem)),
  );
}