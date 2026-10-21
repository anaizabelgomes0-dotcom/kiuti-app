import 'package:flutter/material.dart';
import 'package:kiuti_app/models/insumo.dart';
import 'package:kiuti_app/providers/insumos_provider.dart';
import 'package:kiuti_app/theme/cores.dart';
import 'package:kiuti_app/theme/tema.dart';
import 'package:kiuti_app/ui/widgets/cabecalho_aba.dart';
import 'package:kiuti_app/ui/widgets/cartao_rosa.dart';
// import 'package:kiuti_app/ui/widgets/confirmacao.dart';
import 'package:kiuti_app/ui/widgets/estados.dart';
import 'package:kiuti_app/ui/widgets/formatos.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class InsumosScreen extends StatefulWidget {
  const InsumosScreen({super.key});

  @override
  State<InsumosScreen> createState() => _InsumosScreenState();
}

class _InsumosScreenState extends State<InsumosScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<InsumosProvider>().carregar());
  }

  void _abrir([Insumo? insumo]) {
  if (insumo == null) {
    context.push('/insumos/novo');
  } else {
    context.push('/insumos/editar', extra: insumo);
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrir(),
        backgroundColor: Cores.preto,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Novo insumo'),
      ),
      body: Consumer<InsumosProvider>(
        builder: (context, provider, child) {
          if (provider.carregando) return const Center(child: CircularProgressIndicator());
          if (provider.erro != null) return ErroComTentar(mensagem: provider.erro!, aoTentar: provider.carregar);

          final insumos = provider.insumos;
          final total = insumos.length;
          return RefreshIndicator(
            onRefresh: provider.carregar,
            child: ListView(
              padding: const EdgeInsets.only(bottom: 96), // espaço para o botão flutuante
              children: [
                CabecalhoAba(
                  titulo: 'Insumos',
                  direita: Text('$total insumo${total == 1 ? '' : 's'}', style: const TextStyle(color: Cores.cinza)),
                ),
                if (insumos.isEmpty)
                  const EstadoVazio(
                    titulo: 'Nenhum insumo ainda',
                    texto: 'Cadastre do jeito que você compra: "500 g por R\$ 60,00".',
                  )
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: CartaoRosa(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          for (final insumo in insumos) _LinhaInsumo(insumo: insumo, aoTocar: () => _abrir(insumo)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _LinhaInsumo extends StatelessWidget {
  const _LinhaInsumo({required this.insumo, required this.aoTocar});

  final Insumo insumo;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    final n = insumo.qtdProdutos;
    final uso = n == 0 ? 'sem uso' : '$n produto${n == 1 ? '' : 's'}';
    return ListTile(
      onTap: aoTocar,
      title: Text(insumo.nome, style: fredoka(tamanho: 16, peso: FontWeight.w500)),
      subtitle: Text(
        '${formatarNumero(insumo.qtdeCompra)} ${insumo.unidadeCompra} por ${formatarReais(insumo.custo)} · $uso',
      ),
      trailing: Text(
        '${formatarReaisUnitario(insumo.custoUnitario)}/${insumo.unidadeCompra}',
        style: fredoka(tamanho: 16),
      ),
    );
  }
}