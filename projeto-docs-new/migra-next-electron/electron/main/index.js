"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getMainWindow = getMainWindow;
const electron_1 = require("electron");
const handlers_1 = require("./mcp/computer-use/handlers");
const handlers_2 = require("./mcp/handlers");
const manager_1 = require("./mcp/manager");
const utils_1 = require("./utils");
const window_1 = require("./window");
let mainWindow = null;
async function initialize() {
    console.log("[Electron] Inicializando aplicação...");
    // Criar janela principal
    mainWindow = (0, window_1.createWindow)();
    // Tentar inicializar todos os MCPs (não bloqueante)
    try {
        const status = await manager_1.mcpManager.initializeAll();
        console.log("[Electron] MCPs inicializados:", status);
    }
    catch (error) {
        console.warn("[Electron] Falha ao inicializar MCPs (continuando sem eles):", error);
    }
    // Registrar IPC handlers
    (0, handlers_2.registerMcpIpc)();
    (0, handlers_1.registerComputerUseIpc)();
    // Carregar URL
    const startUrl = (0, utils_1.getStartUrl)();
    console.log("[Electron] Carregando URL:", startUrl);
    try {
        await mainWindow.loadURL(startUrl);
        console.log("[Electron] URL carregada com sucesso");
    }
    catch (error) {
        console.error("[Electron] Erro ao carregar URL:", error);
    }
}
// App lifecycle
electron_1.app.whenReady().then(() => {
    initialize().catch((error) => {
        console.error("[Electron] Erro na inicialização:", error);
    });
});
electron_1.app.on("window-all-closed", () => {
    if (process.platform !== "darwin") {
        manager_1.mcpManager.shutdownAll().then(() => {
            electron_1.app.quit();
        });
    }
});
electron_1.app.on("activate", () => {
    if (electron_1.BrowserWindow.getAllWindows().length === 0) {
        initialize().catch((error) => {
            console.error("[Electron] Erro ao reativar:", error);
        });
    }
});
electron_1.app.on("before-quit", async () => {
    console.log("[Electron] Encerrando aplicação...");
    await manager_1.mcpManager.shutdownAll();
});
// Expor mainWindow para outros módulos
function getMainWindow() {
    return mainWindow;
}
//# sourceMappingURL=index.js.map