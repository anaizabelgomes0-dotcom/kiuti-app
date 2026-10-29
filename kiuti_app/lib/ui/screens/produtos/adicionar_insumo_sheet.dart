import 'package:flutter/material.dart';
import 'package:kiuti_app/ui/widgets/campo_busca.dart';
import 'package:go_router/go_router.dart';
import 'package:kiuti_app/models/insumo.dart';
import 'package:kiuti_app/models/produto.dart';
import 'package:kiuti_app/providers/ficha_provider.dart';
import 'package:kiuti_app/providers/insumos_provider.dart';
import 'package:kiuti_app/services/api_exception.dart';
import 'package:kiuti_app/theme/cores.dart';
import 'package:kiuti_app/theme/tema.dart';
import 'package:kiuti_app/ui/widgets/botoes.dart';
import 'package:kiuti_app/ui/widgets/campo.dart';
import 'package:kiuti_app/ui/widgets/formatos.dart';
import 'package:provider/provider.dart';

/// Folha "Adicionar insumo": escolher o insumo, informar a quantidade e ver o novo custo total.
class AdicionarInsumoSheet extends StatefulWidget {
  const AdicionarInsumoSheet({super.key});

  @override
  State<AdicionarInsumoSheet> createState() => _AdicionarInsumoSheetState();
}

class _AdicionarInsumoSheetState extends State<AdicionarInsumoSheet> {
  final _qtde = TextEditingController();
  Insumo? _escolhido;
  String? _erroQtde;
  String _busca = '';
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    // Depois do primeiro desenho: chamar o provider durante o build da tela dá erro.
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<InsumosProvider>().carregar());
  }

  @override
  void dispose() {
    _qtde.dispose();
    super.dispose();
  }

  Future<void> _cadastrarNovo() async {
    final insumos = context.read<InsumosProvider>();
    final antes = {for (final insumo in insumos.insumos) insumo.idInsumo};
    final mudou = await context.push<bool>('/insumos/novo');
    if (mudou != true || !mounted) return;
    // O provider já recarregou a lista ao salvar. O insumo que não estava antes é o novo: já deixa escolhido.
    final novos = insumos.insumos.where((insumo) => !antes.contains(insumo.idInsumo));
    if (novos.isNotEmpty) setState(() => _escolhido = novos.first);
  }

  Future<void> _adicionar() async {
    final qtde = lerNumero(_qtde.text);
    if (qtde == null || qtde <= 0) {
      setState(() => _erroQtde = 'Precisa ser maior que zero.');
      return;
    }
    setState(() {
      _salvando = true;
      _erroQtde = null;
    });
    try {
      await context.read<FichaProvider>().adicionarItem(idInsumo: _escolhido!.idInsumo, qtde: qtde);
      if (!mounted) return;
      Navigator.pop(context); // fecha a folha; a ficha já recarregou
    } on ApiException catch (e) {
      if (mounted) setState(() => _erroQtde = e.mensagem);
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ficha = context.watch<FichaProvider>();
    final insumos = context.watch<InsumosProvider>();
    final idsNaFicha = {for (final item in ficha.itens) item.idInsumo}; // aparecem desativados
    final escolhido = _escolhido;
    final qtde = lerNumero(_qtde.text);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: Text('Adicionar insumo', style: fredoka(tamanho: 22))),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
            ],
          ),
          const SizedBox(height: 8),
          if (insumos.carregando)
            const Center(child: CircularProgressIndicator())
          else if (insumos.erro != null)
            Text(insumos.erro!, style: const TextStyle(color: Cores.vermelho))
          else ...[
            CampoBusca(dica: 'Buscar insumo', aoMudar: (v) => setState(() => _busca = v)),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 260), // a lista rola dentro desse espaço
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final insumo in insumos.insumos.where((i) => combinaComBusca(i.nome, _busca)))
                    _OpcaoInsumo(
                      insumo: insumo,
                      jaNaFicha: idsNaFicha.contains(insumo.idInsumo),
                      escolhido: escolhido?.idInsumo == insumo.idInsumo,
                      aoTocar: () => setState(() => _escolhido = insumo),
                    ),
                ],
              ),
            ),
          ],
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: _cadastrarNovo,
              style: TextButton.styleFrom(foregroundColor: Cores.vermelho),
              icon: const Icon(Icons.add),
              label: const Text('Cadastrar novo insumo'),
            ),
          ),
          if (escolhido != null) ...[
            Campo(
              controller: _qtde,
              rotulo: 'Quantidade usada no produto',
              numero: true,
              sufixo: escolhido.unidadeCompra, // RN03: a unidade de compra do insumo
              erro: _erroQtde,
              aoMudar: (_) => setState(() {}),
            ),
            if (qtde != null && qtde > 0) ...[
              const SizedBox(height: 12),
              _Previa(produto: ficha.produto!, insumo: escolhido, qtde: qtde),
            ],
          ],
          const SizedBox(height: 16),
          BotaoPrincipal(
            texto: 'Adicionar à ficha',
            carregando: _salvando,
            aoTocar: escolhido == null ? null : _adicionar,
          ),
        ],
      ),
    );
  }
}

/// Um insumo da lista. Os que já estão na ficha ficam desativados.
class _OpcaoInsumo extends StatelessWidget {
  const _OpcaoInsumo({
    required this.insumo,
    required this.jaNaFicha,
    required this.escolhido,
    required this.aoTocar,
  });

  final Insumo insumo;
  final bool jaNaFicha;
  final bool escolhido;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: escolhido ? Cores.rosaClaro : Colors.white,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: escolhido ? Cores.preto : Cores.borda, width: escolhido ? 2 : 1),
        ),
        child: ListTile(
          enabled: !jaNaFicha,
          onTap: jaNaFicha ? null : aoTocar,
          title: Text(insumo.nome),
          subtitle: Text('${formatarReaisUnitario(insumo.custoUnitario)} por ${insumo.unidadeCompra}'),
          trailing: jaNaFicha
              ? const Text('já na ficha', style: TextStyle(fontSize: 12))
              : escolhido
                  ? const Icon(Icons.check_circle, color: Cores.preto)
                  : null,
        ),
      ),
    );
  }
}

/// "0,5 g × R$ 0,80 = R$ 0,40" e "Custo total do produto R$ 4,18 → R$ 4,58".
class _Previa extends StatelessWidget {
  const _Previa({required this.produto, required this.insumo, required this.qtde});

  final Produto produto;
  final Insumo insumo;
  final double qtde;

  @override
  Widget build(BuildContext context) {
    final custoItem = qtde * insumo.custoUnitario;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Cores.rosa, borderRadius: BorderRadius.circular(14)),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${formatarNumero(qtde)} ${insumo.unidadeCompra} × ${formatarReaisUnitario(insumo.custoUnitario)}',
                ),
              ),
              Text(formatarReais(custoItem), style: const TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Expanded(child: Text('Custo total do produto')),
              Text('${formatarReais(produto.custoTotal)} → ${formatarReais(produto.custoTotal + custoItem)}'),
            ],
          ),
        ],
      ),
    );
  }
}