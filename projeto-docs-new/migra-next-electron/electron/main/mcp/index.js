"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.startMcp = startMcp;
exports.getMcpClient = getMcpClient;
exports.stopMcp = stopMcp;
const node_path_1 = __importDefault(require("node:path"));
const index_js_1 = require("@modelcontextprotocol/sdk/client/index.js");
const stdio_js_1 = require("@modelcontextprotocol/sdk/client/stdio.js");
let mcpClient = null;
let transport = null;
async function startMcp() {
    try {
        console.log("[MCP] Iniciando Playwright MCP (local module)...");
        // Caminho para o CLI do Playwright MCP instalado localmente
        const mcpCliPath = node_path_1.default.join(process.cwd(), "node_modules", "@playwright", "mcp", "cli.js");
        console.log("[MCP] Usando CLI:", mcpCliPath);
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
        mcpClient = new index_js_1.Client({
            name: "ai-chatbot-electron",
            version: "1.0.0",
        }, {
            capabilities: {},
        });
        await mcpClient.connect(transport);
        console.log("[MCP] Conectado com sucesso via stdio local");
        return mcpClient;
    }
    catch (error) {
        console.error("[MCP] Erro ao iniciar:", error);
        mcpClient = null;
        return null;
    }
}
function getMcpClient() {
    return mcpClient;
}
async function stopMcp() {
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
    }
    catch (error) {
        console.error("[MCP] Erro ao desconectar:", error);
    }
}
//# sourceMappingURL=index.js.map