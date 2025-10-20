/**
 * Stubs para funcionalidades Electron
 * Usado no build web (Vercel) para evitar erros "Module not found"
 *
 * IMPORTANTE: Priorizar window.electronRuntime quando disponível!
 */

export function isElectron(): boolean {
  if (typeof window === "undefined") {
    return false;
  }

  // PRIORITY: Usar runtime injetado pelo preload
  if ((window as any).electronRuntime?.isElectron) {
    return (window as any).electronRuntime.isElectron();
  }

  // Fallback: Verificar window.env (método atual do projeto)
  if ((window as any).env?.isElectron) {
    return true;
  }

  // Fallback: false no web puro
  return false;
}

export function hasMCP(): boolean {
  if (typeof window === "undefined") {
    return false;
  }

  // PRIORITY: Usar runtime injetado pelo preload
  if ((window as any).electronRuntime?.hasMCP) {
    return (window as any).electronRuntime.hasMCP();
  }

  return false;
}

export const mcpClient = {
  listTools: () => {
    // PRIORITY: Usar client injetado pelo preload
    if (
      typeof window !== "undefined" &&
      (window as any).electronRuntime?.mcpClient
    ) {
      return (window as any).electronRuntime.mcpClient.listTools();
    }

    console.warn("MCP not available in web mode");
    return Promise.resolve({ tools: [] });
  },

  callTool: (name: string, args?: unknown) => {
    // PRIORITY: Usar client injetado pelo preload
    if (
      typeof window !== "undefined" &&
      (window as any).electronRuntime?.mcpClient
    ) {
      return (window as any).electronRuntime.mcpClient.callTool(name, args);
    }

    console.warn("MCP not available in web mode");
    return Promise.reject(
      new Error(`MCP tool '${name}' not available in web mode`)
    );
  },
};

export const computerUseClient = {
  listTools: () => {
    // PRIORITY: Usar client injetado pelo preload
    if (
      typeof window !== "undefined" &&
      (window as any).electronRuntime?.computerUseClient
    ) {
      return (window as any).electronRuntime.computerUseClient.listTools();
    }

    console.warn("Computer-Use not available in web mode");
    return Promise.resolve({ tools: [] });
  },

  callTool: (name: string, args?: unknown) => {
    // PRIORITY: Usar client injetado pelo preload
    if (
      typeof window !== "undefined" &&
      (window as any).electronRuntime?.computerUseClient
    ) {
      return (window as any).electronRuntime.computerUseClient.callTool(
        name,
        args
      );
    }

    console.warn("Computer-Use not available in web mode");
    return Promise.reject(
      new Error(`Computer-Use tool '${name}' not available in web mode`)
    );
  },
};
