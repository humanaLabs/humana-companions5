# 11 - Desenvolvimento vs Produção

## ✅ Objetivo

Entender e dominar os diferentes modos de execução:
- **Dev Mode** - Desenvolvimento com hot reload
- **Prod Mode** - Produção otimizada
- **Variáveis de ambiente**
- **Debugging**

---

## 🔄 Diferenças Fundamentais

| Aspecto | Dev Mode | Prod Mode |
|---------|----------|-----------|
| **URL Next.js** | `http://localhost:3000` | `https://app.seudominio.com` |
| **Hot Reload** | ✅ Sim (Next.js + Electron watch) | ❌ Não |
| **DevTools** | ✅ Abre automaticamente | ❌ Fechado |
| **Source Maps** | ✅ Sim | ⚠️ Opcional |
| **Otimização** | ❌ Não otimizado | ✅ Otimizado/Minificado |
| **MCP** | Local (`node_modules`) | Bundled no instalador |
| **Logs** | ✅ Verbose | ⚠️ Apenas erros |

---

## 🛠️ Modo Desenvolvimento

### 1. Scripts Disponíveis

```json
{
  "scripts": {
    "dev": "next dev --turbo",
    "electron:compile": "tsc -p electron/tsconfig.json",
    "electron:watch": "tsc -p electron/tsconfig.json --watch",
    "electron:start": "electron .",
    "electron:dev": "concurrently \"pnpm dev\" \"pnpm electron:watch\" \"wait-on http://localhost:3000 && cross-env NODE_ENV=development electron .\""
  }
}
```

### 2. Opção 1: Script Automático (Recomendado)

**Inicia tudo de uma vez**:

```bash
pnpm electron:dev
```

**O que acontece**:
1. ✅ Next.js inicia em `localhost:3000` (com Turbopack)
2. ✅ TypeScript compila Electron em modo watch
3. ✅ Aguarda Next.js ficar pronto (`wait-on`)
4. ✅ Electron inicia e carrega localhost:3000
5. 🔄 Mudanças em Electron recompilam automaticamente

**Logs esperados**:
```
[1] ▲ Next.js 15.3.0 (turbo)
[1] - Local:        http://localhost:3000
[2] Watching for file changes...
[3] [Electron] Inicializando aplicação...
[3] [MCP] Conectado com sucesso
[3] [Electron] URL carregada com sucesso
```

**Encerrar**: `Ctrl+C` (fecha tudo)

### 3. Opção 2: Manual (Mais Controle)

**Terminal 1 - Next.js**:
```bash
pnpm dev

# Aguardar
# ▲ Ready on http://localhost:3000
```

**Terminal 2 - Electron (watch mode)**:
```bash
pnpm electron:watch

# Deixar rodando
# Watching for file changes...
```

**Terminal 3 - Electron**:
```bash
pnpm electron:start

# Recarregar quando mudar código Electron:
# Ctrl+C e rodar novamente
```

### 4. Opção 3: Windows Scripts (Recomendado para Windows)

Scripts helper que automatizam o processo:

```bash
# Script .bat (recomendado)
.\run-electron.bat

# Script PowerShell
.\start-electron.ps1
```

**Ver guia completo**: [12-scripts-helper-windows.md](./12-scripts-helper-windows.md)

Esses scripts:
- ✅ Verificam se Next.js está rodando
- ✅ Compilam TypeScript automaticamente
- ✅ Iniciam Electron
- ✅ Tratam erros gracefully

### 5. Hot Reload Behavior

**Next.js (Frontend)**:
- ✅ Hot reload automático
- Mudanças em componentes React → reload instantâneo
- Mudanças em API routes → reload instantâneo

**Electron (Desktop Shell)**:
- ⚠️ **Não** hot reload automático
- Mudanças em `electron/` → recompilar + reiniciar
- **Fluxo**:
  1. Salvar mudança em `electron/main/index.ts`
  2. TypeScript recompila (se watch ativo)
  3. Fechar Electron: `Ctrl+C`
  4. Reabrir: `pnpm electron:start`

**Automação opcional** (watch + auto-restart):
```bash
# Instalar nodemon
pnpm add -D nodemon

# Adicionar script
"electron:dev:full": "nodemon --watch electron/main --exec 'electron .'"
```

---

## 🚀 Modo Produção

### 1. Build Completo

```bash
# Build tudo
pnpm electron:build

# Equivalente a:
pnpm build              # 1. Build Next.js
pnpm electron:compile   # 2. Compile Electron
electron-builder        # 3. Empacotar
```

**Resultado**: `electron-dist/Seu App-Setup-1.0.0.exe`

### 2. Build por Plataforma

```bash
# Windows
pnpm dist:win
# → Seu App-Setup-1.0.0.exe (instalador)
# → Seu App-1.0.0.exe (portable)

# macOS
pnpm dist:mac
# → Seu App-1.0.0.dmg

# Linux
pnpm dist:linux
# → Seu App-1.0.0.AppImage
```

### 3. Testar Build Localmente (Antes de Distribuir)

```bash
# Build
pnpm dist:win

# Executar instalador
.\electron-dist\Seu App-Setup-1.0.0.exe

# Ou portable
.\electron-dist\Seu App-1.0.0.exe
```

### 4. URL de Produção

**Configurar em `electron/main/utils.ts`**:

```typescript
export function getStartUrl(): string {
  // Dev: localhost
  if (isDevelopment() || !process.env.ELECTRON_START_URL) {
    return process.env.ELECTRON_START_URL || "http://localhost:3000";
  }
  
  // Prod: URL remota OU servir .next local
  return "https://app.seudominio.com";
}
```

**Opções de Deploy**:

#### Opção A: Shell Remoto (Recomendado)
```typescript
// Electron carrega URL remota
return "https://app.seudominio.com";
```

**Vantagens**:
- ✅ Updates Next.js não requerem recompilação Electron
- ✅ Deploy web normal (Vercel, Netlify, etc)
- ✅ Usuários recebem updates automaticamente

**Desvantagens**:
- ❌ Requer internet
- ❌ Primeira carga mais lenta

#### Opção B: Bundled (Local)
```typescript
// Electron serve .next/ local
import { app } from "electron";
import path from "path";

export function getStartUrl(): string {
  if (isDevelopment()) {
    return "http://localhost:3000";
  }
  
  // Em produção, servir local
  const nextPath = path.join(app.getAppPath(), ".next");
  return `file://${nextPath}/index.html`;
}
```

**Requer**: Incluir `.next/` no bundle:

```json
{
  "build": {
    "files": [
      ".next/**/*",
      "public/**/*"
    ]
  }
}
```

**Vantagens**:
- ✅ Funciona offline
- ✅ Mais rápido (local)

**Desvantagens**:
- ❌ Updates requerem reinstalar Electron
- ❌ Binário maior (~200-300MB)

---

## 🔐 Variáveis de Ambiente

### 1. Desenvolvimento

**`.env.local`** (Next.js):
```bash
# API Keys
OPENAI_API_KEY=sk-...
DATABASE_URL=postgresql://...

# Dev only
NEXT_PUBLIC_API_URL=http://localhost:3000/api
```

**`.env.development`** (Electron):
```bash
NODE_ENV=development
ELECTRON_START_URL=http://localhost:3000
```

### 2. Produção

**`.env.production`** (Next.js):
```bash
NEXT_PUBLIC_API_URL=https://api.seudominio.com
DATABASE_URL=postgresql://prod...
```

**Electron** (passar via script):
```json
{
  "scripts": {
    "electron:build": "cross-env ELECTRON_START_URL=https://app.seudominio.com pnpm build && pnpm electron:compile && electron-builder"
  }
}
```

### 3. Acessar no Código

**Next.js**:
```typescript
// Client-side (NEXT_PUBLIC_*)
const apiUrl = process.env.NEXT_PUBLIC_API_URL;

// Server-side (qualquer env var)
const dbUrl = process.env.DATABASE_URL;
```

**Electron Main**:
```typescript
// Qualquer env var
const startUrl = process.env.ELECTRON_START_URL || "http://localhost:3000";
```

---

## 🐛 Debugging

### Dev Mode

#### 1. Next.js (Frontend)
```bash
# DevTools do Chrome
# Abrir http://localhost:3000
# F12 → Console, Network, etc
```

#### 2. Electron Renderer
```typescript
// electron/main/window.ts
if (isDevelopment()) {
  window.webContents.openDevTools(); // Abre automaticamente
}
```

**Ou manualmente**: `Ctrl+Shift+I` (Windows/Linux) ou `Cmd+Option+I` (macOS)

#### 3. Electron Main Process
```bash
# Logs no terminal
console.log("[Main] Debug info:", data);

# Ou usar VSCode debugger
```

**VSCode Launch Config** (`.vscode/launch.json`):
```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Debug Electron Main",
      "type": "node",
      "request": "launch",
      "cwd": "${workspaceFolder}",
      "runtimeExecutable": "${workspaceFolder}/node_modules/.bin/electron",
      "windows": {
        "runtimeExecutable": "${workspaceFolder}/node_modules/.bin/electron.cmd"
      },
      "args": ["."],
      "outputCapture": "std",
      "skipFiles": ["<node_internals>/**"]
    }
  ]
}
```

**Uso**:
1. Abrir VSCode
2. F5 → "Debug Electron Main"
3. Colocar breakpoints em `electron/main/*.ts`

### Prod Mode

#### Logs em Produção

**Configurar logging**:
```typescript
// electron/main/index.ts
import fs from "fs";
import path from "path";
import { app } from "electron";

const logPath = path.join(app.getPath("userData"), "app.log");

function log(message: string) {
  const timestamp = new Date().toISOString();
  const logMessage = `[${timestamp}] ${message}\n`;
  
  console.log(logMessage);
  fs.appendFileSync(logPath, logMessage);
}

log("[Electron] App iniciado");
```

**Localização dos logs**:
- Windows: `%APPDATA%\Seu App\app.log`
- macOS: `~/Library/Application Support/Seu App/app.log`
- Linux: `~/.config/Seu App/app.log`

---

## 📊 Checklist Dev vs Prod

### Desenvolvimento
- [ ] `pnpm electron:dev` funciona
- [ ] Hot reload Next.js funciona
- [ ] Mudanças Electron recompilam com watch
- [ ] DevTools acessível
- [ ] MCP conecta
- [ ] Logs verbose no terminal
- [ ] Performance OK (não otimizado, OK ser mais lento)

### Produção
- [ ] `pnpm electron:build` sem erros
- [ ] Instalador funciona
- [ ] App abre sem internet (se bundled) OU com internet (se remote)
- [ ] MCP funciona
- [ ] Performance boa (< 1GB RAM, < 10s startup)
- [ ] DevTools fechado (ou abre apenas com atalho)
- [ ] Logs apenas erros críticos
- [ ] Ícone e nome corretos

---

## 🚨 Problemas Comuns

### Dev Mode

#### ❌ "Port 3000 already in use"
```bash
# Matar processo
lsof -ti:3000 | xargs kill -9  # macOS/Linux
netstat -ano | findstr :3000   # Windows (ver PID)
taskkill /PID <PID> /F         # Windows (matar)
```

#### ❌ Electron não recarrega mudanças
```bash
# Verificar se watch está ativo
pnpm electron:watch

# Se não estiver, rodar em terminal separado
# Ou usar electron:dev que já inclui watch
```

#### ❌ MCP não conecta em dev
```bash
# Verificar se @playwright/mcp está instalado
pnpm list @playwright/mcp

# Reinstalar
pnpm install @playwright/mcp
```

### Prod Mode

#### ❌ Tela branca após instalação
```typescript
// Verificar URL em electron/main/utils.ts
export function getStartUrl(): string {
  if (isDevelopment()) {
    return "http://localhost:3000";
  }
  return "https://app.seudominio.com"; // URL correta?
}
```

#### ❌ MCP não funciona após build
```bash
# Verificar se @playwright/mcp foi incluído
# Adicionar em package.json build.files:
{
  "build": {
    "files": [
      "node_modules/@playwright/**/*",
      "node_modules/@modelcontextprotocol/**/*"
    ]
  }
}
```

---

## 💡 Dicas Pro

### 1. Ambiente Híbrido (Dev Web + Prod Desktop)

```bash
# Terminal 1: Next.js em produção local
pnpm build
pnpm start

# Terminal 2: Electron (testa como se fosse prod)
NODE_ENV=production pnpm electron:start
```

### 2. Debug Performance

```typescript
// Adicionar logs de timing
console.time("MCP Init");
await startMcp();
console.timeEnd("MCP Init");
```

### 3. Profiles Diferentes

```json
{
  "scripts": {
    "electron:dev": "cross-env ELECTRON_ENV=dev pnpm electron:dev",
    "electron:staging": "cross-env ELECTRON_ENV=staging ...",
    "electron:prod": "cross-env ELECTRON_ENV=prod ..."
  }
}
```

```typescript
// electron/main/utils.ts
export function getStartUrl(): string {
  const env = process.env.ELECTRON_ENV || "dev";
  
  const urls = {
    dev: "http://localhost:3000",
    staging: "https://staging.seudominio.com",
    prod: "https://app.seudominio.com",
  };
  
  return urls[env] || urls.dev;
}
```

---

## 📋 Resumo Rápido

### Desenvolvimento
```bash
# Tudo automático
pnpm electron:dev

# Ou manual
pnpm dev                 # Terminal 1
pnpm electron:watch      # Terminal 2
pnpm electron:start      # Terminal 3 (reiniciar quando mudar Electron)
```

### Produção
```bash
# Build
pnpm electron:build      # ou dist:win, dist:mac, dist:linux

# Testar
.\electron-dist\Seu App-Setup-1.0.0.exe
```

### Quick Commands
| Comando | Quando Usar |
|---------|-------------|
| `pnpm dev` | Next.js standalone |
| `pnpm electron:dev` | **Desenvolvimento completo (recomendado)** |
| `pnpm electron:start` | Electron apenas (Next.js já rodando) |
| `pnpm electron:compile` | Compilar Electron TS → JS |
| `pnpm electron:build` | **Build produção completo** |
| `pnpm dist:win` | Build Windows apenas |

---

**Status**: ✅ Guia Dev vs Prod Completo

