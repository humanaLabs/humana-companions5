# 09 - Troubleshooting e Problemas Comuns

## 📋 Índice de Problemas

1. [Instalação e Dependências](#1-instalação-e-dependências)
2. [Compilação TypeScript](#2-compilação-typescript)
3. [Electron não Inicia](#3-electron-não-inicia)
4. [MCP não Conecta](#4-mcp-não-conecta)
5. [Interface não Aparece](#5-interface-não-aparece)
6. [Comandos /pw não Funcionam](#6-comandos-pw-não-funcionam)
7. [Build de Produção](#7-build-de-produção)
8. [Performance e Memória](#8-performance-e-memória)
9. [Problemas por Plataforma](#9-problemas-por-plataforma)

---

## 1. Instalação e Dependências

### ❌ Erro: "Cannot find module '@modelcontextprotocol/sdk'"

**Sintomas**:
```
Error: Cannot find module '@modelcontextprotocol/sdk/client/index.js'
```

**Causa**: Pacote MCP não instalado.

**Solução**:
```bash
# Reinstalar dependências
pnpm install @modelcontextprotocol/sdk

# Verificar
pnpm list @modelcontextprotocol/sdk
```

### ❌ Erro: "node-gyp rebuild failed" (Windows)

**Sintomas**:
```
gyp ERR! find VS
gyp ERR! find VS msvs_version not set from command line or npm config
```

**Causa**: Visual Studio Build Tools não instaladas.

**Solução**:
```powershell
# Instalar Build Tools
# https://visualstudio.microsoft.com/downloads/
# Selecionar: "Desktop development with C++"

# Ou via Chocolatey
choco install visualstudio2019-workload-vctools

# Reiniciar terminal e tentar novamente
pnpm install
```

### ❌ Erro: "EACCES: permission denied" (Linux/macOS)

**Sintomas**:
```
npm ERR! code EACCES
npm ERR! syscall mkdir
```

**Causa**: Permissões incorretas.

**Solução**:
```bash
# NÃO usar sudo npm install!
# Corrigir permissões do npm
mkdir ~/.npm-global
npm config set prefix '~/.npm-global'
echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.bashrc
source ~/.bashrc

# Reinstalar
pnpm install
```

---

## 2. Compilação TypeScript

### ❌ Erro: "Cannot find name 'window'"

**Sintomas**:
```typescript
Property 'env' does not exist on type 'Window & typeof globalThis'
```

**Causa**: Tipos não importados.

**Solução**:

Adicionar em `tsconfig.json` (raiz):
```json
{
  "include": [
    "**/*.ts",
    "**/*.tsx",
    "electron/types/**/*.ts"
  ]
}
```

Ou adicionar referência no arquivo:
```typescript
/// <reference path="../../electron/types/native.d.ts" />
```

### ❌ Erro: "Module not found: Can't resolve '@/lib/runtime'"

**Sintomas**:
```
Module not found: Can't resolve '@/lib/runtime/detection'
```

**Causa**: Path alias não configurado.

**Solução**:

Verificar `tsconfig.json`:
```json
{
  "compilerOptions": {
    "paths": {
      "@/*": ["./*"]
    }
  }
}
```

Se usar Next.js 13+, também em `next.config.js`:
```javascript
/** @type {import('next').NextConfig} */
const nextConfig = {
  // ... outras configs
};

module.exports = nextConfig;
```

### ❌ Erro na compilação do Electron: "Unexpected token"

**Sintomas**:
```
SyntaxError: Unexpected token 'export'
```

**Causa**: `electron/tsconfig.json` incorreto.

**Solução**:

Verificar `electron/tsconfig.json`:
```json
{
  "compilerOptions": {
    "module": "commonjs",  // Importante!
    "target": "ES2020"
  }
}
```

---

## 3. Electron não Inicia

### ❌ Janela não abre

**Sintomas**: Electron inicia mas janela não aparece.

**Diagnóstico**:
```bash
# Ver logs
NODE_ENV=development pnpm electron:start
```

**Causas e Soluções**:

1. **Next.js não está rodando**:
```bash
# Terminal 1
pnpm dev
# Aguardar "Ready on http://localhost:3000"

# Terminal 2
pnpm electron:start
```

2. **Porta ocupada**:
```bash
# Linux/macOS
lsof -i :3000

# Windows
netstat -ano | findstr :3000

# Matar processo
kill -9 PID  # Linux/macOS
taskkill /PID PID /F  # Windows
```

3. **URL incorreta**:

Verificar `electron/main/utils.ts`:
```typescript
export function getStartUrl(): string {
  return "http://localhost:3000";  // URL correta?
}
```

### ❌ Erro: "Cannot find module '../preload/index.js'"

**Sintomas**:
```
Error: Cannot find module '/path/to/electron/preload/index.js'
```

**Causa**: Preload não foi compilado.

**Solução**:
```bash
# Compilar Electron
pnpm electron:compile

# Verificar
ls electron/preload/index.js
# Deve existir
```

### ❌ App fecha imediatamente

**Sintomas**: Janela abre e fecha em < 1 segundo.

**Diagnóstico**:
```bash
# Rodar com logs
pnpm electron:start
# Ver erros no terminal
```

**Causa comum**: Erro no main process.

**Solução**: Verificar logs e corrigir erro.

---

## 4. MCP não Conecta

### ❌ Logs: "[MCP] Erro ao iniciar"

**Sintomas**:
```
[MCP] Erro ao iniciar: Error: spawn npx ENOENT
```

**Causa**: `@playwright/mcp` não instalado ou Node.js não no PATH.

**Solução**:
```bash
# Reinstalar MCP
pnpm install @playwright/mcp

# Verificar instalação
ls node_modules/@playwright/mcp/cli.js

# Verificar Node.js no PATH
which node  # Unix
where node  # Windows
```

### ❌ Timeout ao conectar MCP

**Sintomas**:
```
[MCP] Timeout connecting to server
```

**Diagnóstico**:
```bash
# Testar MCP manualmente
node node_modules/@playwright/mcp/cli.js
# Deve iniciar sem erros
```

**Solução**:

1. Reinstalar Playwright:
```bash
pnpm remove @playwright/mcp playwright @playwright/test
pnpm install @playwright/mcp
pnpm dlx playwright install chromium
```

2. Verificar permissões:
```bash
# Linux/macOS
chmod +x node_modules/@playwright/mcp/cli.js
```

### ❌ DevTools: "window.mcp is undefined"

**Sintomas**: No Electron, `window.mcp` não existe.

**Causa**: Preload não carregou ou não compilou.

**Diagnóstico**:
```javascript
// No DevTools do Electron
console.log(window.env);
// Se undefined, preload não carregou
```

**Solução**:

1. Recompilar preload:
```bash
pnpm electron:compile
```

2. Verificar caminho em `electron/main/window.ts`:
```typescript
webPreferences: {
  preload: path.join(__dirname, "../preload/index.js"),
  // Caminho correto?
}
```

3. Verificar logs:
```
[Preload] contextBridge configurado com sucesso
# Deve aparecer
```

---

## 5. Interface não Aparece

### ❌ Tela branca no Electron

**Sintomas**: Janela abre mas fica branca/vazia.

**Diagnóstico**:

Abrir DevTools (`Ctrl+Shift+I`):
- Ver erros no console
- Network tab: Requisições falhando?

**Causas e Soluções**:

1. **Next.js não carregou**:
```bash
# Verificar se Next.js está rodando
curl http://localhost:3000
```

2. **CSP bloqueando**:

Se tiver Content Security Policy, adicionar em `next.config.js`:
```javascript
const nextConfig = {
  async headers() {
    return [
      {
        source: '/:path*',
        headers: [
          {
            key: 'Content-Security-Policy',
            value: "default-src 'self' 'unsafe-inline' 'unsafe-eval';",
          },
        ],
      },
    ];
  },
};
```

3. **Erro de CORS**:

Verificar se está tentando fazer fetch para domínio bloqueado.

### ❌ MCPMenu não aparece

**Sintomas**: No Electron, menu MCP não renderiza.

**Diagnóstico**:
```javascript
// DevTools
console.log("isElectron:", window.env?.isElectron);
console.log("hasMCP:", !!window.mcp);
```

**Causa**: Feature detection retornando false.

**Solução**:

1. Verificar imports em `components/mcp-menu.tsx`:
```typescript
import { isElectron, hasMCP } from "@/lib/runtime/detection";
```

2. Verificar condição:
```typescript
if (!isElectron() || !hasMCP()) {
  return null;
}
```

3. Se ambos true mas não renderiza, verificar CSS:
```typescript
// Adicionar log
console.log("MCPMenu should render!");
return <div>Menu MCP</div>;
```

---

## 6. Comandos /pw não Funcionam

### ❌ Comando não interceptado

**Sintomas**: Digita `/pw navigate google.com` mas é enviado como mensagem normal.

**Causa**: Interceptação não implementada ou ordem errada.

**Solução**:

Verificar no `handleSubmit`:
```typescript
// DEVE estar ANTES do código normal de submit
if (isPlaywrightCommand(input)) {
  // ... processar
  return; // Importante: return aqui!
}

// Código normal de submit
```

### ❌ Erro: "Comandos /pw só disponíveis no Desktop"

**Sintomas**: No Electron, comando não executa.

**Diagnóstico**:
```javascript
// DevTools
console.log(window.env?.isElectron);  // true?
console.log(!!window.mcp);  // true?
```

**Causa**: MCP não inicializou ou feature detection falhando.

**Solução**: Ver seção 4 (MCP não Conecta).

### ❌ Timeout ao executar comando

**Sintomas**:
```
Timeout: O comando demorou muito para responder
```

**Causa**: Comando travou ou MCP não respondeu.

**Diagnóstico**:

Ver logs do terminal Electron:
```
[MCP] Erro ao executar tool: ...
```

**Solução**:

1. Verificar se browser Playwright está travado
2. Fechar e reabrir Electron
3. Reinstalar browsers:
```bash
pnpm dlx playwright install chromium
```

---

## 7. Build de Produção

### ❌ Erro no build: "ENOENT: no such file or directory"

**Sintomas**:
```
Error: ENOENT: no such file or directory, open '.next/...'
```

**Causa**: Next.js não foi buildado antes.

**Solução**:
```bash
# Ordem correta
pnpm build              # 1. Build Next.js
pnpm electron:compile   # 2. Compile Electron
pnpm dist               # 3. Build Electron
```

### ❌ Build muito lento (> 30 min)

**Causa**: Incluindo arquivos desnecessários.

**Solução**:

Otimizar `package.json`:
```json
{
  "build": {
    "files": [
      "electron/main/**/*.js",
      "electron/preload/**/*.js",
      "node_modules/**/*",
      "!node_modules/@types/**",
      "!node_modules/.cache/**",
      "!**/*.ts",
      "!**/*.md"
    ]
  }
}
```

### ❌ Instalador gerado mas app não funciona

**Sintomas**: Instala OK mas app não abre ou tela branca.

**Causa**: URL de produção não configurada.

**Solução**:

Atualizar `electron/main/utils.ts`:
```typescript
export function getStartUrl(): string {
  if (isDevelopment()) {
    return "http://localhost:3000";
  }
  // Em produção, usar URL pública
  return "https://seuapp.seudominio.com";  // ← Atualizar!
}
```

---

## 8. Performance e Memória

### ⚠️ Alto uso de memória (> 1GB)

**Causa**: Múltiplas instâncias ou memory leak.

**Diagnóstico**:
```bash
# Ver processos Electron
ps aux | grep electron  # Unix
tasklist | findstr electron  # Windows
```

**Solução**:

1. Fechar instâncias antigas:
```bash
killall electron  # Unix
taskkill /IM electron.exe /F  # Windows
```

2. Otimizar: Fechar browser Playwright quando não usar:
```javascript
await window.mcp.callTool("browser_close", {});
```

### ⚠️ App lento para iniciar (> 10s)

**Causa**: MCP inicialização lenta ou Next.js grande.

**Solução**:

1. Otimizar Next.js:
```javascript
// next.config.js
const nextConfig = {
  experimental: {
    optimizePackageImports: ['lucide-react'],
  },
};
```

2. Lazy load MCP:
```typescript
// Iniciar MCP apenas quando necessário
// ao invés de no startup
```

---

## 9. Problemas por Plataforma

### Windows

#### ❌ "Windows protected your PC"

**Causa**: App não assinado.

**Solução temporária**: Clicar "More info" → "Run anyway"

**Solução permanente**: Code signing (ver etapa 08).

#### ❌ Antivírus bloqueia

**Causa**: Electron flagged como suspeito.

**Solução**: Adicionar exceção no antivírus.

### macOS

#### ❌ "App is damaged and can't be opened"

**Causa**: Gatekeeper bloqueando app não assinado.

**Solução**:
```bash
# Remover quarentena
xattr -cr /Applications/Seu\ App.app

# Ou permitir apps não identificados
sudo spctl --master-disable
```

#### ❌ "xcrun: error: invalid active developer path"

**Causa**: Xcode CLI Tools não instaladas.

**Solução**:
```bash
xcode-select --install
```

### Linux

#### ❌ AppImage não executa

**Causa**: Permissões ou FUSE não instalado.

**Solução**:
```bash
# Dar permissão de execução
chmod +x Seu-App-1.0.0.AppImage

# Instalar FUSE (se necessário)
sudo apt install fuse libfuse2
```

#### ❌ Erro: "error while loading shared libraries"

**Causa**: Bibliotecas faltando.

**Solução**:
```bash
# Ubuntu/Debian
sudo apt install libgtk-3-0 libnotify4 libnss3 libxss1 libxtst6 xdg-utils

# Fedora
sudo dnf install gtk3 libnotify nss libXScrnSaver libXtst xdg-utils
```

---

## 🆘 Obtendo Ajuda

### Logs Úteis

```bash
# Logs do Electron (main process)
# Ver no terminal que iniciou o Electron

# Logs do Renderer (DevTools)
# Ctrl+Shift+I no Electron

# Logs do Next.js
# Terminal que rodou pnpm dev

# Logs do MCP
# [MCP] no terminal do Electron
```

### Comandos de Diagnóstico

```bash
# Verificar versões
node --version
pnpm --version
pnpm list electron
pnpm list @playwright/mcp

# Verificar build
ls -la electron/main/*.js
ls -la electron/preload/*.js
ls -la .next/

# Limpar tudo e recomeçar
rm -rf node_modules electron-dist .next
rm -rf electron/main/*.js electron/preload/*.js
pnpm install
pnpm build
pnpm electron:compile
```

---

## 📋 Checklist de Diagnóstico

Quando algo não funcionar:

- [ ] Node.js 18+ instalado?
- [ ] Dependências instaladas: `pnpm install`
- [ ] TypeScript compilado: `pnpm electron:compile`
- [ ] Next.js rodando: `http://localhost:3000` acessível?
- [ ] Logs no terminal: erros visíveis?
- [ ] DevTools no Electron: `Ctrl+Shift+I` - erros?
- [ ] MCP instalado: `ls node_modules/@playwright/mcp/cli.js`
- [ ] Browsers instalados: `pnpm dlx playwright install chromium`
- [ ] Permissões OK (Linux/macOS)?
- [ ] Build tools instaladas (Windows)?

---

**Se o problema persistir**: Crie issue no GitHub do projeto com:
- Versões (Node.js, pnpm, Electron)
- SO e versão
- Logs completos
- Passos para reproduzir

---

**Status**: ✅ Guia de Troubleshooting Completo

