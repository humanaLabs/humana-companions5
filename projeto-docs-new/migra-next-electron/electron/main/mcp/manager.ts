import {
  getComputerUseMcpClient,
  startComputerUseMcp,
  stopComputerUseMcp,
} from "./computer-use/index";
import { getMcpClient, startMcp, stopMcp } from "./index";

export interface MCPStatus {
  playwright: {
    active: boolean;
    error?: string;
  };
  computerUse: {
    active: boolean;
    error?: string;
  };
}

/**
 * Gerenciador central de múltiplos MCPs
 * Coordena inicialização, status e shutdown de todos os servidores MCP
 */
export class MCPManager {
  private status: MCPStatus = {
    playwright: { active: false },
    computerUse: { active: false },
  };

  /**
   * Inicializa todos os MCPs em paralelo (não bloqueante)
   */
  async initializeAll(): Promise<MCPStatus> {
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
  private async initializePlaywright(): Promise<void> {
    try {
      const client = await startMcp();
      if (client) {
        this.status.playwright.active = true;
        console.log("[MCP Manager] ✅ Playwright MCP ativo");
      } else {
        this.status.playwright.active = false;
        this.status.playwright.error = "Falha ao conectar";
        console.warn("[MCP Manager] ⚠️ Playwright MCP falhou");
      }
    } catch (error) {
      this.status.playwright.active = false;
      this.status.playwright.error = String(error);
      console.error("[MCP Manager] ❌ Erro no Playwright MCP:", error);
    }
  }

  /**
   * Inicializa apenas o Computer-Use MCP
   */
  private async initializeComputerUse(): Promise<void> {
    try {
      const client = await startComputerUseMcp();
      if (client) {
        this.status.computerUse.active = true;
        console.log("[MCP Manager] ✅ Computer-Use MCP ativo");
      } else {
        this.status.computerUse.active = false;
        this.status.computerUse.error = "Falha ao conectar";
        console.warn("[MCP Manager] ⚠️ Computer-Use MCP falhou");
      }
    } catch (error) {
      this.status.computerUse.active = false;
      this.status.computerUse.error = String(error);
      console.error("[MCP Manager] ❌ Erro no Computer-Use MCP:", error);
    }
  }

  /**
   * Retorna o status atual de todos os MCPs
   */
  getStatus(): MCPStatus {
    return {
      playwright: {
        active: !!getMcpClient(),
        error: this.status.playwright.error,
      },
      computerUse: {
        active: !!getComputerUseMcpClient(),
        error: this.status.computerUse.error,
      },
    };
  }

  /**
   * Desliga todos os MCPs gracefully
   */
  async shutdownAll(): Promise<void> {
    console.log("[MCP Manager] 🛑 Desligando todos os MCPs...");

    await Promise.allSettled([stopMcp(), stopComputerUseMcp()]);

    this.status.playwright.active = false;
    this.status.computerUse.active = false;

    console.log("[MCP Manager] ✅ Todos os MCPs desligados");
  }
}

// Singleton instance
export const mcpManager = new MCPManager();
