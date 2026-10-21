import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kiuti_app/providers/sessao_provider.dart';
import 'package:kiuti_app/ui/screens/home_screen.dart';
import 'package:kiuti_app/ui/screens/login_screen.dart';
import 'package:kiuti_app/ui/screens/configuracoes/configuracoes_screen.dart';
import 'package:kiuti_app/ui/screens/produtos/produtos_screen.dart';
import 'package:kiuti_app/ui/screens/produtos/ficha_screen.dart';
import 'package:kiuti_app/ui/screens/insumos/insumos_screen.dart';
import 'package:kiuti_app/ui/screens/insumos/insumo_form_screen.dart';
import 'package:kiuti_app/models/insumo.dart';
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
            builder: (context, state) => const ProdutosScreen(),
          ),
          GoRoute(
            path: '/insumos',
            builder: (context, state) => const InsumosScreen(),
          ),
          GoRoute(
            path: '/reajustes',
            builder: (context, state) => const Center(child: Text('Reajustes: em construção (I0-FL-20)')),
          ),
          GoRoute(
            path: '/configuracoes',
            builder: (context, state) => const ConfiguracoesScreen(),
          ),
          GoRoute(
           path: '/produtos/:id',
          builder: (context, state) => FichaScreen(idProduto: int.parse(state.pathParameters['id']!)),
),
        ],
      ),
      
      GoRoute(path: '/insumos/novo', builder: (context, state) => const InsumoFormScreen()),
      GoRoute(
        path: '/insumos/editar',
        builder: (context, state) => InsumoFormScreen(insumo: state.extra as Insumo),
      ),

      // Telas que abrem por cima das abas (com context.push). Cada tarefa acrescenta a sua aqui.
    ],
  );
}
