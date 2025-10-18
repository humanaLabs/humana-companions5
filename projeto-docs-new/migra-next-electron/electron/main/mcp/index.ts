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
        name: "ai-chatbot-electron",
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
