import 'package:flutter/material.dart';

class TelaLogin extends StatefulWidget {
  const TelaLogin({super.key});

  @override
  State<TelaLogin> createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  // Cores tiradas da imagem. Se existirem equivalentes em lib/theme/cores.dart,
  // troque estas constantes por elas.
  static const _rosaCartao = Color(0xFFFDEEF3);
  static const _rosaBorda = Color(0xFFEBC9D6);
  static const _preto = Color(0xFF111111);

  final _usuarioController = TextEditingController();
  final _senhaController = TextEditingController();

  @override
  void dispose() {
    _usuarioController.dispose();
    _senhaController.dispose();
    super.dispose();
  }
void _entrar() {
  final usuario = _usuarioController.text.trim();
  final senha = _senhaController.text;

  if (usuario.isEmpty || senha.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Preencha o usuário e a senha.'),
      ),
    );
    return;
  }

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Login ainda não conectado ao servidor.'),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Rolagem + altura mínima da tela: evita overflow em telas pequenas
            // ou com o teclado aberto, e mantém o botão no rodapé em telas altas.
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      Image.asset(
                        'assets/logo.png',
                        width: 140,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Custos, preços e reajustes da sua loja.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 15, color: _preto),
                      ),
                      const SizedBox(height: 32),
                      _cartaoCampos(),
                      const Spacer(),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _entrar,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _preto,
                            foregroundColor: Colors.white,
                            shape: const StadiumBorder(),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Entrar',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Esqueceu a senha? Fale com a equipe do projeto.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: _preto),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _cartaoCampos() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _rosaCartao,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _campo(
            rotulo: 'Usuário',
            controller: _usuarioController,
            acao: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          _campo(
            rotulo: 'Senha',
            controller: _senhaController,
            senha: true,
            acao: TextInputAction.done,
          ),
        ],
      ),
    );
  }

  Widget _campo({
    required String rotulo,
    required TextEditingController controller,
    required TextInputAction acao,
    bool senha = false,
  }) {
    final borda = OutlineInputBorder(
      borderRadius: BorderRadius.circular(28),
      borderSide: const BorderSide(color: _rosaBorda),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(rotulo, style: const TextStyle(fontSize: 13, color: _preto)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: senha,
          textInputAction: acao,
          keyboardType:
              senha ? TextInputType.visiblePassword : TextInputType.text,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            enabledBorder: borda,
            focusedBorder: borda.copyWith(
              borderSide: const BorderSide(color: _preto),
            ),
          ),
        ),
      ],
    );
  }
}