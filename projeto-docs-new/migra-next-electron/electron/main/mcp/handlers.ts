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
