import { hasMCP } from "./detection";

export class ElectronMCPClient {
  listTools() {
    if (!hasMCP()) {
      console.warn("[MCP Client] MCP não disponível");
      return Promise.resolve({ tools: [] });
    }
    return window.mcp.listTools();
  }

  async callTool(name: string, args?: any) {
    if (!hasMCP()) {
      throw new Error(
        "MCP não disponível - Execute apenas no Electron Desktop"
      );
    }

    console.log(`[MCP Client] Calling tool: ${name}`, args);

    try {
      const result = await window.mcp.callTool(name, args);
      console.log(`[MCP Client] Tool ${name} result:`, result);
      return result;
    } catch (error) {
      console.error(`[MCP Client] Tool ${name} error:`, error);
      throw error;
    }
  }

  navigateTo(url: string) {
    console.log("[MCP Client] Navigate to:", url);
    return this.callTool("browser_navigate", { url });
  }

  takeSnapshot() {
    return this.callTool("browser_snapshot", {});
  }

  click(element: string, ref: string) {
    return this.callTool("browser_click", { element, ref });
  }

  type(element: string, ref: string, text: string) {
    return this.callTool("browser_type", { element, ref, text });
  }

  screenshot(filename?: string) {
    return this.callTool("browser_take_screenshot", { filename });
  }

  closePlaywright() {
    return this.callTool("browser_close", {});
  }
}

export const mcpClient = new ElectronMCPClient();
