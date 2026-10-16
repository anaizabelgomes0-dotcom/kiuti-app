import 'package:flutter/material.dart';

import 'package:kiuti_app/theme/cores.dart';
import 'package:kiuti_app/theme/tema.dart';
import 'botoes.dart';
import 'logo_kiuti.dart';

/// Lista vazia: mascote, título, texto e (opcional) um botão.
class EstadoVazio extends StatelessWidget {
  const EstadoVazio({super.key, required this.titulo, this.texto, this.textoBotao, this.aoTocar});

  final String titulo;
  final String? texto;
  final String? textoBotao;
  final VoidCallback? aoTocar;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Mascote(),
            const SizedBox(height: 16),
            Text(titulo, style: fredoka(tamanho: 20), textAlign: TextAlign.center),
            if (texto != null) ...[
              const SizedBox(height: 8),
              Text(texto!, style: const TextStyle(color: Cores.cinza), textAlign: TextAlign.center),
            ],
            if (textoBotao != null) ...[
              const SizedBox(height: 20),
              BotaoContorno(texto: textoBotao!, aoTocar: aoTocar),
            ],
          ],
        ),
      ),
    );
  }
}

/// Erro ao carregar: mensagem e "Tentar de novo".
class ErroComTentar extends StatelessWidget {
  const ErroComTentar({super.key, required this.mensagem, required this.aoTentar});

  final String mensagem;
  final VoidCallback aoTentar;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 48, color: Cores.cinza),
            const SizedBox(height: 12),
            Text(mensagem, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            BotaoContorno(texto: 'Tentar de novo', icone: Icons.refresh, aoTocar: aoTentar),
          ],
        ),
      ),
    );
  }
}
