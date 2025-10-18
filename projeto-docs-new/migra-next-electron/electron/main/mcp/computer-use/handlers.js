"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.registerComputerUseIpc = registerComputerUseIpc;
const electron_1 = require("electron");
const index_1 = require("./index");
// ⚠️ ALLOWLIST CRÍTICA DE SEGURANÇA
// O Computer-Use MCP pode controlar TODO o seu desktop!
// Apenas ferramentas explicitamente permitidas aqui serão executadas
const ALLOWED_TOOLS = new Set([
    "computer", // Tool principal de controle do computador
]);
// 🔴 AÇÕES BLOQUEADAS (teclas/comandos perigosos)
const BLOCKED_ACTIONS = new Set([
    "key:Delete",
    "key:Alt+F4",
    "key:Ctrl+Alt+Delete",
    "key:Windows+L",
    "left_click_drag", // Pode arrastar janelas/arquivos
]);
function registerComputerUseIpc() {
    // Listar tools disponíveis
    electron_1.ipcMain.handle("computerUse:listTools", async () => {
        const client = (0, index_1.getComputerUseMcpClient)();
        if (!client) {
            console.warn("[Computer-Use MCP] Cliente não inicializado");
            return { tools: [] };
        }
        try {
            const result = await client.listTools();
            return result;
        }
        catch (error) {
            console.error("[Computer-Use MCP] Erro ao listar tools:", error);
            return { tools: [] };
        }
    });
    // Executar tool
    electron_1.ipcMain.handle("computerUse:callTool", async (_event, { name, args }) => {
        const client = (0, index_1.getComputerUseMcpClient)();
        if (!client) {
            throw new Error("Computer-Use MCP não inicializado");
        }
        // ✅ Validar allowlist
        if (!ALLOWED_TOOLS.has(name)) {
            throw new Error(`⚠️ Tool não permitida: ${name}`);
        }
        // ✅ Validar ações bloqueadas
        if (args?.action) {
            const actionKey = `${args.action}${args.text ? `:${args.text}` : ""}`;
            if (BLOCKED_ACTIONS.has(actionKey)) {
                throw new Error(`🔴 Ação bloqueada por segurança: ${actionKey}`);
            }
        }
        // ✅ Sanitizar args
        const sanitizedArgs = sanitizeArgs(args);
        // 📝 Log de segurança
        console.log("[Computer-Use MCP] 🎯 Executando:", {
            tool: name,
            action: args?.action,
            timestamp: new Date().toISOString(),
        });
        try {
            const result = await client.callTool({
                name,
                arguments: sanitizedArgs ?? {},
            });
            console.log("[Computer-Use MCP] ✅ Resultado:", result);
            return result;
        }
        catch (error) {
            console.error("[Computer-Use MCP] ❌ Erro ao executar tool:", error);
            throw error;
        }
    });
    console.log("[Computer-Use MCP] IPC handlers registrados");
}
function sanitizeArgs(args) {
    if (!args) {
        return {};
    }
    // Remover funções, símbolos, etc
    const cleaned = JSON.parse(JSON.stringify(args));
    // ✅ Validações específicas de segurança
    if (cleaned.text) {
        // Limitar tamanho de texto
        if (cleaned.text.length > 10000) {
            throw new Error("Texto muito longo (max 10000 caracteres)");
        }
    }
    if (cleaned.coordinate) {
        // Validar coordenadas são números válidos
        const [x, y] = cleaned.coordinate;
        if (!Number.isFinite(x) || !Number.isFinite(y)) {
            throw new Error("Coordenadas inválidas");
        }
        if (x < 0 || y < 0 || x > 10000 || y > 10000) {
            throw new Error("Coordenadas fora dos limites");
        }
    }
    return cleaned;
}
//# sourceMappingURL=handlers.js.map