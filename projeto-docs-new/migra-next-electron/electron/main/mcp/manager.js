"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.mcpManager = exports.MCPManager = void 0;
const index_1 = require("./computer-use/index");
const index_2 = require("./index");
/**
 * Gerenciador central de múltiplos MCPs
 * Coordena inicialização, status e shutdown de todos os servidores MCP
 */
class MCPManager {
    constructor() {
        this.status = {
            playwright: { active: false },
            computerUse: { active: false },
        };
    }
    /**
     * Inicializa todos os MCPs em paralelo (não bloqueante)
     */
    async initializeAll() {
        console.log("[MCP Manager] 🚀 Inicializando todos os MCPs...");
        // Inicializar em paralelo para melhor performance
        const results = await Promise.allSettled([
            this.initializePlaywright(),
            this.initializeComputerUse(),
        ]);
        console.log("[MCP Manager] Status final:", this.status);
        return this.status;
    }
    /**
     * Inicializa apenas o Playwright MCP
     */
    async initializePlaywright() {
        try {
            const client = await (0, index_2.startMcp)();
            if (client) {
                this.status.playwright.active = true;
                console.log("[MCP Manager] ✅ Playwright MCP ativo");
            }
            else {
                this.status.playwright.active = false;
                this.status.playwright.error = "Falha ao conectar";
                console.warn("[MCP Manager] ⚠️ Playwright MCP falhou");
            }
        }
        catch (error) {
            this.status.playwright.active = false;
            this.status.playwright.error = String(error);
            console.error("[MCP Manager] ❌ Erro no Playwright MCP:", error);
        }
    }
    /**
     * Inicializa apenas o Computer-Use MCP
     */
    async initializeComputerUse() {
        try {
            const client = await (0, index_1.startComputerUseMcp)();
            if (client) {
                this.status.computerUse.active = true;
                console.log("[MCP Manager] ✅ Computer-Use MCP ativo");
            }
            else {
                this.status.computerUse.active = false;
                this.status.computerUse.error = "Falha ao conectar";
                console.warn("[MCP Manager] ⚠️ Computer-Use MCP falhou");
            }
        }
        catch (error) {
            this.status.computerUse.active = false;
            this.status.computerUse.error = String(error);
            console.error("[MCP Manager] ❌ Erro no Computer-Use MCP:", error);
        }
    }
    /**
     * Retorna o status atual de todos os MCPs
     */
    getStatus() {
        return {
            playwright: {
                active: !!(0, index_2.getMcpClient)(),
                error: this.status.playwright.error,
            },
            computerUse: {
                active: !!(0, index_1.getComputerUseMcpClient)(),
                error: this.status.computerUse.error,
            },
        };
    }
    /**
     * Desliga todos os MCPs gracefully
     */
    async shutdownAll() {
        console.log("[MCP Manager] 🛑 Desligando todos os MCPs...");
        await Promise.allSettled([(0, index_2.stopMcp)(), (0, index_1.stopComputerUseMcp)()]);
        this.status.playwright.active = false;
        this.status.computerUse.active = false;
        console.log("[MCP Manager] ✅ Todos os MCPs desligados");
    }
}
exports.MCPManager = MCPManager;
// Singleton instance
exports.mcpManager = new MCPManager();
//# sourceMappingURL=manager.js.map