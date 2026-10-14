import 'package:flutter/material.dart';

class LogoKiuti extends StatelessWidget {
  final double largura;

  const LogoKiuti({
    super.key,
    this.largura = 150,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/logo.png',
      width: largura,
      fit: BoxFit.contain,
      errorBuilder: (context, erro, stackTrace) {
        return Text(
          'Kiuti',
          style: TextStyle(
            fontSize: largura * 0.25,
            fontWeight: FontWeight.bold,
          ),
        );
      },
    );
  }
}

class MascoteKiuti extends StatelessWidget {
  final double tamanho;

  const MascoteKiuti({
    super.key,
    this.tamanho = 100,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: tamanho,
      height: tamanho,
      decoration: const BoxDecoration(
        color: Color(0xFFFCE4EC),
        shape: BoxShape.circle,
      ),
      padding: const EdgeInsets.all(12),
      child: Image.asset(
        'assets/mascote.png',
        fit: BoxFit.contain,
        errorBuilder: (context, erro, stackTrace) {
          return const Icon(
            Icons.favorite,
            color: Color(0xFFD9534F),
            size: 40,
          );
        },
      ),
    );
  }
}