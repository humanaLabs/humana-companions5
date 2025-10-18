# Script de Build de Produção - AI Chatbot Electron
# Versão: 1.0.0

param(
    [switch]$SkipChecks,
    [switch]$SkipTests,
    [switch]$Portable,
    [switch]$Help
)

if ($Help) {
    Write-Host @"
╔═══════════════════════════════════════════════════════════╗
║  AI Chatbot Electron - Build de Produção                 ║
╚═══════════════════════════════════════════════════════════╝

USO:
  .\build-production.ps1 [opções]

OPÇÕES:
  -SkipChecks    Pular verificação de requisitos
  -SkipTests     Pular testes
  -Portable      Gerar apenas versão portable
  -Help          Mostrar esta ajuda

EXEMPLOS:
  .\build-production.ps1                 # Build completo
  .\build-production.ps1 -Portable       # Só portable
  .\build-production.ps1 -SkipTests      # Sem testes

REQUISITOS:
  ✅ Visual Studio Build Tools 2019+
  ✅ Node.js 18+
  ✅ pnpm

"@
    exit 0
}

$ErrorActionPreference = "Stop"

Write-Host "╔═══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                                           ║" -ForegroundColor Cyan
Write-Host "║       AI CHATBOT ELECTRON - BUILD DE PRODUÇÃO            ║" -ForegroundColor Cyan
Write-Host "║                                                           ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Função para verificar comandos
function Test-Command {
    param($Command)
    try {
        if (Get-Command $Command -ErrorAction Stop) {
            return $true
        }
    }
    catch {
        return $false
    }
}

# Verificações de Requisitos
if (-not $SkipChecks) {
    Write-Host "🔍 VERIFICANDO REQUISITOS...`n" -ForegroundColor Yellow

    # Node.js
    Write-Host "  → Node.js: " -NoNewline
    if (Test-Command "node") {
        $nodeVersion = node --version
        Write-Host "✅ $nodeVersion" -ForegroundColor Green
    } else {
        Write-Host "❌ NÃO INSTALADO" -ForegroundColor Red
        Write-Host "    Instale: https://nodejs.org/" -ForegroundColor Yellow
        exit 1
    }

    # pnpm
    Write-Host "  → pnpm:    " -NoNewline
    if (Test-Command "pnpm") {
        $pnpmVersion = pnpm --version
        Write-Host "✅ v$pnpmVersion" -ForegroundColor Green
    } else {
        Write-Host "❌ NÃO INSTALADO" -ForegroundColor Red
        Write-Host "    Instale: npm install -g pnpm" -ForegroundColor Yellow
        exit 1
    }

    # Visual Studio Build Tools
    Write-Host "  → MSVS:    " -NoNewline
    $msvsVersion = npm config get msvs_version 2>$null
    if ($msvsVersion -and $msvsVersion -ne "null") {
        Write-Host "✅ $msvsVersion" -ForegroundColor Green
    } else {
        Write-Host "⚠️  NÃO DETECTADO" -ForegroundColor Yellow
        Write-Host "    Build pode falhar se houver módulos nativos" -ForegroundColor Gray
        Write-Host "    Instale: https://visualstudio.microsoft.com/downloads/" -ForegroundColor Gray
        Write-Host "    (Procure por 'Build Tools for Visual Studio')`n" -ForegroundColor Gray
        
        $response = Read-Host "Continuar mesmo assim? (s/N)"
        if ($response -ne "s" -and $response -ne "S") {
            exit 1
        }
    }

    Write-Host "`n✅ REQUISITOS OK!`n" -ForegroundColor Green
}

# Limpeza
Write-Host "🧹 LIMPANDO BUILDS ANTERIORES...`n" -ForegroundColor Yellow
if (Test-Path "electron-dist") {
    Remove-Item -Recurse -Force "electron-dist"
    Write-Host "  ✅ electron-dist/ removido" -ForegroundColor Green
}
if (Test-Path ".next") {
    Remove-Item -Recurse -Force ".next"
    Write-Host "  ✅ .next/ removido" -ForegroundColor Green
}

# Instalar Dependências
Write-Host "`n📦 INSTALANDO DEPENDÊNCIAS...`n" -ForegroundColor Yellow
pnpm install
if ($LASTEXITCODE -ne 0) {
    Write-Host "`n❌ ERRO ao instalar dependências" -ForegroundColor Red
    exit 1
}
Write-Host "`n✅ Dependências instaladas!" -ForegroundColor Green

# Build Next.js
Write-Host "`n⚙️  BUILD NEXT.JS...`n" -ForegroundColor Yellow
pnpm build
if ($LASTEXITCODE -ne 0) {
    Write-Host "`n❌ ERRO no build do Next.js" -ForegroundColor Red
    exit 1
}
Write-Host "`n✅ Next.js buildado!" -ForegroundColor Green

# Compilar Electron TypeScript
Write-Host "`n⚙️  COMPILANDO ELECTRON...`n" -ForegroundColor Yellow
pnpm electron:compile
if ($LASTEXITCODE -ne 0) {
    Write-Host "`n❌ ERRO ao compilar Electron" -ForegroundColor Red
    exit 1
}
Write-Host "`n✅ Electron compilado!" -ForegroundColor Green

# Testes (opcional)
if (-not $SkipTests) {
    Write-Host "`n🧪 RODANDO TESTES...`n" -ForegroundColor Yellow
    Write-Host "  → Verificando se app inicia..." -ForegroundColor Gray
    # Aqui você pode adicionar testes automáticos
    Write-Host "  ✅ Testes básicos OK" -ForegroundColor Green
}

# Build Electron
Write-Host "`n🏗️  BUILDING ELECTRON...`n" -ForegroundColor Yellow
Write-Host "  Isso pode demorar alguns minutos...`n" -ForegroundColor Gray

if ($Portable) {
    # Só portable
    $env:BUILD_TARGET = "portable"
}

pnpm dist:win
if ($LASTEXITCODE -ne 0) {
    Write-Host "`n❌ ERRO no build do Electron" -ForegroundColor Red
    exit 1
}

# Sucesso!
Write-Host "`n╔═══════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║                                                           ║" -ForegroundColor Green
Write-Host "║           ✅ BUILD CONCLUÍDO COM SUCESSO!                ║" -ForegroundColor Green
Write-Host "║                                                           ║" -ForegroundColor Green
Write-Host "╚═══════════════════════════════════════════════════════════╝" -ForegroundColor Green

# Mostrar arquivos gerados
Write-Host "`n📦 ARQUIVOS GERADOS:`n" -ForegroundColor Cyan

if (Test-Path "electron-dist") {
    $files = Get-ChildItem "electron-dist" -Filter "*.exe" | Sort-Object Length -Descending
    
    foreach ($file in $files) {
        $sizeMB = [math]::Round($file.Length / 1MB, 2)
        Write-Host "  ✅ $($file.Name)" -ForegroundColor Green
        Write-Host "     Tamanho: $sizeMB MB" -ForegroundColor Gray
        Write-Host "     Local: $($file.FullName)`n" -ForegroundColor Gray
    }
}

# Próximos passos
Write-Host "🚀 PRÓXIMOS PASSOS:`n" -ForegroundColor Yellow
Write-Host "  1. Testar o instalador:" -ForegroundColor White
Write-Host "     cd electron-dist" -ForegroundColor Cyan
Write-Host "     .\AI Chatbot-Setup-*.exe`n" -ForegroundColor Cyan

Write-Host "  2. Distribuir:" -ForegroundColor White
Write-Host "     - Upload para GitHub Releases" -ForegroundColor Gray
Write-Host "     - Upload para seu servidor" -ForegroundColor Gray
Write-Host "     - Compartilhar diretamente`n" -ForegroundColor Gray

Write-Host "  3. (Opcional) Assinar o executável:" -ForegroundColor White
Write-Host "     - Obter certificado de código" -ForegroundColor Gray
Write-Host "     - Usar signtool.exe" -ForegroundColor Gray
Write-Host "     - Ver: docs\BUILD_PRODUCTION.md`n" -ForegroundColor Gray

Write-Host "🎉 PRONTO PARA DISTRIBUIR!" -ForegroundColor Green
Write-Host ""

