# 12 - Scripts Helper para Windows

## ✅ Objetivo

Scripts prontos para Windows que facilitam o desenvolvimento, eliminando a necessidade de múltiplos terminais ou comandos complexos.

---

## 📝 Scripts Disponíveis

### 1. run-electron.bat (Recomendado)
- ✅ Verifica se Next.js está rodando
- ✅ Compila TypeScript automaticamente
- ✅ Inicia Electron
- ✅ Feedback visual de cada etapa
- ✅ Tratamento de erros

### 2. start-electron.ps1
- ✅ Compila TypeScript
- ✅ Configura variáveis de ambiente
- ✅ Inicia Electron
- ✅ Output colorido

---

## 🔧 1. run-electron.bat

**Criar arquivo `run-electron.bat` na raiz do projeto**:

```batch
@echo off
echo ========================================
echo   ELECTRON DEV - SEU APP
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
```

### Como Usar

**Opção 1: Duplo clique**
1. Garantir que Next.js está rodando: `pnpm dev`
2. Duplo clique em `run-electron.bat`
3. Aguardar Electron abrir

**Opção 2: Linha de comando**
```cmd
# Terminal 1: Next.js
pnpm dev

# Terminal 2: Electron (com script)
.\run-electron.bat
```

### O que o Script Faz

1. **Verifica Next.js** (linha 8-16):
   - Tenta acessar `http://localhost:3000`
   - Se falhar, mostra mensagem e aguarda usuário
   - Evita abrir Electron com tela branca

2. **Compila TypeScript** (linha 20-27):
   - Executa `pnpm electron:compile`
   - Se falhar, mostra erro e para

3. **Inicia Electron** (linha 31-37):
   - Define `NODE_ENV=development`
   - Abre Electron em janela separada (`start ""`)
   - Fecha console após 2 segundos

---

## 🔧 2. start-electron.ps1

**Criar arquivo `start-electron.ps1` na raiz do projeto**:

```powershell
# Script para iniciar Electron em Windows sem cross-env

Write-Host "🚀 Iniciando Seu App Electron..." -ForegroundColor Cyan

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
```

### Como Usar

**Opção 1: PowerShell**
```powershell
# Terminal 1: Next.js
pnpm dev

# Terminal 2: Electron (com script)
.\start-electron.ps1
```

**Opção 2: Adicionar atalho no package.json**
```json
{
  "scripts": {
    "electron:dev:win": "powershell -ExecutionPolicy Bypass -File start-electron.ps1"
  }
}
```

Usar:
```bash
pnpm electron:dev:win
```

### Resolver Erro de Execution Policy

Se aparecer erro:
```
cannot be loaded because running scripts is disabled on this system
```

**Solução temporária**:
```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\start-electron.ps1
```

**Solução permanente** (Admin):
```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

---

## 🚀 3. Script Completo (Tudo em Um)

Para quem quer **um único comando**, criar `dev-full.bat`:

```batch
@echo off
title Electron Dev - Seu App

echo ========================================
echo   INICIANDO DESENVOLVIMENTO COMPLETO
echo ========================================
echo.

REM Compilar Electron primeiro
echo [1/4] Compilando Electron...
call pnpm electron:compile
if %errorlevel% neq 0 (
    echo ❌ Erro ao compilar
    pause
    exit /b 1
)
echo ✅ Compilado
echo.

REM Iniciar Next.js em janela separada
echo [2/4] Iniciando Next.js...
start "Next.js Dev Server" cmd /c "pnpm dev"
echo ✅ Next.js iniciado em janela separada
echo.

REM Aguardar Next.js ficar pronto
echo [3/4] Aguardando Next.js...
timeout /t 5 /nobreak >nul

:check_next
curl -s http://localhost:3000 >nul 2>&1
if %errorlevel% neq 0 (
    echo    Aguardando servidor...
    timeout /t 2 /nobreak >nul
    goto check_next
)
echo ✅ Next.js pronto
echo.

REM Iniciar Electron
echo [4/4] Iniciando Electron...
set NODE_ENV=development
start "Electron" "node_modules\.bin\electron.cmd" .
echo ✅ Electron iniciado!
echo.
echo ========================================
echo   AMBIENTE PRONTO!
echo ========================================
echo.
echo Feche esta janela para continuar...
echo (Next.js e Electron estao em janelas separadas)
timeout /t 3 >nul
```

### Uso do Script Completo

```bash
# Apenas um comando!
.\dev-full.bat
```

**O que acontece**:
1. ✅ Compila Electron
2. ✅ Abre Next.js em janela separada
3. ✅ Aguarda Next.js ficar pronto
4. ✅ Abre Electron em outra janela
5. ✅ Console fecha automaticamente

**Encerrar tudo**:
- Fechar janelas individualmente
- Ou usar `Ctrl+C` em cada

---

## 🔧 4. Scripts de Build

### build-production.bat

```batch
@echo off
echo ========================================
echo   BUILD DE PRODUCAO
echo ========================================
echo.

echo [1/3] Build Next.js...
call pnpm build
if %errorlevel% neq 0 (
    echo ❌ Erro no build Next.js
    pause
    exit /b 1
)
echo ✅ Next.js buildado
echo.

echo [2/3] Compilar Electron...
call pnpm electron:compile
if %errorlevel% neq 0 (
    echo ❌ Erro ao compilar Electron
    pause
    exit /b 1
)
echo ✅ Electron compilado
echo.

echo [3/3] Gerando instalador Windows...
call pnpm dist:win
if %errorlevel% neq 0 (
    echo ❌ Erro ao gerar instalador
    pause
    exit /b 1
)
echo ✅ Instalador gerado!
echo.

echo ========================================
echo   BUILD COMPLETO!
echo ========================================
echo.
echo Instalador em: electron-dist\
dir electron-dist\*.exe
echo.
pause
```

### Uso

```bash
.\build-production.bat
```

---

## 📋 Comparação de Scripts

| Script | Quando Usar | Complexidade | Pré-requisito |
|--------|-------------|--------------|---------------|
| `run-electron.bat` | Dev rápido | ⭐ Fácil | Next.js rodando |
| `start-electron.ps1` | Dev PowerShell | ⭐ Fácil | Next.js rodando |
| `dev-full.bat` | Tudo automático | ⭐⭐ Médio | Nenhum |
| `build-production.bat` | Build final | ⭐⭐⭐ Avançado | Nenhum |

---

## 🎯 Recomendações

### Para Desenvolvimento Diário

**Opção 1: Máximo Controle**
```bash
# Terminal 1
pnpm dev

# Terminal 2
.\run-electron.bat
```

**Opção 2: Automático**
```bash
# Apenas um comando
.\dev-full.bat
```

### Para Distribuição

```bash
.\build-production.bat
```

---

## 🚨 Troubleshooting

### ❌ "curl is not recognized"

**Causa**: curl não instalado no Windows antigo.

**Solução**: Atualizar Windows 10 (build 1803+) ou instalar curl:
```bash
# Via Chocolatey
choco install curl

# Ou usar alternativa no script (ping)
ping -n 1 localhost:3000 >nul 2>&1
```

### ❌ Script não executa (duplo clique)

**Causa**: Política de execução ou erro de sintaxe.

**Solução**:
```bash
# Executar via cmd
cmd /c run-electron.bat

# Ver erros
.\run-electron.bat
pause
```

### ❌ Electron abre tela branca

**Causa**: Next.js não estava rodando quando script executou.

**Solução**: Garantir `pnpm dev` rodando antes de executar script.

### ❌ PowerShell não executa script

```powershell
# Erro: execution policy
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

# Tentar novamente
.\start-electron.ps1
```

---

## 💡 Customização

### Adicionar Notificação Sonora

```batch
REM No final do run-electron.bat
echo 🔔 Pronto!
powershell -c (New-Object Media.SoundPlayer "C:\Windows\Media\notify.wav").PlaySync()
```

### Adicionar Cores (PowerShell)

```powershell
Write-Host "✅ Sucesso!" -ForegroundColor Green
Write-Host "⚠️  Aviso!" -ForegroundColor Yellow
Write-Host "❌ Erro!" -ForegroundColor Red
```

### Abrir Navegador Automaticamente

```batch
REM Após iniciar Next.js
start http://localhost:3000
```

---

## 📦 Arquivos para Criar

**Estrutura sugerida**:
```
seu-projeto/
├── run-electron.bat         # Script principal (duplo clique)
├── start-electron.ps1       # Alternativa PowerShell
├── dev-full.bat            # Tudo automático (opcional)
├── build-production.bat    # Build completo (opcional)
└── docs/
    └── migra-next-electron/
        └── 12-scripts-helper-windows.md  # Este doc
```

---

## ✅ Checklist

- [ ] `run-electron.bat` criado na raiz
- [ ] `start-electron.ps1` criado na raiz (opcional)
- [ ] Scripts testados:
  - [ ] `run-electron.bat` funciona
  - [ ] Verifica Next.js corretamente
  - [ ] Compila TypeScript
  - [ ] Abre Electron
- [ ] Scripts commitados no git
- [ ] Equipe informada sobre os scripts

---

## 🎯 Próximos Passos

Com os scripts prontos:

1. ✅ Desenvolvimento mais rápido (1 comando)
2. ✅ Menos erros (validações automáticas)
3. ✅ Onboarding mais fácil (duplo clique)
4. ✅ Cross-platform (`.bat` Windows, `pnpm electron:dev` Unix)

---

**Status**: ✅ Scripts Helper Windows Documentados

**Uso**: Copiar scripts desejados para a raiz do novo projeto e usar!

