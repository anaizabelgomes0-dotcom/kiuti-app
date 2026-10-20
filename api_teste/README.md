# API de teste

Uma imitação da API do Kiuti para o Flutter testar as telas enquanto a API real não fica pronta. Tem as mesmas rotas e
o mesmo JSON do contrato (`Incrementos/00-mvp/contrato-api.md` na documentação). Os dados ficam em memória e **voltam
ao início toda vez que ela reinicia**. Por que ela existe: alinhamento de 20/10 (`Alinhamento/2026-10-20_api_de_teste_flutter.md`).

## Subir

Precisa do Python 3.10 ou mais novo (`python --version`).

Dê **dois cliques em `subir.bat`**. Na primeira vez ele cria o `.venv` e instala o FastAPI. Para parar, feche a
janela. Pelo terminal:

```powershell
cd api_teste
python -m venv .venv
.venv\Scripts\python -m pip install -r requirements.txt
.venv\Scripts\python main.py
```

Ela sobe em `http://localhost:8000`. Para testar as rotas sem o app, use o Swagger em
[localhost:8000/docs](http://localhost:8000/docs): rode o `POST /auth/login`, copie o `access_token` e cole no botão
**Authorize**.

## Usar no app

Nada muda no app: o `lib/config.dart` já aponta para `http://10.0.2.2:8000`, que é o PC visto de dentro do emulador.
Em outros lugares, troque a URL (sem fazer commit da troca):

| App rodando em | `apiUrl` |
|---|---|
| emulador Android | `http://10.0.2.2:8000` (o padrão) |
| Chrome (`flutter run -d chrome`) ou Windows | `http://127.0.0.1:8000` |
| celular de verdade no mesmo Wi-Fi | `http://<IP do PC>:8000` (a API de teste já ouve em `0.0.0.0`) |

O CORS está liberado, então o Chrome não barra as requisições.

**Login:** `keila` / `kiuti123`. O token é fixo e não vence.

## Dados iniciais

Os do cenário de referência:

| | |
|---|---|
| Configurações | taxa de 20% + R$ 4,00, margem de 100%, embalagem R$ 1,50, brinde R$ 0,50, envio e despesas R$ 0 |
| Insumos | Resina epóxi (500 g por R$ 60), Gancho (100 un por R$ 15), Flor seca (50 un por R$ 20), Cartela (100 un por R$ 12) |
| Brinco Flor de Resina | R$ 15,45, ficha completa: **na meta**, custo R$ 4,18 e sugerido R$ 15,50 |
| Colar Gota de Resina | R$ 10,00, 10 g de resina e 1 cartela: **abaixo da meta**, sugerido R$ 13,30 (aparece nos Reajustes) |
| Pulseira Miçanga | R$ 12,90, sem ficha: **ficha incompleta** |

Para ver o Brinco ir para os reajustes, mude o custo da Resina para R$ 78. Ele passa a sugerir R$ 16,20.

## O que ela faz e o que não faz

- **Faz:** todas as rotas do contrato, o cálculo de preço da ADR 001 e os erros que as telas mostram. São eles: 401
  (sem login), 404, 422 com `campo` (RN15), 409 de nome repetido (RN26), insumo em uso (RN11), insumo que já está na
  ficha e marcar como atualizado sem ficha (RN08).
- **Não faz:** banco, JWT de verdade e dados que sobrevivem a um reinício.

Mudou o contrato? Mude o `main.py` no mesmo PR.
