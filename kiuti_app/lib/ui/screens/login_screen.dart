import 'package:flutter/material.dart';
import 'package:kiuti_app/services/api_exception.dart';
import 'package:kiuti_app/services/auth_service.dart';
import 'package:kiuti_app/theme/cores.dart';
import 'package:kiuti_app/ui/widgets/botoes.dart';
import 'package:kiuti_app/ui/widgets/cartao_rosa.dart';
import 'package:kiuti_app/ui/widgets/logo_kiuti.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _login = TextEditingController();
  final _senha = TextEditingController();
  bool _mostrarSenha = false;
  bool _entrando = false;
  String? _erro;

  @override
  void dispose() {
    _login.dispose();
    _senha.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    if (_login.text.trim().isEmpty || _senha.text.isEmpty) {
      setState(() => _erro = 'Informe o usuário e a senha.');
      return;
    }
    setState(() {
      _entrando = true;
      _erro = null;
    });
    try {
      // Deu certo: a sessão guarda o token e o go_router troca o login pelas abas sozinho.
      await context.read<AuthService>().entrar(_login.text.trim(), _senha.text);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _erro = e.mensagem); // "Login ou senha incorretos." vem da API
    } finally {
      if (mounted) setState(() => _entrando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 32),
            const Center(child: Mascote(tamanho: 140)),
            const SizedBox(height: 16),
            const Center(child: LogoKiuti(altura: 56)),
            const SizedBox(height: 8),
            const Text('Custos, preços e reajustes da sua loja.', textAlign: TextAlign.center),
            const SizedBox(height: 32),
            CartaoRosa(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Usuário', style: TextStyle(fontSize: 13)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _login,
                    autocorrect: false,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(isDense: true),
                  ),
                  const SizedBox(height: 16),
                  const Text('Senha', style: TextStyle(fontSize: 13)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _senha,
                    obscureText: !_mostrarSenha,
                    onSubmitted: (_) => _entrar(),
                    decoration: InputDecoration(
                      isDense: true,
                      suffixIcon: IconButton(
                        icon: Icon(_mostrarSenha ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _mostrarSenha = !_mostrarSenha),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_erro != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(_erro!, style: const TextStyle(color: Cores.vermelho), textAlign: TextAlign.center),
              ),
            const SizedBox(height: 32),
            BotaoPrincipal(texto: 'Entrar', carregando: _entrando, aoTocar: _entrar),
            const SizedBox(height: 16),
            const Text(
              'Esqueceu a senha? Fale com a equipe do projeto.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Cores.cinza),
            ),
          ],
        ),
      ),
    );
  }
}
