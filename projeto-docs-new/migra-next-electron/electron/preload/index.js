"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const electron_1 = require("electron");
// Ambiente
electron_1.contextBridge.exposeInMainWorld("env", {
    isElectron: true,
    platform: process.platform,
    version: process.versions.electron,
});
// MCP APIs (Playwright)
electron_1.contextBridge.exposeInMainWorld("mcp", {
    listTools: () => electron_1.ipcRenderer.invoke("mcp:listTools"),
    callTool: (name, args) => electron_1.ipcRenderer.invoke("mcp:callTool", { name, args }),
});
// Computer-Use MCP APIs
electron_1.contextBridge.exposeInMainWorld("computerUse", {
    listTools: () => electron_1.ipcRenderer.invoke("computerUse:listTools"),
    callTool: (name, args) => electron_1.ipcRenderer.invoke("computerUse:callTool", { name, args }),
});
console.log("[Preload] contextBridge configurado com sucesso");
//# sourceMappingURL=index.js.map