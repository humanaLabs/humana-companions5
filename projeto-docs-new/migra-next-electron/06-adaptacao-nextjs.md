# 06 - Adaptação do Next.js

## ✅ Objetivos desta Etapa

- Implementar runtime detection (isElectron, hasMCP)
- Criar wrapper client para MCP
- Implementar sistema de comandos `/pw`
- Nenhuma mudança destrutiva no código existente

---

## 🔍 1. lib/runtime/detection.ts

**Feature detection - Detecta se está no Electron**

```typescript
export const isBrowser = typeof window !== "undefined";

export function isElectron(): boolean {
  if (!isBrowser) {
    return false;
  }
  return !!(window as any).env?.isElectron;
}

export function hasMCP(): boolean {
  if (!isBrowser) {
    return false;
  }
  return !!(window as any).mcp;
}

export function getPlatform(): string | null {
  if (!isElectron()) {
    return null;
  }
  return (window as any).env?.platform ?? null;
}

export function getElectronVersion(): string | null {
  if (!isElectron()) {
    return null;
  }
  return (window as any).env?.version ?? null;
}
```

**💡 Explicação**:

**Funções**:
- `isBrowser` - Detecta se está no browser (vs SSR)
- `isElectron()` - Detecta se está no Electron desktop
- `hasMCP()` - Detecta se MCP está disponível
- `getPlatform()` - Retorna SO (win32, darwin, linux)
- `getElectronVersion()` - Retorna versão do Electron

**Uso**:
```typescript
import { isElectron, hasMCP } from "@/lib/runtime/detection";

if (isElectron() && hasMCP()) {
  // Código específico para desktop
}
```

---

## 🔌 2. lib/runtime/electron-client.ts

**Wrapper client para APIs MCP**

```typescript
import { hasMCP } from "./detection";

export class ElectronMCPClient {
  listTools() {
    if (!hasMCP()) {
      console.warn("[MCP Client] MCP não disponível");
      return Promise.resolve({ tools: [] });
    }
    return window.mcp.listTools();
  }

  async callTool(name: string, args?: any) {
    if (!hasMCP()) {
      throw new Error(
        "MCP não disponível - Execute apenas no Electron Desktop"
      );
    }

    console.log(`[MCP Client] Calling tool: ${name}`, args);

    try {
      const result = await window.mcp.callTool(name, args);
      console.log(`[MCP Client] Tool ${name} result:`, result);
      return result;
    } catch (error) {
      console.error(`[MCP Client] Tool ${name} error:`, error);
      throw error;
    }
  }

  navigateTo(url: string) {
    console.log("[MCP Client] Navigate to:", url);
    return this.callTool("browser_navigate", { url });
  }

  takeSnapshot() {
    return this.callTool("browser_snapshot", {});
  }

  click(element: string, ref: string) {
    return this.callTool("browser_click", { element, ref });
  }

  type(element: string, ref: string, text: string) {
    return this.callTool("browser_type", { element, ref, text });
  }

  screenshot(filename?: string) {
    return this.callTool("browser_take_screenshot", { filename });
  }

  closePlaywright() {
    return this.callTool("browser_close", {});
  }
}

export const mcpClient = new ElectronMCPClient();
```

**💡 Explicação**:

**Classe ElectronMCPClient**:
- Wrapper amigável para `window.mcp`
- Métodos helper para ações comuns
- Logs automáticos
- Tratamento de erros

**Singleton** (linha 58):
- `mcpClient` - Instância única para todo o app

**Uso**:
```typescript
import { mcpClient } from "@/lib/runtime/electron-client";

await mcpClient.navigateTo("https://google.com");
await mcpClient.screenshot();
```

---

## 🎭 3. lib/runtime/playwright-commands.ts

**Sistema de comandos `/pw` no chat**

```typescript
import { hasMCP, isElectron } from "./detection";
import { mcpClient } from "./electron-client";

export type PlaywrightCommand = {
  command: string;
  description: string;
  args?: string[];
  handler: (args: string[]) => Promise<string>;
};

// Lista de comandos disponíveis
export const playwrightCommands: PlaywrightCommand[] = [
  {
    command: "navigate",
    description: "Navegar para uma URL",
    args: ["url"],
    handler: async ([url]) => {
      if (!url) {
        return "❌ URL não fornecida. Use: /pw navigate <url>";
      }

      // Adicionar protocolo se não tiver
      let fullUrl = url;
      if (!url.startsWith("http://") && !url.startsWith("https://")) {
        fullUrl = `https://${url}`;
      }

      try {
        const result = await mcpClient.navigateTo(fullUrl);
        console.log("[Playwright Command] Navigate result:", result);
        return `✅ Navegando para: ${fullUrl}`;
      } catch (error) {
        console.error("[Playwright Command] Navigate error:", error);
        throw new Error(
          `Erro ao navegar: ${error instanceof Error ? error.message : "Desconhecido"}`
        );
      }
    },
  },
  {
    command: "snapshot",
    description: "Capturar snapshot da página",
    handler: async () => {
      const result = await mcpClient.takeSnapshot();
      return `✅ Snapshot capturado:\n${JSON.stringify(result, null, 2)}`;
    },
  },
  {
    command: "screenshot",
    description: "Tirar screenshot",
    handler: async () => {
      const result = await mcpClient.screenshot();
      return `✅ Screenshot salvo:\n${JSON.stringify(result, null, 2)}`;
    },
  },
  {
    command: "close",
    description: "Fechar o navegador Playwright",
    handler: async () => {
      await mcpClient.closePlaywright();
      return "✅ Navegador Playwright fechado";
    },
  },
  {
    command: "tools",
    description: "Listar todas as ferramentas disponíveis",
    handler: async () => {
      const result = await mcpClient.listTools();
      const tools = result.tools || [];
      return `✅ ${tools.length} ferramentas disponíveis:\n${tools
        .map((t: any) => `  • ${t.name}`)
        .join("\n")}`;
    },
  },
  {
    command: "help",
    description: "Mostrar ajuda dos comandos /pw",
    handler: () => {
      const helpText = [
        "🎭 **Comandos Playwright disponíveis:**",
        "",
        ...playwrightCommands.map((cmd) => {
          const argsText = cmd.args
            ? ` ${cmd.args.map((a) => `<${a}>`).join(" ")}`
            : "";
          return `  **/pw ${cmd.command}${argsText}** - ${cmd.description}`;
        }),
        "",
        "📝 **Exemplos:**",
        "  /pw navigate https://google.com",
        "  /pw snapshot",
        "  /pw screenshot",
      ];
      return Promise.resolve(helpText.join("\n"));
    },
  },
  {
    command: "status",
    description: "Verificar status do MCP",
    handler: async () => {
      try {
        const result = await mcpClient.listTools();
        const tools = result.tools || [];
        return `✅ MCP conectado!\n📊 ${tools.length} ferramentas disponíveis\n\n${tools
          .slice(0, 5)
          .map((t: any) => `• ${t.name}`)
          .join(
            "\n"
          )}${tools.length > 5 ? `\n... e mais ${tools.length - 5}` : ""}`;
      } catch (error) {
        return `❌ MCP não conectado\n\nErro: ${error instanceof Error ? error.message : "Desconhecido"}\n\n💡 Verifique os logs do terminal`;
      }
    },
  },
];

// Verificar se é um comando /pw
export function isPlaywrightCommand(input: string): boolean {
  return input.trim().startsWith("/pw ");
}

// Regex para split (declarada no top level)
const WHITESPACE_REGEX = /\s+/;

// Processar comando /pw
export function processPlaywrightCommand(
  input: string
): Promise<{ success: boolean; message: string }> {
  // Verificar se está no Electron
  if (!isElectron() || !hasMCP()) {
    return Promise.resolve({
      success: false,
      message: "❌ Comandos /pw só estão disponíveis no Electron Desktop App",
    });
  }

  // Parse do comando
  const parts = input.trim().split(WHITESPACE_REGEX);
  const [_pw, commandName, ...args] = parts;

  if (!commandName) {
    return Promise.resolve({
      success: false,
      message: "❌ Comando não especificado. Use: /pw help",
    });
  }

  // Buscar comando
  const command = playwrightCommands.find((cmd) => cmd.command === commandName);

  if (!command) {
    return Promise.resolve({
      success: false,
      message: `❌ Comando desconhecido: ${commandName}\nUse: /pw help`,
    });
  }

  // Executar comando
  return command
    .handler(args)
    .then((result) => ({
      success: true,
      message: result,
    }))
    .catch((error) => {
      console.error("[Playwright Command] Erro:", error);
      return {
        success: false,
        message: `❌ Erro ao executar comando: ${error instanceof Error ? error.message : String(error)}`,
      };
    });
}
```

**💡 Explicação**:

**Comandos Disponíveis**:
- `/pw navigate <url>` - Navegar para URL
- `/pw snapshot` - Capturar snapshot
- `/pw screenshot` - Tirar screenshot
- `/pw close` - Fechar browser
- `/pw tools` - Listar ferramentas
- `/pw help` - Mostrar ajuda
- `/pw status` - Verificar status MCP

**Funções**:
- `isPlaywrightCommand()` - Detecta se input é comando /pw
- `processPlaywrightCommand()` - Executa comando

**Uso** (será integrado na etapa 7):
```typescript
import { isPlaywrightCommand, processPlaywrightCommand } from "@/lib/runtime/playwright-commands";

if (isPlaywrightCommand(input)) {
  const result = await processPlaywrightCommand(input);
  // Mostrar resultado via toast/UI
}
```

---

## ✅ 4. Validação da Implementação

### 4.1 Verificar Arquivos Criados

```bash
ls -la lib/runtime/
# Deve mostrar:
# detection.ts
# electron-client.ts
# playwright-commands.ts
```

### 4.2 Testar Detection

**No browser (desenvolvimento web)**:

Abrir DevTools em `http://localhost:3000`:

```javascript
// Executar no console
console.log("isElectron:", window?.env?.isElectron);
// Deve ser: undefined (pois não está no Electron)
```

**No Electron**:

Abrir DevTools no Electron (`Ctrl+Shift+I`):

```javascript
// Executar no console
console.log("isElectron:", window.env.isElectron);
// Deve ser: true

console.log("platform:", window.env.platform);
// Deve ser: "win32", "darwin" ou "linux"
```

### 4.3 Testar MCP Client

**No Electron DevTools**:

```javascript
// Importar (se tiver acesso ao module system)
// Ou testar diretamente window.mcp

// Listar tools
const tools = await window.mcp.listTools();
console.log("Tools:", tools.tools.map(t => t.name));

// Navegar
await window.mcp.callTool("browser_navigate", {
  url: "https://example.com"
});
```

### 4.4 Testar Comandos (Simulação)

**No Electron DevTools**:

```javascript
// Simular processamento de comando
const input = "/pw navigate https://google.com";

if (input.startsWith("/pw ")) {
  console.log("✅ Comando /pw detectado!");
  
  // Processar (se tiver module system)
  // const result = await processPlaywrightCommand(input);
  // console.log(result);
}
```

---

## 📋 Checklist da Etapa

Antes de continuar:

- [ ] `lib/runtime/detection.ts` implementado
- [ ] `lib/runtime/electron-client.ts` implementado
- [ ] `lib/runtime/playwright-commands.ts` implementado
- [ ] TypeScript compila sem erros: `pnpm build` ou `pnpm dev`
- [ ] No Electron: `window.env.isElectron === true`
- [ ] No Browser: `window.env === undefined`
- [ ] `mcpClient.listTools()` funciona no Electron
- [ ] Comandos `/pw` podem ser processados

---

## 🚨 Problemas Comuns

### ❌ Erro: "Cannot find module '@/lib/runtime'"

**Causa**: Path alias não configurado.

**Solução**: Verificar `tsconfig.json`:
```json
{
  "compilerOptions": {
    "paths": {
      "@/*": ["./*"]
    }
  }
}
```

### ❌ TypeScript erro: "Property 'env' does not exist on type 'Window'"

**Causa**: Tipos não importados.

**Solução**: Adicionar no `tsconfig.json` (raiz):
```json
{
  "include": [
    "**/*.ts",
    "**/*.tsx",
    "electron/types/**/*.ts"
  ]
}
```

Ou importar explicitamente:
```typescript
/// <reference path="../../electron/types/native.d.ts" />
```

### ❌ `window.mcp is undefined` no Electron

**Causa**: Preload não carregou.

**Verificar**:
1. Preload compilado: `ls electron/preload/index.js`
2. Caminho correto em `electron/main/window.ts`:
   ```typescript
   preload: path.join(__dirname, "../preload/index.js")
   ```

---

## 🎯 Próxima Etapa

Next.js adaptado! Agora vamos integrar na UI (componentes).

**[07-integracao-ui.md](./07-integracao-ui.md)** - Integração com UI

---

**Status**: ✅ Next.js Adaptado

