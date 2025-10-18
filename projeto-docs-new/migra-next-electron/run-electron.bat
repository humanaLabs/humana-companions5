@echo off
echo ========================================
echo   ELECTRON DEV - AI CHATBOT
echo ========================================
echo.

REM Verificar se Next.js está rodando
echo [1/3] Verificando Next.js...
curl -s http://localhost:3000 >nul 2>&1
if %errorlevel% neq 0 (
    echo ⚠️  Next.js nao esta rodando!
    echo    Inicie com: pnpm dev
    pause
    exit /b 1
)
echo ✅ Next.js rodando

REM Compilar TypeScript
echo.
echo [2/3] Compilando Electron...
call pnpm electron:compile
if %errorlevel% neq 0 (
    echo ❌ Erro ao compilar
    pause
    exit /b 1
)
echo ✅ Compilado

REM Iniciar Electron
echo.
echo [3/3] Iniciando Electron...
set NODE_ENV=development
start "" "node_modules\.bin\electron.cmd" .
echo ✅ Electron iniciado!
echo.
echo ========================================
timeout /t 2 >nul

