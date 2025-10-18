import { app, BrowserWindow } from "electron";
import { registerComputerUseIpc } from "./mcp/computer-use/handlers";
import { registerMcpIpc } from "./mcp/handlers";
import { mcpManager } from "./mcp/manager";
import { getStartUrl, isDevelopment } from "./utils";
import { createWindow } from "./window";

let mainWindow: BrowserWindow | null = null;

async function initialize() {
  console.log("[Electron] Inicializando aplicação...");

  // Criar janela principal
  mainWindow = createWindow();

  // Tentar inicializar todos os MCPs (não bloqueante)
  try {
    const status = await mcpManager.initializeAll();
    console.log("[Electron] MCPs inicializados:", status);
  } catch (error) {
    console.warn(
      "[Electron] Falha ao inicializar MCPs (continuando sem eles):",
      error
    );
  }

  // Registrar IPC handlers
  registerMcpIpc();
  registerComputerUseIpc();

  // Carregar URL
  const startUrl = getStartUrl();
  console.log("[Electron] Carregando URL:", startUrl);

  try {
    await mainWindow.loadURL(startUrl);
    console.log("[Electron] URL carregada com sucesso");
  } catch (error) {
    console.error("[Electron] Erro ao carregar URL:", error);
  }
}

// App lifecycle
app.whenReady().then(() => {
  initialize().catch((error) => {
    console.error("[Electron] Erro na inicialização:", error);
  });
});

app.on("window-all-closed", () => {
  if (process.platform !== "darwin") {
    mcpManager.shutdownAll().then(() => {
      app.quit();
    });
  }
});

app.on("activate", () => {
  if (BrowserWindow.getAllWindows().length === 0) {
    initialize().catch((error) => {
      console.error("[Electron] Erro ao reativar:", error);
    });
  }
});

app.on("before-quit", async () => {
  console.log("[Electron] Encerrando aplicação...");
  await mcpManager.shutdownAll();
});

// Expor mainWindow para outros módulos
export function getMainWindow() {
  return mainWindow;
}
