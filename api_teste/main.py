"""API de teste do Kiuti, só para o Flutter testar enquanto a API real não fica pronta.

Mesmas rotas e mesmo JSON do contrato (DOCUMENTACAO/Incrementos/00-mvp/contrato-api.md). Os dados ficam em memória e
voltam ao início toda vez que a API reinicia. Login: keila / kiuti123.

Mudou o contrato? Mude este arquivo no mesmo PR (alinhamento de 20/10).
"""

from decimal import ROUND_CEILING, ROUND_HALF_UP, Decimal, InvalidOperation

import uvicorn
from fastapi import APIRouter, Body, Depends, FastAPI
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse, Response
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer

D = Decimal
CENTAVO = D("0.01")
DEZ_CENTAVOS = D("0.1")

USUARIO = {"login": "keila", "senha": "kiuti123"}
TOKEN = "token-de-teste"  # sem JWT: a API de teste aceita só este texto
UNIDADES = ["un", "g", "kg", "m", "cm", "ml", "l", "pct"]

# ---------------------------------------------------------------- dados (cenário de referência, I0-BD-04)

config = {
    "perc_taxa_shopee": D("20"),
    "taxa_fixa_shopee": D("4"),
    "perc_lucro_padrao": D("100"),
    "embalagem_padrao": D("1.5"),
    "envio_padrao": D("0"),
    "brinde_padrao": D("0.5"),
    "despesas_variaveis_padrao": D("0"),
}

insumos = {
    1: {"id_insumo": 1, "nome": "Resina epóxi", "custo": D("60"), "unidade_compra": "g", "qtde_compra": D("500")},
    2: {"id_insumo": 2, "nome": "Gancho", "custo": D("15"), "unidade_compra": "un", "qtde_compra": D("100")},
    3: {"id_insumo": 3, "nome": "Flor seca", "custo": D("20"), "unidade_compra": "un", "qtde_compra": D("50")},
    4: {"id_insumo": 4, "nome": "Cartela", "custo": D("12"), "unidade_compra": "un", "qtde_compra": D("100")},
}


def _produto(id_produto, nome, sku, preco):
    return {
        "id_produto": id_produto,
        "nome": nome,
        "sku_referencia": sku,
        "preco_atual_shopee": D(preco),
        "perc_lucro": None,
        "custo_embalagem": None,
        "custo_envio": None,
        "custo_brinde": None,
        "despesas_variaveis": None,
        "id_produto_shopee": None,
        "ativo": True,
    }


produtos = {
    1: _produto(1, "Brinco Flor de Resina", "BFR-01", "15.45"),  # na meta: sugerido 15,50
    2: _produto(2, "Pulseira Miçanga", None, "12.90"),  # sem ficha: ficha incompleta
    3: _produto(3, "Colar Gota de Resina", None, "10.00"),  # abaixo da meta: aparece nos reajustes
}

itens = {
    1: {"id_item": 1, "id_produto": 1, "id_insumo": 1, "qtde": D("8")},
    2: {"id_item": 2, "id_produto": 1, "id_insumo": 2, "qtde": D("2")},
    3: {"id_item": 3, "id_produto": 1, "id_insumo": 3, "qtde": D("2")},
    4: {"id_item": 4, "id_produto": 1, "id_insumo": 4, "qtde": D("1")},
    5: {"id_item": 5, "id_produto": 3, "id_insumo": 1, "qtde": D("10")},
    6: {"id_item": 6, "id_produto": 3, "id_insumo": 4, "qtde": D("1")},
}

# ---------------------------------------------------------------- erros no formato do contrato


class Erro(Exception):
    def __init__(self, status: int, detail: str, **extra):
        self.status = status
        self.corpo = {"detail": detail, **extra}


app = FastAPI(title="Kiuti — API de teste", description="Dados em memória. Login: keila / kiuti123.")


@app.exception_handler(Erro)
def _erro(_, e: Erro):
    return JSONResponse(e.corpo, status_code=e.status)


@app.exception_handler(RequestValidationError)
def _validacao(_, e: RequestValidationError):
    campo = str(e.errors()[0]["loc"][-1]) if e.errors() else None
    return JSONResponse({"detail": "Dados inválidos.", "campo": campo}, status_code=422)


def achar(tabela: dict, id_: int, nome: str) -> dict:
    if id_ not in tabela:
        raise Erro(404, f"{nome} não encontrado.")
    return tabela[id_]


def novo_id(tabela: dict) -> int:
    return max(tabela, default=0) + 1


# ---------------------------------------------------------------- validação (RN15)


def numero(dados: dict, campo: str, *, maior_que_zero=False, nulo=False) -> Decimal | None:
    valor = dados.get(campo)
    if valor is None:
        if nulo:
            return None
        raise Erro(422, "Informe um valor.", campo=campo)
    if isinstance(valor, bool):
        raise Erro(422, "Deve ser um número.", campo=campo)
    try:
        valor = D(str(valor))
    except InvalidOperation:
        raise Erro(422, "Deve ser um número.", campo=campo)
    if maior_que_zero and valor <= 0:
        raise Erro(422, "Deve ser maior que zero.", campo=campo)
    if valor < 0:
        raise Erro(422, "Não pode ser negativo.", campo=campo)
    return valor


def texto(dados: dict, campo: str, maximo: int, *, nulo=False) -> str | None:
    valor = dados.get(campo)
    if valor is None and nulo:
        return None
    valor = str(valor or "").strip()
    if not valor:
        if nulo:
            return None
        raise Erro(422, "Informe o nome.", campo=campo)
    if len(valor) > maximo:
        raise Erro(422, f"Use no máximo {maximo} caracteres.", campo=campo)
    return valor


# ---------------------------------------------------------------- cálculo (I0-API-05 / ADR 001)

PADRAO_DE = {
    "perc_lucro": "perc_lucro_padrao",
    "custo_embalagem": "embalagem_padrao",
    "custo_envio": "envio_padrao",
    "custo_brinde": "brinde_padrao",
    "despesas_variaveis": "despesas_variaveis_padrao",
}


def f2(valor: Decimal | None) -> float | None:
    return None if valor is None else float(valor.quantize(CENTAVO, rounding=ROUND_HALF_UP))


def custo_unitario(insumo: dict) -> Decimal:
    return insumo["custo"] / insumo["qtde_compra"]


def itens_do_produto(id_produto: int) -> list[dict]:
    return [i for i in itens.values() if i["id_produto"] == id_produto]


def produto_json(p: dict) -> dict:
    efetivos = {c: p[c] if p[c] is not None else config[k] for c, k in PADRAO_DE.items()}  # RN02
    ficha = itens_do_produto(p["id_produto"])
    custo_insumos = sum((custo_unitario(insumos[i["id_insumo"]]) * i["qtde"] for i in ficha), D(0))
    custo_total = custo_insumos + sum(efetivos[c] for c in PADRAO_DE if c != "perc_lucro")

    lucro_meta = preco_sugerido = lucro_atual = None
    situacao = "ficha_incompleta"  # RN04
    if ficha:
        taxa = config["perc_taxa_shopee"] / 100
        taxa_fixa = config["taxa_fixa_shopee"]
        lucro_meta = custo_total * efetivos["perc_lucro"] / 100
        preco_sugerido = ((custo_total + lucro_meta + taxa_fixa) / (1 - taxa)).quantize(
            DEZ_CENTAVOS, rounding=ROUND_CEILING
        )  # RN01
        lucro_atual = p["preco_atual_shopee"] * (1 - taxa) - taxa_fixa - custo_total  # RN05
        situacao = "abaixo_da_meta" if f2(lucro_atual) < f2(lucro_meta) else "na_meta"

    return {
        **{k: float(v) if isinstance(v, Decimal) else v for k, v in p.items()},
        "efetivos": {k: float(v) for k, v in efetivos.items()},
        "custo_insumos": f2(custo_insumos),
        "custo_total": f2(custo_total),
        "lucro_meta": f2(lucro_meta),
        "preco_sugerido": f2(preco_sugerido),
        "lucro_atual": f2(lucro_atual),
        "situacao": situacao,
    }


def produtos_que_usam(id_insumo: int) -> list[dict]:
    usos = [
        {"id_produto": i["id_produto"], "nome": produtos[i["id_produto"]]["nome"], "qtde": float(i["qtde"])}
        for i in itens.values()
        if i["id_insumo"] == id_insumo
    ]
    return sorted(usos, key=lambda u: u["nome"].casefold())


def insumo_json(insumo: dict) -> dict:
    return {
        **insumo,
        "custo": float(insumo["custo"]),
        "qtde_compra": float(insumo["qtde_compra"]),
        "custo_unitario": float(custo_unitario(insumo)),  # sem arredondar
        "qtd_produtos": len(produtos_que_usam(insumo["id_insumo"])),
    }


def item_json(item: dict) -> dict:
    insumo = insumos[item["id_insumo"]]
    return {
        "id_item": item["id_item"],
        "id_insumo": item["id_insumo"],
        "nome_insumo": insumo["nome"],
        "unidade_compra": insumo["unidade_compra"],
        "custo_unitario": float(custo_unitario(insumo)),
        "qtde": float(item["qtde"]),
        "custo_item": f2(custo_unitario(insumo) * item["qtde"]),
    }


def por_nome(lista: list[dict]) -> list[dict]:
    return sorted(lista, key=lambda x: x["nome"].casefold())


# ---------------------------------------------------------------- login

bearer = HTTPBearer(auto_error=False)  # deixa o botão "Authorize" no /docs


def logado(credenciais: HTTPAuthorizationCredentials | None = Depends(bearer)):
    if credenciais is None or credenciais.credentials != TOKEN:
        raise Erro(401, "Faça login para continuar.")


@app.post("/auth/login")
def login(dados: dict = Body(..., examples=[{"login": "keila", "senha": "kiuti123"}])):
    if dados.get("login") != USUARIO["login"] or dados.get("senha") != USUARIO["senha"]:
        raise Erro(401, "Login ou senha incorretos.")
    return {"access_token": TOKEN, "token_type": "bearer"}


rotas = APIRouter(dependencies=[Depends(logado)])

# ---------------------------------------------------------------- configurações


@rotas.get("/configuracoes")
def ler_configuracoes():
    return {k: float(v) for k, v in config.items()}


@rotas.put("/configuracoes")
def salvar_configuracoes(dados: dict = Body(..., examples=[{"perc_lucro_padrao": 120.0}])):
    novos = {}
    for chave in dados:
        if chave not in config:
            raise Erro(422, "Configuração desconhecida.", campo=chave)
        novos[chave] = numero(dados, chave)
    if novos.get("perc_taxa_shopee", 0) >= 100:
        raise Erro(422, "Deve ser menor que 100.", campo="perc_taxa_shopee")
    config.update(novos)
    return ler_configuracoes()


# ---------------------------------------------------------------- insumos


def validar_insumo(dados: dict, id_atual: int | None) -> dict:
    nome = texto(dados, "nome", 60)
    repetido = next(
        (i for i in insumos.values() if i["nome"].casefold() == nome.casefold() and i["id_insumo"] != id_atual), None
    )
    if repetido:  # RN26
        raise Erro(409, "Já existe um insumo com esse nome.", campo="nome", id_insumo_existente=repetido["id_insumo"])
    unidade = dados.get("unidade_compra")
    if unidade not in UNIDADES:
        raise Erro(422, f"Use uma destas unidades: {', '.join(UNIDADES)}.", campo="unidade_compra")
    return {
        "nome": nome,
        "custo": numero(dados, "custo"),
        "unidade_compra": unidade,
        "qtde_compra": numero(dados, "qtde_compra", maior_que_zero=True),
    }


EXEMPLO_INSUMO = {"nome": "Argola", "custo": 10.0, "unidade_compra": "un", "qtde_compra": 50.0}


@rotas.get("/insumos")
def listar_insumos():
    return [insumo_json(i) for i in por_nome(list(insumos.values()))]


@rotas.get("/insumos/{id_insumo}")
def ler_insumo(id_insumo: int):
    return insumo_json(achar(insumos, id_insumo, "Insumo"))


@rotas.post("/insumos", status_code=201)
def criar_insumo(dados: dict = Body(..., examples=[EXEMPLO_INSUMO])):
    id_insumo = novo_id(insumos)
    insumos[id_insumo] = {"id_insumo": id_insumo, **validar_insumo(dados, None)}
    return insumo_json(insumos[id_insumo])


@rotas.put("/insumos/{id_insumo}")
def editar_insumo(id_insumo: int, dados: dict = Body(..., examples=[EXEMPLO_INSUMO])):
    insumo = achar(insumos, id_insumo, "Insumo")
    insumo.update(validar_insumo(dados, id_insumo))
    return insumo_json(insumo)


@rotas.get("/insumos/{id_insumo}/produtos")
def produtos_do_insumo(id_insumo: int):
    achar(insumos, id_insumo, "Insumo")
    return produtos_que_usam(id_insumo)


@rotas.delete("/insumos/{id_insumo}", status_code=204)
def excluir_insumo(id_insumo: int):
    achar(insumos, id_insumo, "Insumo")
    usos = produtos_que_usam(id_insumo)
    if usos:  # RN11
        n = len(usos)
        raise Erro(
            409,
            f"Este insumo está em {n} produto{'s' if n > 1 else ''}. Tire-o das fichas antes de excluir.",
            produtos=usos,
        )
    del insumos[id_insumo]
    return Response(status_code=204)


# ---------------------------------------------------------------- produtos

CAMPOS_PROPRIOS = list(PADRAO_DE)
EXEMPLO_PRODUTO = {"nome": "Anel de Resina", "sku_referencia": None, "preco_atual_shopee": 12.0}


def validar_produto(dados: dict, atual: dict | None) -> dict:
    """No POST valida tudo; no PUT, só os campos que vieram."""
    novos = {}
    if atual is None or "nome" in dados:
        novos["nome"] = texto(dados, "nome", 120)
    if atual is None or "preco_atual_shopee" in dados:
        novos["preco_atual_shopee"] = numero(dados, "preco_atual_shopee")
    if atual is None or "sku_referencia" in dados:
        novos["sku_referencia"] = texto(dados, "sku_referencia", 100, nulo=True)
    for campo in CAMPOS_PROPRIOS:
        if atual is None or campo in dados:
            novos[campo] = numero(dados, campo, nulo=True)  # null = usar o padrão (RN02)
    return novos


@rotas.get("/produtos")
def listar_produtos():
    return [produto_json(p) for p in por_nome(list(produtos.values()))]


@rotas.get("/produtos/{id_produto}")
def ler_produto(id_produto: int):
    return produto_json(achar(produtos, id_produto, "Produto"))


@rotas.post("/produtos", status_code=201)
def criar_produto(dados: dict = Body(..., examples=[EXEMPLO_PRODUTO])):
    id_produto = novo_id(produtos)
    produtos[id_produto] = {**_produto(id_produto, "", None, "0"), **validar_produto(dados, None)}
    return produto_json(produtos[id_produto])


@rotas.put("/produtos/{id_produto}")
def editar_produto(id_produto: int, dados: dict = Body(..., examples=[{"preco_atual_shopee": 16.0}])):
    produto = achar(produtos, id_produto, "Produto")
    produto.update(validar_produto(dados, produto))
    return produto_json(produto)


@rotas.delete("/produtos/{id_produto}", status_code=204)
def excluir_produto(id_produto: int):
    achar(produtos, id_produto, "Produto")
    for item in itens_do_produto(id_produto):  # RN13: a ficha vai junto
        del itens[item["id_item"]]
    del produtos[id_produto]
    return Response(status_code=204)


# ---------------------------------------------------------------- ficha (itens)


def achar_item(id_produto: int, id_item: int) -> dict:
    achar(produtos, id_produto, "Produto")
    item = itens.get(id_item)
    if item is None or item["id_produto"] != id_produto:
        raise Erro(404, "Item não encontrado.")
    return item


@rotas.get("/produtos/{id_produto}/itens")
def listar_itens(id_produto: int):
    achar(produtos, id_produto, "Produto")
    return sorted((item_json(i) for i in itens_do_produto(id_produto)), key=lambda i: i["nome_insumo"].casefold())


@rotas.post("/produtos/{id_produto}/itens", status_code=201)
def adicionar_item(id_produto: int, dados: dict = Body(..., examples=[{"id_insumo": 2, "qtde": 1.0}])):
    achar(produtos, id_produto, "Produto")
    id_insumo = dados.get("id_insumo")
    if id_insumo not in insumos:
        raise Erro(422, "Escolha um insumo.", campo="id_insumo")
    if any(i["id_insumo"] == id_insumo for i in itens_do_produto(id_produto)):
        raise Erro(409, "Este insumo já está na ficha.", campo="id_insumo")
    qtde = numero(dados, "qtde", maior_que_zero=True)
    id_item = novo_id(itens)
    itens[id_item] = {"id_item": id_item, "id_produto": id_produto, "id_insumo": id_insumo, "qtde": qtde}
    return item_json(itens[id_item])


@rotas.put("/produtos/{id_produto}/itens/{id_item}")
def editar_item(id_produto: int, id_item: int, dados: dict = Body(..., examples=[{"qtde": 10.0}])):
    item = achar_item(id_produto, id_item)
    item["qtde"] = numero(dados, "qtde", maior_que_zero=True)
    return item_json(item)


@rotas.delete("/produtos/{id_produto}/itens/{id_item}", status_code=204)
def remover_item(id_produto: int, id_item: int):
    del itens[achar_item(id_produto, id_item)["id_item"]]
    return Response(status_code=204)


# ---------------------------------------------------------------- reajustes


@rotas.get("/reajustes")
def listar_reajustes():
    return [p for p in listar_produtos() if p["situacao"] == "abaixo_da_meta"]  # RN06


@rotas.post("/produtos/{id_produto}/marcar-atualizado")
def marcar_atualizado(id_produto: int):
    produto = achar(produtos, id_produto, "Produto")
    sugerido = produto_json(produto)["preco_sugerido"]
    if sugerido is None:
        raise Erro(409, "Monte a ficha antes: o produto ainda não tem preço sugerido.")
    produto["preco_atual_shopee"] = D(str(sugerido))  # RN08
    return produto_json(produto)


app.include_router(rotas)

if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
