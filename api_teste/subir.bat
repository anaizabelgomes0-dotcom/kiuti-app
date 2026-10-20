@echo off
rem Sobe a API de teste em http://localhost:8000 (Swagger em /docs). Feche a janela para parar.
cd /d "%~dp0"
if not exist .venv (
    echo Criando o ambiente .venv e instalando o FastAPI ^(so na primeira vez^)...
    python -m venv .venv || goto erro
    .venv\Scripts\python -m pip install -r requirements.txt || goto erro
)
.venv\Scripts\python main.py
pause
exit /b

:erro
echo.
echo Nao deu para preparar o ambiente. Confira se o Python esta instalado: python --version
pause
