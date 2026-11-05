# Ajustes diversos — 2026-11-05

**Status:** design aceito em 2026-11-05 e implementado. Ícone: ficou o **atual** (gata em fundo branco), só o nome mudou para "Kiuti APP".
**Design:** https://claude.ai/artifact/QH8JcwDhEyRuLN9W3hQsPJ

## 1. Pedido

1. **Listas de Produtos e Insumos mais legíveis:** fundo branco, itens levemente separados e borda parecida com a do botão de importação. A Composição da ficha também fica com fundo branco, mas mantém a separação dos itens que já existe.
2. **Ícone do app**, com o nome **Kiuti APP**. A ideia é apresentada no artefato.
3. **Painel de Reajustes mais legível:** o novo preço sugerido em vermelho dá ideia de prejuízo. O fundo rosa passa a branco e o rótulo do novo preço ganha o rosa.
4. **Botões mais altos**, na altura da faixa "Novo preço sugerido": Marcar como atualizado na Shopee, Salvar configurações, Sair da conta, Excluir, Adicionar insumo etc. Hoje são difíceis de tocar em telas pequenas.
5. **Nomes de produto ocupando até 3 linhas** em telas pequenas. Qual abordagem resolve?

## 2. Validação de design

| # | Mudança | Parecer | Princípio |
|---|---|---|---|
| 1 | Fundo branco e itens separados por borda | **Aprovado**, com um ajuste na cor da borda | Proximidade/região comum (Gestalt): cada item vira um bloco e um alvo de toque claro. |
| 1a | Cor da borda | Ajustado: `Cores.borda` (#F0C9DA), 1px, raio 16, 8px entre os itens | Hierarquia: uma borda preta como a do botão faria cada item parecer um botão e competiria com as ações de verdade. O rosa-borda é a mesma cor dos campos, então mantém a consistência. |
| 1b | Composição com fundo branco e divisores | **Aprovado** | A composição é uma conta (itens → custo total) e não uma lista de itens soltos, então continua num cartão só, com divisores finos entre as linhas. |
| 3a | Tirar o vermelho do preço sugerido | **Aprovado** | Semântica de cor: vermelho = perda/erro. O preço sugerido é a *solução*. O vermelho fica só no "lucro agora", que é o problema. Isso muda a regra do Manual registrada em `cores.dart` ("vermelho SÓ no preço sugerido…"). |
| 3b | Rótulo do novo preço em rosa | **Ajustado** | Contraste: texto #F6D1E2 sobre branco dá ~1,3:1 (o WCAG AA exige 4,5:1). O rosa vai no **fundo** da faixa, com rótulo e preço em preto (~17:1). O destaque rosa continua, e o texto fica legível. |
| 3c | Cartão branco no Reajustes | **Aprovado** | Menos ruído de fundo: o único bloco colorido do cartão passa a ser a faixa do preço, que é o que importa. |
| 4 | Botões com 52px de altura | **Aprovado** | Alvo de toque: acima do mínimo de 48dp do Material e de 44pt da Apple (Lei de Fitts). Iguala a altura do `BotaoPrincipal`, que já tem 52. Vale para botões de contorno, de texto e dos diálogos. A regra fica no tema, num lugar só. |

## 3. Nomes longos (item 5)

**Recomendação:**
- O título ocupa a **largura toda** da linha, com **no máximo 2 linhas** e reticências (…).
- O selo de situação ("Abaixo da meta", "Ficha incompleta") **desce para a linha de preço e lucro**. Hoje ele fica à direita e tira ~35% da largura do título, e é isso que joga o nome para 3 linhas.
- O nome completo continua visível no topo da ficha, ao tocar no item.

**Descartado:** um campo "nome curto". Exigiria mudar o banco e a API, e a usuária teria que manter dois nomes.

## 4. Ícone — Kiuti APP

No artefato, artboard "Ícone · Kiuti APP", o ícone atual (rosto da gata em fundo **branco**) aparece ao lado de 3 conceitos, cada um em tamanho grande e em tamanho real na tela inicial, com fundo claro e escuro:

- **A · Gata no rosa (recomendado):** o mesmo desenho, com o fundo rosa da marca. O fundo branco some em papéis de parede claros, e o rosa dá identidade. Mantém a continuidade com o mascote. Para implementar, basta trocar `ic_launcher_background` em `values/colors.xml`.
- **B · Etiqueta-gata:** etiqueta de preço rosa com orelhas, em fundo preto. Comunica "preço", mas perde o mascote.
- **C · Monograma K:** a letra K com orelhas, em fundo rosa. É a mais simples, porém a menos afetiva.

Depois da escolha:
- os mipmaps são gerados em `kiuti_app/android/app/src/main/res/mipmap-*`, nas mesmas pastas do ícone atual;
- `android:label="Kiuti APP"` vai para o `AndroidManifest.xml`.

## 5. Implementação (feita)

- `lib/theme/tema.dart`: altura mínima de 52 em todos os botões (Filled, Outlined e Text).
- `lib/ui/widgets/botoes.dart`: `BotaoContorno` passa a seguir a altura do tema.
- `lib/ui/widgets/cartao_rosa.dart`: o widget ganha a opção de cor e borda.
- `produtos_screen.dart` e `insumos_screen.dart`: um cartão branco com borda por item, com o título em até 2 linhas e o selo embaixo.
- `ficha_screen.dart`: composição em fundo branco, com divisores.
- `reajustes_screen.dart`: cartão branco e faixa rosa com o preço em preto.
- `theme/cores.dart`: atualizar a regra do vermelho.

## 6. Verificação

- `flutter analyze` sem problemas.
- Emulador de 360×640: nomes com no máximo 2 linhas, botões com 52px, preço sugerido sem vermelho.
- Build do APK: conferir o ícone e o nome "Kiuti APP" no launcher.
