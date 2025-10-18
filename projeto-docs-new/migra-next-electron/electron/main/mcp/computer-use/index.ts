import path from "node:path";
import { Client } from "@modelcontextprotocol/sdk/client/index.js";
import { StdioClientTransport } from "@modelcontextprotocol/sdk/client/stdio.js";

let computerUseClient: Client | null = null;
let transport: StdioClientTransport | null = null;

export async function startComputerUseMcp() {
  try {
    console.log("[Computer-Use MCP] Iniciando Computer-Use MCP...");

    // Caminho para o CLI do Computer-Use MCP instalado localmente
    const mcpCliPath = path.join(
      process.cwd(),
      "node_modules",
      "computer-use-mcp",
      "dist",
      "index.js"
    );

    console.log("[Computer-Use MCP] Usando CLI:", mcpCliPath);

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
    computerUseClient = new Client(
      {
        name: "ai-chatbot-electron-computer-use",
        version: "1.0.0",
      },
      {
        capabilities: {},
      }
    );

    await computerUseClient.connect(transport);

    console.log("[Computer-Use MCP] ✅ Conectado com sucesso!");

    // Listar tools disponíveis
    const tools = await computerUseClient.listTools();
    console.log(
      "[Computer-Use MCP] Tools disponíveis:",
      tools.tools.map((t) => t.name)
    );

    return computerUseClient;
  } catch (error) {
    console.error("[Computer-Use MCP] ❌ Erro ao iniciar:", error);
    computerUseClient = null;
    return null;
  }
}

export function getComputerUseMcpClient(): Client | null {
  return computerUseClient;
}

export async function stopComputerUseMcp() {
  try {
    if (computerUseClient) {
      await computerUseClient.close();
      computerUseClient = null;
    }
    if (transport) {
      await transport.close();
      transport = null;
    }
    console.log("[Computer-Use MCP] Desconectado");
  } catch (error) {
    console.error("[Computer-Use MCP] Erro ao desconectar:", error);
  }
}
