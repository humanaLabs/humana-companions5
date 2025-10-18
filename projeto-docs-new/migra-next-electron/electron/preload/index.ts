import { contextBridge, ipcRenderer } from "electron";

// Ambiente
contextBridge.exposeInMainWorld("env", {
  isElectron: true,
  platform: process.platform,
  version: process.versions.electron,
});

// MCP APIs (Playwright)
contextBridge.exposeInMainWorld("mcp", {
  listTools: () => ipcRenderer.invoke("mcp:listTools"),
  callTool: (name: string, args?: any) =>
    ipcRenderer.invoke("mcp:callTool", { name, args }),
});

// Computer-Use MCP APIs
contextBridge.exposeInMainWorld("computerUse", {
  listTools: () => ipcRenderer.invoke("computerUse:listTools"),
  callTool: (name: string, args?: any) =>
    ipcRenderer.invoke("computerUse:callTool", { name, args }),
});

console.log("[Preload] contextBridge configurado com sucesso");
