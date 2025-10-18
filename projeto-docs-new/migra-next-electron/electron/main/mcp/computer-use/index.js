"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.startComputerUseMcp = startComputerUseMcp;
exports.getComputerUseMcpClient = getComputerUseMcpClient;
exports.stopComputerUseMcp = stopComputerUseMcp;
const node_path_1 = __importDefault(require("node:path"));
const index_js_1 = require("@modelcontextprotocol/sdk/client/index.js");
const stdio_js_1 = require("@modelcontextprotocol/sdk/client/stdio.js");
let computerUseClient = null;
let transport = null;
async function startComputerUseMcp() {
    try {
        console.log("[Computer-Use MCP] Iniciando Computer-Use MCP...");
        // Caminho para o CLI do Computer-Use MCP instalado localmente
        const mcpCliPath = node_path_1.default.join(process.cwd(), "node_modules", "computer-use-mcp", "dist", "index.js");
        console.log("[Computer-Use MCP] Usando CLI:", mcpCliPath);
        // Transport stdio usando o módulo local
        transport = new stdio_js_1.StdioClientTransport({
            command: process.platform === "win32" ? "node.exe" : "node",
            args: [mcpCliPath],
            env: {
                ...process.env,
                NODE_ENV: "production",
            },
        });
        // Cliente MCP
        computerUseClient = new index_js_1.Client({
            name: "ai-chatbot-electron-computer-use",
            version: "1.0.0",
        }, {
            capabilities: {},
        });
        await computerUseClient.connect(transport);
        console.log("[Computer-Use MCP] ✅ Conectado com sucesso!");
        // Listar tools disponíveis
        const tools = await computerUseClient.listTools();
        console.log("[Computer-Use MCP] Tools disponíveis:", tools.tools.map((t) => t.name));
        return computerUseClient;
    }
    catch (error) {
        console.error("[Computer-Use MCP] ❌ Erro ao iniciar:", error);
        computerUseClient = null;
        return null;
    }
}
function getComputerUseMcpClient() {
    return computerUseClient;
}
async function stopComputerUseMcp() {
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
    }
    catch (error) {
        console.error("[Computer-Use MCP] Erro ao desconectar:", error);
    }
}
//# sourceMappingURL=index.js.map