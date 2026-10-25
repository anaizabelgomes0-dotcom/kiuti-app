import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kiuti_app/models/insumo.dart';
import 'package:kiuti_app/models/produto_uso.dart';
import 'package:kiuti_app/theme/cores.dart';
import 'package:kiuti_app/theme/tema.dart';
import 'package:kiuti_app/ui/widgets/botoes.dart';
import 'package:kiuti_app/ui/widgets/cartao_rosa.dart';
import 'package:kiuti_app/ui/widgets/formatos.dart';
import 'package:kiuti_app/ui/widgets/logo_kiuti.dart';

/// RN11: o insumo está em fichas e não pode ser excluído. Mostra os produtos, com atalho para cada ficha.
Future<void> mostrarInsumoEmUso(
  BuildContext context, {
  required Insumo insumo,
  required List<ProdutoUso> produtos,
}) {
  final n = produtos.length;
  return showDialog<void>(
    context: context,
    builder: (ctx) => Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Mascote(),
            const SizedBox(height: 16),
            Text('${insumo.nome} está em uso', style: fredoka(tamanho: 22), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              'Ele está na ficha de $n produto${n == 1 ? '' : 's'}. Tire-o dessas fichas antes de excluir, '
              'para o custo deles não ficar menor que o real.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            CartaoRosa(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  for (final produto in produtos)
                    ListTile(
                      title: Text(produto.nome, style: fredoka(tamanho: 15, peso: FontWeight.w500)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('${formatarNumero(produto.qtde)} ${insumo.unidadeCompra}'),
                          const Icon(Icons.chevron_right),
                        ],
                      ),
                      onTap: () {
                        Navigator.pop(ctx); // fecha o aviso
                        context.push('/produtos/${produto.idProduto}'); // abre a ficha
                      },
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Mudou só o preço ou o fornecedor? Não precisa excluir: é só atualizar o insumo.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Cores.cinza),
            ),
            const SizedBox(height: 16),
            BotaoPrincipal(texto: 'Entendi', aoTocar: () => Navigator.pop(ctx)),
          ],
        ),
      ),
    ),
  );
}