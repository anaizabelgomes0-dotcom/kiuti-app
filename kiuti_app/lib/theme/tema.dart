import 'package:flutter/material.dart';

import 'cores.dart';

/// Fredoka nos títulos, preços e botões; DM Sans nos textos.
TextStyle fredoka({double tamanho = 16, FontWeight peso = FontWeight.w600, Color cor = Cores.preto}) =>
    TextStyle(fontFamily: 'Fredoka', fontSize: tamanho, fontWeight: peso, color: cor);

ThemeData criarTema() {
  final borda = OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: const BorderSide(color: Cores.borda),
  );
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Cores.rosa,
      primary: Cores.preto,
      error: Cores.vermelho,
      surface: Colors.white,
    ),
    scaffoldBackgroundColor: Colors.white,
    textTheme: Typography.material2021().black.apply(fontFamily: 'DMSans').copyWith(
      headlineMedium: fredoka(tamanho: 30),
      titleLarge: fredoka(tamanho: 22),
      titleMedium: fredoka(tamanho: 17, peso: FontWeight.w500),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 0,
      titleTextStyle: fredoka(tamanho: 24),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: borda,
      enabledBorder: borda,
      focusedBorder: borda.copyWith(borderSide: const BorderSide(color: Cores.preto, width: 1.5)),
    ),
  );
}
