@echo off
setlocal enabledelayedexpansion
title Atualizar Dashboard Polo e Polo

echo ============================================================
echo   Dashboard Farmacia Polo e Polo - Atualizacao Automatica
echo ============================================================
echo.

:: ── Diretório do projeto ─────────────────────────────────────────────────────
set "PROJETO=C:\Users\TI\OneDrive\Trabalho\Vital Contabilidade\Farmacia Polo e Polo"
cd /d "%PROJETO%"
if errorlevel 1 (
    echo [ERRO] Pasta do projeto nao encontrada:
    echo        %PROJETO%
    echo.
    echo Verifique se o OneDrive esta sincronizado e o caminho esta correto.
    pause
    exit /b 1
)

:: ── Atualizar código do projeto ───────────────────────────────────────────────
:: Sempre sincroniza com origin/main de forma explicita (fetch + reset --hard),
:: sem depender de "git pull" ou de qual branch local esta ativa/configurada -
:: isso evita cair em branches locais desatualizadas (ex: "master").
echo [1/5] Atualizando codigo do projeto...
git fetch origin main
if errorlevel 1 (
    echo [AVISO] Nao foi possivel conectar ao GitHub agora.
    echo         Prosseguindo com a versao ja existente nesta pasta.
) else (
    git reset --hard origin/main
    if errorlevel 1 (
        echo [AVISO] Nao foi possivel sincronizar o codigo automaticamente.
        echo         Prosseguindo com a versao ja existente nesta pasta.
    ) else (
        echo [OK] Codigo do projeto atualizado.
    )
)
echo.

:: ── Detectar Python disponível ───────────────────────────────────────────────
echo [2/5] Detectando Python...
set "PYTHON="

:: Tenta Anaconda base
if exist "C:\Users\TI\anaconda3\python.exe" (
    set "PYTHON=C:\Users\TI\anaconda3\python.exe"
    goto :python_found
)
:: Tenta Anaconda3 em AppData
if exist "%USERPROFILE%\AppData\Local\anaconda3\python.exe" (
    set "PYTHON=%USERPROFILE%\AppData\Local\anaconda3\python.exe"
    goto :python_found
)
:: Tenta Python padrão do sistema
where python >nul 2>&1
if not errorlevel 1 (
    set "PYTHON=python"
    goto :python_found
)
:: Tenta py launcher
where py >nul 2>&1
if not errorlevel 1 (
    set "PYTHON=py"
    goto :python_found
)

echo [ERRO] Python nao encontrado!
echo.
echo Instale o Python em https://www.python.org ou o Anaconda em https://anaconda.com
echo Ou edite este arquivo e ajuste o caminho do Python manualmente.
pause
exit /b 1

:python_found
echo [OK] Python encontrado: %PYTHON%
echo.

:: ── Verificar dependências ────────────────────────────────────────────────────
echo [3/5] Verificando dependencias Python...
%PYTHON% -c "import pandas, openpyxl, git" >nul 2>&1
if errorlevel 1 (
    echo [INFO] Instalando dependencias necessarias...
    %PYTHON% -m pip install pandas openpyxl gitpython --quiet
    if errorlevel 1 (
        echo [AVISO] Falha ao instalar dependencias. Tentando continuar mesmo assim...
    ) else (
        echo [OK] Dependencias instaladas.
    )
) else (
    echo [OK] Dependencias OK.
)
echo.

:: ── Executar script Python ────────────────────────────────────────────────────
echo [4/5] Atualizando dados do dashboard...
echo.
%PYTHON% atualizar_polo.py
if errorlevel 1 (
    echo.
    echo [ERRO] Falha ao executar atualizar_polo.py
    echo        Verifique se a planilha Resumo_Farmacia_Polo_e_Polo.xlsx esta fechada no Excel.
    pause
    exit /b 1
)

:: ── Git push (feito pelo Python, mas confirmar) ───────────────────────────────
echo.
echo [5/5] Verificando envio para o servidor...
git status --short >nul 2>&1
if errorlevel 1 (
    echo [AVISO] Git nao encontrado ou nao inicializado.
    echo         O Python pode ter feito o push automaticamente.
) else (
    echo [OK] Git operacional.
)

echo.
echo ============================================================
echo   Dashboard atualizado com sucesso!
echo   Acesse o link do Vercel para ver as alteracoes.
echo ============================================================
echo.
pause
