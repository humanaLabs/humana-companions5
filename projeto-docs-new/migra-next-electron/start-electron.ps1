# Script para iniciar Electron em Windows sem cross-env

Write-Host "🚀 Iniciando AI Chatbot Electron..." -ForegroundColor Cyan

# Compilar TypeScript
Write-Host "📦 Compilando TypeScript..." -ForegroundColor Yellow
pnpm electron:compile

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Erro na compilação!" -ForegroundColor Red
    exit 1
}

# Configurar ambiente
$env:NODE_ENV = "development"

# Rodar Electron
Write-Host "⚡ Iniciando Electron..." -ForegroundColor Green
electron .

