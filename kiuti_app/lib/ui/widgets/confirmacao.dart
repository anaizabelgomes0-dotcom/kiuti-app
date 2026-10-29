import 'package:flutter/material.dart';

import 'package:kiuti_app/theme/cores.dart';
import 'package:kiuti_app/theme/tema.dart';
import 'logo_kiuti.dart';

/// Confirmação com o mascote e o botão vermelho (excluir insumo, excluir produto). Devolve true se confirmou.
Future<bool> confirmarExclusao(
  BuildContext context, {
  required String titulo,
  required String texto,
  required String textoBotao,
  Widget? extra,
}) async {
  final confirmou = await showDialog<bool>(
    context: context,
    builder: (ctx) => Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Mascote(pose: Pose.cuidado),
            const SizedBox(height: 16),
            Text(titulo, style: fredoka(tamanho: 22), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(texto, textAlign: TextAlign.center),
            if (extra != null) ...[const SizedBox(height: 16), extra],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                onPressed: () => Navigator.pop(ctx, true),
                style: FilledButton.styleFrom(backgroundColor: Cores.vermelho, shape: const StadiumBorder()),
                icon: const Icon(Icons.delete_outline),
                label: Text(textoBotao),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(ctx, false),
                style: OutlinedButton.styleFrom(foregroundColor: Cores.preto, shape: const StadiumBorder()),
                child: const Text('Cancelar'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
  return confirmou == true;
}

/// Mensagem com "Desfazer". [onConfirmar] roda quando a barra some sem o toque (aí a exclusão vale);
/// [onDesfazer] roda se tocou. Recebe o messenger porque a tela de origem pode já ter fechado.
void avisarComDesfazer(
  ScaffoldMessengerState messenger,
  String mensagem, {
  required VoidCallback onDesfazer,
  required Future<void> Function() onConfirmar,
}) {
  messenger.clearSnackBars(); // a barra anterior fecha e confirma a exclusão dela
  messenger
      .showSnackBar(
        SnackBar(
          content: Text(mensagem),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(label: 'Desfazer', onPressed: onDesfazer),
        ),
      )
      .closed
      .then((motivo) {
    if (motivo != SnackBarClosedReason.action) onConfirmar();
  });
}

/// Mensagem curta no rodapé da tela.
void avisar(BuildContext context, String mensagem) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensagem)));
}
