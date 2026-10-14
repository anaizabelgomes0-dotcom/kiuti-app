import 'package:flutter/material.dart';
import 'ui/telas/tela_login.dart';

void main() {
  runApp(const KiutiApp());
}

class KiutiApp extends StatelessWidget {
  const KiutiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kiuti',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFFF7F7),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD9534F),
        ),
      ),
      home: const TelaInicial(),
    );
  }
}

class TelaInicial extends StatelessWidget {
  const TelaInicial({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/logo.png',
                  width: 150,
                  height: 150,
                  fit: BoxFit.contain,
                ),

                const SizedBox(height: 28),

                const Text(
                  'Bem-vinda ao Kiuti!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFD9534F),
                  ),
                ),

                const SizedBox(height: 12),

                const Text(
                  'Seu espaço para organizar e acompanhar '
                  'suas metas com carinho.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const TelaLogin(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: const StadiumBorder(),
                    ),
                    child: const Text('Começar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}