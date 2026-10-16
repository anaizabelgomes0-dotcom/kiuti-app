import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kiuti_app/providers/configuracao_provider.dart';
import 'package:kiuti_app/providers/ficha_provider.dart';
import 'package:kiuti_app/providers/insumos_provider.dart';
import 'package:kiuti_app/providers/produtos_provider.dart';
import 'package:kiuti_app/providers/reajustes_provider.dart';
import 'package:kiuti_app/providers/sessao_provider.dart';
import 'package:kiuti_app/router.dart';
import 'package:kiuti_app/services/api.dart';
import 'package:kiuti_app/services/auth_service.dart';
import 'package:kiuti_app/services/configuracao_service.dart';
import 'package:kiuti_app/services/insumo_service.dart';
import 'package:kiuti_app/services/item_service.dart';
import 'package:kiuti_app/services/produto_service.dart';
import 'package:kiuti_app/services/reajuste_service.dart';
import 'package:kiuti_app/theme/tema.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // necessário antes de ler o armazenamento seguro
  final sessao = SessaoProvider();
  await sessao.carregar(); // já tem token guardado? Então abre direto nas abas.
  runApp(KiutiApp(sessao: sessao, rotas: criarRotas(sessao)));
}

class KiutiApp extends StatelessWidget {
  const KiutiApp({super.key, required this.sessao, required this.rotas});

  final SessaoProvider sessao;
  final GoRouter rotas;

  @override
  Widget build(BuildContext context) {
    // Injeção de dependência: cada peça é criada uma vez aqui e pega o que precisa com context.read.
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SessaoProvider>.value(value: sessao),
        Provider<Dio>(create: (_) => criarDio(sessao)),
        // Services: recebem o Dio.
        Provider<AuthService>(create: (context) => AuthService(context.read<Dio>(), sessao)),
        Provider<ConfiguracaoService>(create: (context) => ConfiguracaoService(context.read<Dio>())),
        Provider<InsumoService>(create: (context) => InsumoService(context.read<Dio>())),
        Provider<ProdutoService>(create: (context) => ProdutoService(context.read<Dio>())),
        Provider<ItemService>(create: (context) => ItemService(context.read<Dio>())),
        Provider<ReajusteService>(create: (context) => ReajusteService(context.read<Dio>())),
        // Providers: recebem os services e guardam o estado das telas.
        ChangeNotifierProvider<ConfiguracaoProvider>(
          create: (context) => ConfiguracaoProvider(context.read<ConfiguracaoService>()),
        ),
        ChangeNotifierProvider<InsumosProvider>(
          create: (context) => InsumosProvider(context.read<InsumoService>()),
        ),
        ChangeNotifierProvider<ProdutosProvider>(
          create: (context) => ProdutosProvider(context.read<ProdutoService>()),
        ),
        ChangeNotifierProvider<FichaProvider>(
          create: (context) => FichaProvider(context.read<ProdutoService>(), context.read<ItemService>()),
        ),
        ChangeNotifierProvider<ReajustesProvider>(
          create: (context) => ReajustesProvider(context.read<ReajusteService>()),
        ),
      ],
      child: MaterialApp.router(
        title: 'Kiuti',
        debugShowCheckedModeBanner: false,
        theme: criarTema(),
        routerConfig: rotas,
      ),
    );
  }
}
