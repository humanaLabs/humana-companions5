import { hasComputerUse } from "./detection";

/**
 * Cliente TypeScript para Computer-Use MCP
 * ⚠️ ATENÇÃO: Este cliente controla SEU DESKTOP INTEIRO!
 * Use apenas em ambientes controlados e supervisionados.
 */
export class ComputerUseClient {
  /**
   * Lista todas as tools disponíveis do Computer-Use MCP
   */
  listTools() {
    if (!hasComputerUse()) {
      console.warn("[Computer-Use Client] MCP não disponível");
      return Promise.resolve({ tools: [] });
    }
    return window.computerUse.listTools();
  }

  /**
   * Executa uma tool do Computer-Use MCP
   * @param name - Nome da tool
   * @param args - Argumentos da tool
   */
  async callTool(name: string, args?: any) {
    if (!hasComputerUse()) {
      throw new Error(
        "Computer-Use MCP não disponível - Execute apenas no Electron Desktop"
      );
    }

    console.log(`[Computer-Use Client] 🎯 Calling tool: ${name}`, args);

    try {
      const result = await window.computerUse.callTool(name, args);
      console.log(`[Computer-Use Client] ✅ Tool ${name} result:`, result);
      return result;
    } catch (error) {
      console.error(`[Computer-Use Client] ❌ Tool ${name} error:`, error);
      throw error;
    }
  }

  /**
   * Tira um screenshot da tela
   * @param options - Opções do screenshot
   */
  async takeScreenshot(options?: { displayNum?: number }) {
    return this.callTool("computer", {
      action: "get_screenshot",
      ...options,
    });
  }

  /**
   * Move o mouse para uma coordenada
   * @param x - Coordenada X
   * @param y - Coordenada Y
   */
  async moveMouse(x: number, y: number) {
    return this.callTool("computer", {
      action: "mouse_move",
      coordinate: [x, y],
    });
  }

  /**
   * Clica com o mouse
   * @param button - Botão do mouse (left, right, middle)
   */
  async click(button: "left" | "right" | "middle" = "left") {
    return this.callTool("computer", {
      action: `${button}_click`,
    });
  }

  /**
   * Clica duas vezes
   */
  async doubleClick() {
    return this.callTool("computer", {
      action: "double_click",
    });
  }

  /**
   * Digita texto
   * @param text - Texto a ser digitado
   */
  async type(text: string) {
    return this.callTool("computer", {
      action: "type",
      text,
    });
  }

  /**
   * Pressiona uma tecla
   * @param key - Tecla a ser pressionada (ex: "Enter", "Escape", "Ctrl+C")
   */
  async pressKey(key: string) {
    return this.callTool("computer", {
      action: "key",
      text: key,
    });
  }

  /**
   * Retorna a posição atual do cursor
   */
  async getCursorPosition() {
    return this.callTool("computer", {
      action: "get_cursor_position",
    });
  }
}

// Singleton instance
export const computerUseClient = new ComputerUseClient();
