import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kiuti_app/theme/cores.dart';

/// A moldura das abas: a tela da aba atual (child, escolhida pelo go_router) e a barra embaixo.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.child});

  final Widget child;

  static const _abas = ['/produtos', '/insumos', '/reajustes', '/configuracoes'];

  @override
  Widget build(BuildContext context) {
    final caminho = GoRouterState.of(context).uri.path;
    final aba = _abas.indexOf(caminho);
    return Scaffold(
      body: SafeArea(child: child),
      bottomNavigationBar: NavigationBar(
        selectedIndex: aba < 0 ? 0 : aba,
        onDestinationSelected: (i) => context.go(_abas[i]),
        backgroundColor: Colors.white,
        indicatorColor: Cores.rosa,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.sell_outlined), label: 'Produtos'),
          NavigationDestination(icon: Icon(Icons.layers_outlined), label: 'Insumos'),
          NavigationDestination(icon: Icon(Icons.trending_up), label: 'Reajustes'),
          NavigationDestination(icon: Icon(Icons.tune), label: 'Configurações'),
        ],
      ),
    );
  }
}
