# Script para iniciar Electron em Windows sem cross-env

Write-Host "Iniciando Humana Companions Electron..." -ForegroundColor Cyan

# Compilar TypeScript
Write-Host "Compilando TypeScript..." -ForegroundColor Yellow
pnpm electron:compile

if ($LASTEXITCODE -ne 0) {
    Write-Host "Erro na compilacao!" -ForegroundColor Red
    exit 1
}

# Configurar ambiente
$env:NODE_ENV = "development"

# Rodar Electron
Write-Host "Iniciando Electron..." -ForegroundColor Green
electron .

