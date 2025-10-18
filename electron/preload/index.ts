import { contextBridge } from "electron";

// Ambiente
contextBridge.exposeInMainWorld("env", {
  isElectron: true,
  platform: process.platform,
  version: process.versions.electron,
});

console.log("[Preload] contextBridge configurado com sucesso");

