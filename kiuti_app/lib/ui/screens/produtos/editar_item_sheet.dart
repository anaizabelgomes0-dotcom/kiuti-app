import 'package:flutter/material.dart';
import 'package:kiuti_app/models/item_ficha.dart';
import 'package:kiuti_app/providers/ficha_provider.dart';
import 'package:kiuti_app/services/api_exception.dart';
import 'package:kiuti_app/theme/cores.dart';
import 'package:kiuti_app/theme/tema.dart';
import 'package:kiuti_app/ui/widgets/botoes.dart';
import 'package:kiuti_app/ui/widgets/formatos.dart';
import 'package:provider/provider.dart';

/// Folha "Editar ou remover": muda a quantidade do insumo neste produto ou tira ele da ficha.
class EditarItemSheet extends StatefulWidget {
  const EditarItemSheet({super.key, required this.item});

  final ItemFicha item;

  @override
  State<EditarItemSheet> createState() => _EditarItemSheetState();
}

class _EditarItemSheetState extends State<EditarItemSheet> {
  late final _qtde = TextEditingController(text: formatarNumero(widget.item.qtde));
  String? _erro;
  bool _salvando = false;

  @override
  void dispose() {
    _qtde.dispose();
    super.dispose();
  }

  /// Botões − e +: somam ou tiram 1, sem deixar chegar a zero.
  void _somar(double delta) {
    final novo = (lerNumero(_qtde.text) ?? 0) + delta;
    if (novo <= 0) return;
    setState(() => _qtde.text = formatarNumero(novo));
  }

  Future<void> _salvar() async {
    final qtde = lerNumero(_qtde.text);
    if (qtde == null || qtde <= 0) {
      setState(() => _erro = 'Precisa ser maior que zero.');
      return;
    }
    final ficha = context.read<FichaProvider>();
    await _executar(() => ficha.mudarQuantidade(widget.item, qtde));
  }

  Future<void> _remover() {
    final ficha = context.read<FichaProvider>();
    return _executar(() => ficha.removerItem(widget.item));
  }

  Future<void> _executar(Future<void> Function() acao) async {
    setState(() {
      _salvando = true;
      _erro = null;
    });
    try {
      await acao();
      if (!mounted) return;
      Navigator.pop(context); // fecha a folha; a ficha já recarregou
    } on ApiException catch (e) {
      if (mounted) setState(() => _erro = e.mensagem);
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final produto = context.watch<FichaProvider>().produto!;
    final item = widget.item;
    final qtde = lerNumero(_qtde.text);
    final unitario = formatarReaisUnitario(item.custoUnitario);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.nomeInsumo, style: fredoka(tamanho: 22)),
                    Text(
                      'No ${produto.nome} · $unitario por ${item.unidadeCompra}',
                      style: const TextStyle(color: Cores.cinza),
                    ),
                  ],
                ),
              ),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
            ],
          ),
          const SizedBox(height: 16),
          Text('Quantidade usada no produto (${item.unidadeCompra})', style: const TextStyle(fontSize: 13)),
          const SizedBox(height: 6),
          Row(
            children: [
              IconButton.outlined(icon: const Icon(Icons.remove), onPressed: () => _somar(-1)),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _qtde,
                  textAlign: TextAlign.center,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(isDense: true, errorText: _erro),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.outlined(icon: const Icon(Icons.add), onPressed: () => _somar(1)),
            ],
          ),
          if (qtde != null && qtde > 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Cores.rosa, borderRadius: BorderRadius.circular(14)),
              child: Row(
                children: [
                  Expanded(child: Text('${formatarNumero(qtde)} ${item.unidadeCompra} × $unitario')),
                  Text(formatarReais(qtde * item.custoUnitario), style: const TextStyle(fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          BotaoPrincipal(texto: 'Salvar quantidade', carregando: _salvando, aoTocar: _salvar),
          const Divider(height: 32),
          BotaoContorno(
            texto: 'Remover da ficha',
            icone: Icons.delete_outline,
            cor: Cores.vermelho,
            aoTocar: _salvando ? null : _remover,
          ),
          const SizedBox(height: 8),
          Text(
            'O insumo continua cadastrado. Ele só sai deste produto, e o custo total cai para '
            '${formatarReais(produto.custoTotal - item.custoItem)}.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Cores.cinza),
          ),
        ],
      ),
    );
  }
}
