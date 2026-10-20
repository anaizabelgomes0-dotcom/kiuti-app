import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kiuti_app/providers/sessao_provider.dart';
import 'package:kiuti_app/ui/screens/home_screen.dart';
import 'package:kiuti_app/ui/screens/login_screen.dart';

/// Todas as rotas do app. Sem token, qualquer rota leva ao login; com token, o login leva às abas.
GoRouter criarRotas(SessaoProvider sessao) {
  return GoRouter(
    initialLocation: '/produtos',
    refreshListenable: sessao, // a sessão mudou (entrou, saiu, token venceu): o redirect roda de novo
    redirect: (context, state) {
      final naTelaDeLogin = state.matchedLocation == '/login';
      if (!sessao.logado) return naTelaDeLogin ? null : '/login';
      if (naTelaDeLogin) return '/produtos';
      return null; // segue para onde ia
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),

      // As quatro abas, com a barra embaixo. Trocar de aba cria a tela de novo, e ela busca os dados outra vez.
      ShellRoute(
        builder: (context, state, child) => HomeScreen(child: child),
        routes: [
          GoRoute(
            path: '/produtos',
            builder: (context, state) => const Center(child: Text('Produtos: em construção (I0-FL-12)')),
          ),
          GoRoute(
            path: '/insumos',
            builder: (context, state) => const Center(child: Text('Insumos: em construção (I0-FL-08)')),
          ),
          GoRoute(
            path: '/reajustes',
            builder: (context, state) => const Center(child: Text('Reajustes: em construção (I0-FL-20)')),
          ),
          GoRoute(
            path: '/configuracoes',
            builder: (context, state) => const Center(child: Text('Configurações: em construção (I0-FL-07)')),
          ),
        ],
      ),

      // Telas que abrem por cima das abas (com context.push). Cada tarefa acrescenta a sua aqui.
    ],
  );
}
