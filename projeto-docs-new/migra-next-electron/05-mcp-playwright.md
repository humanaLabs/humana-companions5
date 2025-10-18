# 05 - Implementação do MCP Playwright

## ✅ Objetivos desta Etapa

- Implementar cliente MCP Playwright
- Criar IPC handlers com segurança (allowlist)
- Implementar gerenciador de MCPs
- Integrar MCP no bootstrap principal
- Testar automação de browser

---

## 🎭 1. electron/main/mcp/index.ts

**Cliente MCP que conecta com Playwright via stdio**

```typescript
import path from "node:path";
import { Client } from "@modelcontextprotocol/sdk/client/index.js";
import { StdioClientTransport } from "@modelcontextprotocol/sdk/client/stdio.js";

let mcpClient: Client | null = null;
let transport: StdioClientTransport | null = null;

export async function startMcp() {
  try {
    console.log("[MCP] Iniciando Playwright MCP (local module)...");

    // Caminho para o CLI do Playwright MCP instalado localmente
    const mcpCliPath = path.join(
      process.cwd(),
      "node_modules",
      "@playwright",
      "mcp",
      "cli.js"
    );

    console.log("[MCP] Usando CLI:", mcpCliPath);

    // Transport stdio usando o módulo local
    transport = new StdioClientTransport({
      command: process.platform === "win32" ? "node.exe" : "node",
      args: [mcpCliPath],
      env: {
        ...process.env,
        NODE_ENV: "production",
      },
    });

    // Cliente MCP
    mcpClient = new Client(
      {
        name: "seu-app-electron", // Personalize aqui
        version: "1.0.0",
      },
      {
        capabilities: {},
      }
    );

    await mcpClient.connect(transport);

    console.log("[MCP] Conectado com sucesso via stdio local");

    return mcpClient;
  } catch (error) {
    console.error("[MCP] Erro ao iniciar:", error);
    mcpClient = null;
    return null;
  }
}

export function getMcpClient(): Client | null {
  return mcpClient;
}

export async function stopMcp() {
  try {
    if (mcpClient) {
      await mcpClient.close();
      mcpClient = null;
    }
    if (transport) {
      await transport.close();
      transport = null;
    }
    console.log("[MCP] Desconectado");
  } catch (error) {
    console.error("[MCP] Erro ao desconectar:", error);
  }
}
```

**💡 Explicação**:

**StdioClientTransport** (linhas 22-29):
- Usa `node.exe` (Windows) ou `node` (Unix)
- Executa `@playwright/mcp/cli.js` localmente
- Comunicação via stdin/stdout (stdio)

**Client** (linhas 32-42):
- Nome identificador do cliente
- Conecta via transport
- Retorna cliente ou null se falhar

⚠️ **Personalize**: Linha 35 - nome do seu app.

---

## 🔒 2. electron/main/mcp/handlers.ts

**IPC handlers com allowlist de segurança**

```typescript
import { ipcMain } from "electron";
import { getMcpClient } from "./index";

// Allowlist de tools permitidas
const ALLOWED_TOOLS = new Set([
  "browser_navigate",
  "browser_snapshot",
  "browser_click",
  "browser_type",
  "browser_evaluate",
  "browser_take_screenshot",
  "browser_close",
  "browser_console_messages",
  "browser_resize",
]);

export function registerMcpIpc() {
  // Listar tools disponíveis
  ipcMain.handle("mcp:listTools", async () => {
    const client = getMcpClient();
    if (!client) {
      console.warn("[MCP] Cliente não inicializado");
      return { tools: [] };
    }

    try {
      const result = await client.listTools();
      return result;
    } catch (error) {
      console.error("[MCP] Erro ao listar tools:", error);
      return { tools: [] };
    }
  });

  // Executar tool
  ipcMain.handle("mcp:callTool", async (_event, { name, args }) => {
    const client = getMcpClient();
    if (!client) {
      throw new Error("MCP não inicializado");
    }

    // Validar allowlist
    if (!ALLOWED_TOOLS.has(name)) {
      throw new Error(`Tool não permitida: ${name}`);
    }

    // Sanitizar args
    const sanitizedArgs = sanitizeArgs(args);

    try {
      const result = await client.callTool({
        name,
        arguments: sanitizedArgs ?? {},
      });

      return result;
    } catch (error) {
      console.error("[MCP] Erro ao executar tool:", error);
      throw error;
    }
  });
}

function sanitizeArgs(args: any): any {
  if (!args) {
    return {};
  }

  // Remover funções, símbolos, etc
  const cleaned = JSON.parse(JSON.stringify(args));

  // Adicionar validações específicas aqui se necessário
  return cleaned;
}
```

**💡 Explicação**:

**Allowlist** (linhas 5-14):
- Apenas ferramentas específicas podem ser executadas
- Adicione mais tools conforme necessário
- Bloqueia execução de ferramentas não autorizadas

**Sanitização** (linhas 64-73):
- Remove funções, símbolos, prototypes
- Previne injeção de código
- JSON.parse/stringify limpa objetos

⚠️ **Segurança**: Nunca remover validação da allowlist!

---

## 🎛️ 3. electron/main/mcp/manager.ts

**Gerenciador centralizado de MCPs**

```typescript
import { getMcpClient, startMcp, stopMcp } from "./index";

export interface MCPStatus {
  playwright: {
    active: boolean;
    error?: string;
  };
}

/**
 * Gerenciador central de múltiplos MCPs
 * Coordena inicialização, status e shutdown de todos os servidores MCP
 */
export class MCPManager {
  private status: MCPStatus = {
    playwright: { active: false },
  };

  /**
   * Inicializa todos os MCPs (neste caso, apenas Playwright)
   */
  async initializeAll(): Promise<MCPStatus> {
    console.log("[MCP Manager] 🚀 Inicializando todos os MCPs...");

    await this.initializePlaywright();

    console.log("[MCP Manager] Status final:", this.status);
    return this.status;
  }

  /**
   * Inicializa apenas o Playwright MCP
   */
  private async initializePlaywright(): Promise<void> {
    try {
      const client = await startMcp();
      if (client) {
        this.status.playwright.active = true;
        console.log("[MCP Manager] ✅ Playwright MCP ativo");
      } else {
        this.status.playwright.active = false;
        this.status.playwright.error = "Falha ao conectar";
        console.warn("[MCP Manager] ⚠️ Playwright MCP falhou");
      }
    } catch (error) {
      this.status.playwright.active = false;
      this.status.playwright.error = String(error);
      console.error("[MCP Manager] ❌ Erro no Playwright MCP:", error);
    }
  }

  /**
   * Retorna o status atual de todos os MCPs
   */
  getStatus(): MCPStatus {
    return {
      playwright: {
        active: !!getMcpClient(),
        error: this.status.playwright.error,
      },
    };
  }

  /**
   * Desliga todos os MCPs gracefully
   */
  async shutdownAll(): Promise<void> {
    console.log("[MCP Manager] 🛑 Desligando todos os MCPs...");

    await stopMcp();

    this.status.playwright.active = false;

    console.log("[MCP Manager] ✅ Todos os MCPs desligados");
  }
}

// Singleton instance
export const mcpManager = new MCPManager();
```

**💡 Explicação**:

**Singleton Pattern**:
- Uma única instância do gerenciador
- Coordena todos os MCPs
- Facilita adicionar mais MCPs no futuro

**Métodos**:
- `initializeAll()` - Inicia todos (atualmente só Playwright)
- `getStatus()` - Retorna status em tempo real
- `shutdownAll()` - Desliga gracefully

**Extensibilidade**: Fácil adicionar novos MCPs no futuro (computer-use, filesystem, etc).

---

## 🔧 4. Integrar MCP no Bootstrap Principal

**Atualizar electron/main/index.ts**

Substituir o arquivo completo:

```typescript
import { app, BrowserWindow } from "electron";
import { registerMcpIpc } from "./mcp/handlers";
import { mcpManager } from "./mcp/manager";
import { getStartUrl, isDevelopment } from "./utils";
import { createWindow } from "./window";

let mainWindow: BrowserWindow | null = null;

async function initialize() {
  console.log("[Electron] Inicializando aplicação...");

  // Criar janela principal
  mainWindow = createWindow();

  // Tentar inicializar todos os MCPs (não bloqueante)
  try {
    const status = await mcpManager.initializeAll();
    console.log("[Electron] MCPs inicializados:", status);
  } catch (error) {
    console.warn(
      "[Electron] Falha ao inicializar MCPs (continuando sem eles):",
      error
    );
  }

  // Registrar IPC handlers
  registerMcpIpc();

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
    mcpManager.shutdownAll().then(() => {
      app.quit();
    });
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
  await mcpManager.shutdownAll();
});

// Expor mainWindow para outros módulos
export function getMainWindow() {
  return mainWindow;
}
```

**💡 Mudanças**:
- Linha 2: Import `registerMcpIpc`
- Linha 3: Import `mcpManager`
- Linhas 15-24: Inicialização do MCP (não bloqueante)
- Linha 27: Registro de IPC handlers
- Linha 51: Shutdown do MCP ao fechar
- Linha 67: Shutdown antes de sair

---

## ✅ 5. Compilar e Testar

### 5.1 Compilar

```bash
pnpm electron:compile
```

**Deve criar**:
```
electron/main/mcp/index.js
electron/main/mcp/handlers.js
electron/main/mcp/manager.js
```

### 5.2 Verificar Erros

```bash
# Deve compilar sem erros
pnpm electron:compile

# Se houver erros de import, verificar:
pnpm list @modelcontextprotocol/sdk
pnpm list @playwright/mcp
```

### 5.3 Testar MCP

**Terminal 1 - Next.js + Electron**:
```bash
pnpm electron:dev
```

**Logs esperados**:
```
[Electron] Inicializando aplicação...
[MCP Manager] 🚀 Inicializando todos os MCPs...
[MCP] Iniciando Playwright MCP (local module)...
[MCP] Usando CLI: /caminho/para/node_modules/@playwright/mcp/cli.js
[MCP] Conectado com sucesso via stdio local
[MCP Manager] ✅ Playwright MCP ativo
[MCP Manager] Status final: { playwright: { active: true } }
[Electron] MCPs inicializados: { playwright: { active: true } }
[Electron] Carregando URL: http://localhost:3000
[Electron] URL carregada com sucesso
```

✅ **Se aparecer**: MCP está funcionando!

### 5.4 Testar no DevTools

Abrir DevTools (`Ctrl+Shift+I`):

```javascript
// Listar ferramentas MCP
const tools = await window.mcp.listTools();
console.log(tools);
// Deve mostrar: { tools: [{ name: "browser_navigate", ... }, ...] }

// Testar navegação
const result = await window.mcp.callTool("browser_navigate", {
  url: "https://google.com"
});
console.log(result);
// Deve mostrar resultado da navegação
```

✅ **Se funcionar**: MCP Playwright integrado com sucesso!

---

## 🧪 6. Testes Práticos

### 6.1 Navegar para URL

**No DevTools do Electron**:

```javascript
await window.mcp.callTool("browser_navigate", {
  url: "https://example.com"
});
```

**Resultado**: Browser Playwright abre em background e navega.

### 6.2 Capturar Snapshot

```javascript
const snapshot = await window.mcp.callTool("browser_snapshot", {});
console.log(snapshot);
```

**Resultado**: Retorna estrutura de acessibilidade da página.

### 6.3 Tirar Screenshot

```javascript
await window.mcp.callTool("browser_take_screenshot", {
  filename: "test.png"
});
```

**Resultado**: Screenshot salvo na pasta do projeto.

### 6.4 Fechar Browser

```javascript
await window.mcp.callTool("browser_close", {});
```

**Resultado**: Fecha browser Playwright.

---

## 🚨 Problemas Comuns

### ❌ Erro: "@playwright/mcp: command not found"

**Causa**: Playwright MCP não instalado.

**Solução**:
```bash
pnpm install @playwright/mcp
# Verificar
ls node_modules/@playwright/mcp/cli.js
```

### ❌ Erro: "MCP não inicializado"

**Verificar logs**:
```
[MCP] Erro ao iniciar: ...
```

**Causas comuns**:
1. `@playwright/mcp` não instalado
2. Node.js não encontrado no PATH
3. Permissões insuficientes

**Solução**:
```bash
# Reinstalar
pnpm install @playwright/mcp

# Verificar node no PATH
which node  # Unix
where node  # Windows
```

### ❌ Erro: "Tool não permitida: browser_xyz"

**Causa**: Tool não está na allowlist.

**Solução**: Adicionar em `electron/main/mcp/handlers.ts`:

```typescript
const ALLOWED_TOOLS = new Set([
  // ... existing tools
  "browser_xyz", // Adicionar aqui
]);
```

### ❌ Browser Playwright não abre

**Causa**: Browsers não instalados.

**Solução**:
```bash
# Instalar browsers do Playwright
pnpm dlx playwright install chromium

# Ou instalar todos
pnpm dlx playwright install
```

### ❌ Timeout ao conectar MCP

**Verificar**:
```bash
# Testar MCP manualmente
node node_modules/@playwright/mcp/cli.js
# Deve iniciar servidor MCP
```

**Se falhar**: Reinstalar Playwright:
```bash
pnpm remove playwright @playwright/test @playwright/mcp
pnpm install @playwright/mcp
pnpm dlx playwright install chromium
```

---

## 📋 Checklist da Etapa

Antes de continuar:

- [ ] `electron/main/mcp/index.ts` implementado
- [ ] `electron/main/mcp/handlers.ts` implementado
- [ ] `electron/main/mcp/manager.ts` implementado
- [ ] `electron/main/index.ts` atualizado com MCP
- [ ] `pnpm electron:compile` sem erros
- [ ] `pnpm electron:dev` mostra "MCP ativo" nos logs
- [ ] DevTools: `window.mcp.listTools()` retorna tools
- [ ] DevTools: `window.mcp.callTool("browser_navigate", {url: "..."})` funciona
- [ ] Browser Playwright abre e navega

---

## 🎯 Próxima Etapa

MCP Playwright implementado! Agora vamos adaptar o Next.js para detectar Electron.

**[06-adaptacao-nextjs.md](./06-adaptacao-nextjs.md)** - Adaptação do Next.js

---

**Status**: ✅ MCP Playwright Implementado

