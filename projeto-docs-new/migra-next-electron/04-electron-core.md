# 04 - Implementação do Electron Core

## ✅ Objetivos desta Etapa

- Implementar main process (bootstrap)
- Criar gerenciamento de janelas
- Implementar utils (helpers)
- Configurar preload script (context bridge)
- Definir tipos TypeScript

---

## 📝 1. electron/main/utils.ts

**Funções utilitárias básicas**

```typescript
export function isDevelopment(): boolean {
  return process.env.NODE_ENV === "development";
}

export function npxCmd(): string {
  return process.platform === "win32" ? "npx.cmd" : "npx";
}

export function getStartUrl(): string {
  // Em desenvolvimento, tenta localhost primeiro
  // Usa variável de ambiente ou default para localhost:3000
  if (isDevelopment() || !process.env.ELECTRON_START_URL) {
    return process.env.ELECTRON_START_URL || "http://localhost:3000";
  }
  
  // Em produção, usar sua URL de produção
  return "https://seuapp.seudominio.com";
}
```

**💡 Explicação**:
- `isDevelopment()`: Detecta ambiente dev
- `npxCmd()`: npx.cmd no Windows, npx no Unix
- `getStartUrl()`: URL que Electron carregará (localhost em dev, produção em prod)

⚠️ **Personalize**: Altere URL de produção na linha 12.

---

## 🪟 2. electron/main/window.ts

**Gerenciamento de janelas BrowserWindow**

```typescript
import path from "node:path";
import { BrowserWindow, shell } from "electron";
import { isDevelopment } from "./utils";

export function createWindow(): BrowserWindow {
  const window = new BrowserWindow({
    width: 1280,
    height: 800,
    minWidth: 800,
    minHeight: 600,
    backgroundColor: "#ffffff",
    autoHideMenuBar: true, // Ocultar menu
    webPreferences: {
      preload: path.join(__dirname, "../preload/index.js"),
      nodeIntegration: false,
      contextIsolation: true,
      sandbox: true,
      webSecurity: true,
      allowRunningInsecureContent: false,
    },
    show: false,
  });

  // Mostrar janela quando estiver pronta (evita flash branco)
  window.once("ready-to-show", () => {
    window.show();
  });

  // Abrir links externos no navegador do sistema
  window.webContents.setWindowOpenHandler(({ url }) => {
    if (url.startsWith("http://") || url.startsWith("https://")) {
      shell.openExternal(url);
    }
    return { action: "deny" };
  });

  // Allowlist de navegação (segurança)
  window.webContents.on("will-navigate", (event, url) => {
    const allowedOrigins = [
      "http://localhost:3000",
      "http://localhost:3001",
      "https://seuapp.seudominio.com", // Adicione seu domínio de produção
    ];

    const allowed = allowedOrigins.some((origin) => url.startsWith(origin));

    if (!allowed) {
      event.preventDefault();
      console.warn("[Security] Navegação bloqueada:", url);
    }
  });

  // Logs úteis em dev (opcional)
  if (isDevelopment()) {
    window.webContents.on(
      "did-fail-load",
      (_event, errorCode, errorDescription) => {
        console.error(
          "[Window] Falha ao carregar:",
          errorCode,
          errorDescription
        );
      }
    );

    window.webContents.on("console-message", (_event, _level, message) => {
      console.log("[Renderer]", message);
    });
  }

  return window;
}
```

**💡 Explicação**:

**Segurança** (linhas 12-19):
- `nodeIntegration: false` - Renderer não acessa Node.js
- `contextIsolation: true` - Isola contextos
- `sandbox: true` - Sandboxing completo
- `webSecurity: true` - Políticas web ativas

**Allowlist de Navegação** (linhas 36-50):
- Apenas domínios permitidos podem ser navegados
- Bloqueia redirecionamentos maliciosos

⚠️ **Personalize**: Adicione seus domínios na linha 40.

---

## 🚀 3. electron/main/index.ts

**Entry point do Electron (bootstrap principal)**

```typescript
import { app, BrowserWindow } from "electron";
import { getStartUrl, isDevelopment } from "./utils";
import { createWindow } from "./window";

let mainWindow: BrowserWindow | null = null;

async function initialize() {
  console.log("[Electron] Inicializando aplicação...");

  // Criar janela principal
  mainWindow = createWindow();

  // TODO: MCP será inicializado na etapa 5
  // TODO: IPC handlers serão registrados na etapa 5

  // Carregar URL
  const startUrl = getStartUrl();
  console.log("[Electron] Carregando URL:", startUrl);

  try {
    await mainWindow.loadURL(startUrl);
    console.log("[Electron] URL carregada com sucesso");
  } catch (error) {
    console.error("[Electron] Erro ao carregar URL:", error);
  }
}

// App lifecycle
app.whenReady().then(() => {
  initialize().catch((error) => {
    console.error("[Electron] Erro na inicialização:", error);
  });
});

app.on("window-all-closed", () => {
  if (process.platform !== "darwin") {
    app.quit();
  }
});

app.on("activate", () => {
  if (BrowserWindow.getAllWindows().length === 0) {
    initialize().catch((error) => {
      console.error("[Electron] Erro ao reativar:", error);
    });
  }
});

app.on("before-quit", async () => {
  console.log("[Electron] Encerrando aplicação...");
  // TODO: Shutdown MCP será adicionado na etapa 5
});

// Expor mainWindow para outros módulos
export function getMainWindow() {
  return mainWindow;
}
```

**💡 Explicação**:

**Ciclo de Vida**:
- `app.whenReady()` - Inicializa quando Electron está pronto
- `window-all-closed` - Fecha app (exceto macOS)
- `activate` - Reabre janela (macOS)
- `before-quit` - Cleanup antes de fechar

⚠️ **Nota**: Linhas com `TODO` serão implementadas na etapa 5 (MCP).

---

## 🌉 4. electron/preload/index.ts

**Context Bridge - Expõe APIs seguras para renderer**

```typescript
import { contextBridge, ipcRenderer } from "electron";

// Ambiente
contextBridge.exposeInMainWorld("env", {
  isElectron: true,
  platform: process.platform,
  version: process.versions.electron,
});

// MCP APIs (Playwright)
// Serão usadas quando MCP estiver implementado (etapa 5)
contextBridge.exposeInMainWorld("mcp", {
  listTools: () => ipcRenderer.invoke("mcp:listTools"),
  callTool: (name: string, args?: any) =>
    ipcRenderer.invoke("mcp:callTool", { name, args }),
});

console.log("[Preload] contextBridge configurado com sucesso");
```

**💡 Explicação**:

**window.env**:
- `isElectron: true` - Identifica que está no Electron
- `platform` - SO (win32, darwin, linux)
- `version` - Versão do Electron

**window.mcp**:
- `listTools()` - Lista ferramentas Playwright disponíveis
- `callTool()` - Executa ferramenta Playwright

⚠️ **Segurança**: Apenas métodos explícitos são expostos. Renderer nunca acessa Node.js diretamente.

---

## 📘 5. electron/types/native.d.ts

**Tipos TypeScript para APIs expostas**

```typescript
export {};

declare global {
  // biome-ignore lint/nursery/useConsistentTypeDefinitions: Required for global Window
  interface Window {
    env: {
      isElectron: boolean;
      platform: string;
      version: string;
    };

    mcp: {
      listTools: () => Promise<any>;
      callTool: (name: string, args?: any) => Promise<any>;
    };
  }
}
```

**💡 Explicação**:
- Declara tipos globais para `window.env` e `window.mcp`
- TypeScript reconhecerá essas propriedades no código Next.js
- Autocomplete funciona no VSCode/IDE

---

## ✅ 6. Compilar e Testar

### 6.1 Compilar TypeScript

```bash
pnpm electron:compile
```

**Deve criar**:
```
electron/main/index.js
electron/main/window.js
electron/main/utils.js
electron/preload/index.js
```

### 6.2 Verificar Erros de Compilação

```bash
# Deve compilar sem erros
pnpm electron:compile

# Se houver erros, corrigir antes de continuar
```

### 6.3 Testar Electron (Básico)

⚠️ **Importante**: Next.js deve estar rodando primeiro!

**Terminal 1 - Next.js**:
```bash
pnpm dev
# Aguarde: "Ready on http://localhost:3000"
```

**Terminal 2 - Electron**:
```bash
pnpm electron:start
```

**O que deve acontecer**:
1. ✅ Janela Electron abre
2. ✅ Carrega http://localhost:3000
3. ✅ Seu app Next.js aparece na janela

**Se funcionar**: 🎉 Electron Core implementado com sucesso!

### 6.4 Testar com Script Automático

```bash
# Fecha tudo e testa script completo
pnpm electron:dev
```

**O que deve acontecer**:
1. Next.js inicia automaticamente
2. TypeScript compila em modo watch
3. Electron abre após Next.js estar pronto

**Atalho de teclado**:
- `Ctrl+C` (ou `Cmd+C`) - Fecha tudo

---

## 🔍 7. Validação Detalhada

### 7.1 Console do Electron

Abrir DevTools no Electron:
- Windows/Linux: `Ctrl+Shift+I`
- macOS: `Cmd+Option+I`

**Executar no console**:
```javascript
console.log(window.env);
// Deve mostrar: { isElectron: true, platform: "win32", version: "38.x.x" }

console.log(window.mcp);
// Deve mostrar: { listTools: ƒ, callTool: ƒ }
```

✅ **Se funcionar**: Context Bridge está OK!

### 7.2 Logs no Terminal

Verificar logs do main process:

```
[Electron] Inicializando aplicação...
[Electron] Carregando URL: http://localhost:3000
[Electron] URL carregada com sucesso
[Preload] contextBridge configurado com sucesso
```

✅ **Se aparecer**: Bootstrap está OK!

### 7.3 Testar Navegação

No Electron, navegar para:
- ✅ `http://localhost:3000` - Deve funcionar
- ✅ `http://localhost:3000/qualquer-rota` - Deve funcionar
- ❌ `https://google.com` - Deve ser bloqueado (allowlist)

**Se tentar acessar domínio não permitido**:
```
[Security] Navegação bloqueada: https://google.com
```

✅ **Se funcionar**: Segurança está OK!

---

## 🚨 Problemas Comuns

### ❌ Janela não abre

**Verificar**:
```bash
# Next.js está rodando?
curl http://localhost:3000

# Porta ocupada?
lsof -i :3000  # macOS/Linux
netstat -ano | findstr :3000  # Windows
```

**Solução**: Garantir que Next.js está em `http://localhost:3000`.

### ❌ Erro: "Cannot find module '../preload/index.js'"

**Causa**: Preload não foi compilado.

**Solução**:
```bash
pnpm electron:compile
# Verificar que electron/preload/index.js foi criado
ls electron/preload/index.js
```

### ❌ Janela branca/vazia

**Verificar URL**:
```typescript
// electron/main/utils.ts
export function getStartUrl(): string {
  return "http://localhost:3000"; // URL correta?
}
```

**Verificar console**:
- Abrir DevTools: `Ctrl+Shift+I`
- Ver erros no console

### ❌ "window.env is undefined"

**Causa**: Preload não carregou.

**Verificar**:
```typescript
// electron/main/window.ts
webPreferences: {
  preload: path.join(__dirname, "../preload/index.js"), // Caminho correto?
}
```

**Solução**: Garantir caminho correto e que preload foi compilado.

### ❌ App fecha imediatamente

**Causa**: Erro no main process.

**Ver logs**:
```bash
# Rodar com logs detalhados
NODE_ENV=development pnpm electron:start
```

---

## 📋 Checklist da Etapa

Antes de continuar:

- [ ] `electron/main/utils.ts` implementado
- [ ] `electron/main/window.ts` implementado
- [ ] `electron/main/index.ts` implementado
- [ ] `electron/preload/index.ts` implementado
- [ ] `electron/types/native.d.ts` implementado
- [ ] `pnpm electron:compile` executa sem erros
- [ ] Arquivos `.js` gerados
- [ ] `pnpm electron:dev` abre janela com Next.js
- [ ] DevTools mostra `window.env.isElectron = true`
- [ ] Allowlist de navegação funciona (bloqueia domínios externos)

---

## 🎯 Próxima Etapa

Electron Core implementado! Agora vamos adicionar MCP Playwright.

**[05-mcp-playwright.md](./05-mcp-playwright.md)** - Implementação do MCP Playwright

---

**Status**: ✅ Electron Core Implementado

