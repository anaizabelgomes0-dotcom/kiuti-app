import 'package:flutter/material.dart';

import 'package:kiuti_app/theme/cores.dart';
import 'package:kiuti_app/theme/tema.dart';

/// Botão preto, largura total (Salvar, Entrar, Adicionar à ficha...).
class BotaoPrincipal extends StatelessWidget {
  const BotaoPrincipal({
    super.key,
    required this.texto,
    required this.aoTocar,
    this.icone,
    this.carregando = false,
  });

  final String texto;
  final VoidCallback? aoTocar; // null deixa o botão desativado
  final IconData? icone;
  final bool carregando;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton(
        onPressed: carregando ? null : aoTocar,
        style: FilledButton.styleFrom(
          backgroundColor: Cores.preto,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Cores.preto.withValues(alpha: 0.4),
          disabledForegroundColor: Colors.white,
          shape: const StadiumBorder(),
          textStyle: fredoka(tamanho: 17, cor: Colors.white),
        ),
        child: carregando
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icone != null) ...[Icon(icone, size: 20), const SizedBox(width: 8)],
                  Flexible(child: Text(texto, overflow: TextOverflow.ellipsis)),
                ],
              ),
      ),
    );
  }
}

/// Botão de contorno (Importar, Exportar, "+ Insumo", Excluir em vermelho...).
class BotaoContorno extends StatelessWidget {
  const BotaoContorno({
    super.key,
    required this.texto,
    required this.aoTocar,
    this.icone,
    this.cor = Cores.preto,
  });

  final String texto;
  final VoidCallback? aoTocar;
  final IconData? icone;
  final Color cor;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: aoTocar,
      style: OutlinedButton.styleFrom(
        foregroundColor: cor,
        side: BorderSide(color: cor),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        textStyle: fredoka(tamanho: 15, cor: cor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icone != null) ...[Icon(icone, size: 18), const SizedBox(width: 6)],
          Text(texto),
        ],
      ),
    );
  }
}
