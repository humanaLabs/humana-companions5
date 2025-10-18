import { computerUseClient } from "./computer-use-client";
import { hasComputerUse, isElectron } from "./detection";

export type ComputerUseCommand = {
  command: string;
  description: string;
  args?: string[];
  handler: (args: string[]) => Promise<string>;
};

// Lista de comandos disponíveis
export const computerUseCommands: ComputerUseCommand[] = [
  {
    command: "screenshot",
    description: "Tirar screenshot da tela",
    handler: async () => {
      try {
        const result = await computerUseClient.takeScreenshot();
        return `✅ Screenshot capturado:\n${JSON.stringify(result, null, 2)}`;
      } catch (error) {
        throw new Error(
          `Erro ao tirar screenshot: ${error instanceof Error ? error.message : "Desconhecido"}`
        );
      }
    },
  },
  {
    command: "cursor",
    description: "Obter posição atual do cursor",
    handler: async () => {
      try {
        const result = await computerUseClient.getCursorPosition();
        return `✅ Posição do cursor:\n${JSON.stringify(result, null, 2)}`;
      } catch (error) {
        throw new Error(
          `Erro ao obter posição: ${error instanceof Error ? error.message : "Desconhecido"}`
        );
      }
    },
  },
  {
    command: "move",
    description: "Mover mouse para coordenadas X Y",
    args: ["x", "y"],
    handler: async ([x, y]) => {
      if (!x || !y) {
        return "❌ Coordenadas não fornecidas. Use: /cc move <x> <y>";
      }

      const xNum = Number.parseInt(x, 10);
      const yNum = Number.parseInt(y, 10);

      if (Number.isNaN(xNum) || Number.isNaN(yNum)) {
        return "❌ Coordenadas inválidas. Use números: /cc move 500 300";
      }

      try {
        const result = await computerUseClient.moveMouse(xNum, yNum);
        return `✅ Mouse movido para: (${xNum}, ${yNum})\n${JSON.stringify(result, null, 2)}`;
      } catch (error) {
        throw new Error(
          `Erro ao mover mouse: ${error instanceof Error ? error.message : "Desconhecido"}`
        );
      }
    },
  },
  {
    command: "click",
    description: "Clicar com botão do mouse (left/right/middle)",
    args: ["button?"],
    handler: async ([button = "left"]) => {
      if (!["left", "right", "middle"].includes(button)) {
        return "❌ Botão inválido. Use: left, right ou middle";
      }

      try {
        const result = await computerUseClient.click(
          button as "left" | "right" | "middle"
        );
        return `✅ Clique ${button} executado\n${JSON.stringify(result, null, 2)}`;
      } catch (error) {
        throw new Error(
          `Erro ao clicar: ${error instanceof Error ? error.message : "Desconhecido"}`
        );
      }
    },
  },
  {
    command: "doubleclick",
    description: "Duplo clique",
    handler: async () => {
      try {
        const result = await computerUseClient.doubleClick();
        return `✅ Duplo clique executado\n${JSON.stringify(result, null, 2)}`;
      } catch (error) {
        throw new Error(
          `Erro ao duplo clicar: ${error instanceof Error ? error.message : "Desconhecido"}`
        );
      }
    },
  },
  {
    command: "type",
    description: "Digitar texto",
    args: ["text..."],
    handler: async (args) => {
      const text = args.join(" ");
      if (!text) {
        return "❌ Texto não fornecido. Use: /cc type Olá mundo";
      }

      try {
        const result = await computerUseClient.type(text);
        return `✅ Texto digitado: "${text}"\n${JSON.stringify(result, null, 2)}`;
      } catch (error) {
        throw new Error(
          `Erro ao digitar: ${error instanceof Error ? error.message : "Desconhecido"}`
        );
      }
    },
  },
  {
    command: "key",
    description: "Pressionar tecla (Enter, Escape, Ctrl+C, etc)",
    args: ["key"],
    handler: async ([key]) => {
      if (!key) {
        return "❌ Tecla não fornecida. Use: /cc key Enter";
      }

      try {
        const result = await computerUseClient.pressKey(key);
        return `✅ Tecla pressionada: ${key}\n${JSON.stringify(result, null, 2)}`;
      } catch (error) {
        throw new Error(
          `Erro ao pressionar tecla: ${error instanceof Error ? error.message : "Desconhecido"}`
        );
      }
    },
  },
  {
    command: "tools",
    description: "Listar todas as ferramentas disponíveis",
    handler: async () => {
      const result = await computerUseClient.listTools();
      const tools = result.tools || [];
      return `✅ ${tools.length} ferramentas disponíveis:\n${tools
        .map((t: any) => `  • ${t.name}`)
        .join("\n")}`;
    },
  },
  {
    command: "help",
    description: "Mostrar ajuda dos comandos /cc",
    handler: () => {
      const helpText = [
        "🖥️ **Comandos Computer Control disponíveis:**",
        "",
        ...computerUseCommands.map((cmd) => {
          const argsText = cmd.args
            ? ` ${cmd.args.map((a) => `<${a}>`).join(" ")}`
            : "";
          return `  **/cc ${cmd.command}${argsText}** - ${cmd.description}`;
        }),
        "",
        "📝 **Exemplos:**",
        "  /cc screenshot",
        "  /cc cursor",
        "  /cc move 500 300",
        "  /cc click left",
        "  /cc type Hello World",
        "  /cc key Enter",
        "  /cc openword",
        "  /cc openapp notepad",
      ];
      return Promise.resolve(helpText.join("\n"));
    },
  },
  {
    command: "status",
    description: "Verificar status do Computer-Use MCP",
    handler: async () => {
      try {
        const result = await computerUseClient.listTools();
        const tools = result.tools || [];
        return `✅ Computer-Use MCP conectado!\n📊 ${tools.length} ferramentas disponíveis\n\n${tools
          .map((t: any) => `• ${t.name}`)
          .join("\n")}`;
      } catch (error) {
        return `❌ Computer-Use MCP não conectado\n\nErro: ${error instanceof Error ? error.message : "Desconhecido"}\n\n💡 Verifique os logs do terminal`;
      }
    },
  },
  {
    command: "openword",
    description: "Abre o Microsoft Word (Win+S > word > Enter)",
    handler: async () => {
      try {
        // 1. Pressiona Win+S para abrir busca
        await computerUseClient.pressKey("Meta+s");
        await new Promise((resolve) => setTimeout(resolve, 800));

        // 2. Digita "word"
        await computerUseClient.type("word");
        await new Promise((resolve) => setTimeout(resolve, 500));

        // 3. Pressiona Enter
        await computerUseClient.pressKey("Return");

        return `✅ Abrindo Microsoft Word...\n\n📝 Sequência executada:\n1. Win+S (Busca)\n2. Digitou "word"\n3. Enter`;
      } catch (error) {
        throw new Error(
          `Erro ao abrir Word: ${error instanceof Error ? error.message : "Desconhecido"}`
        );
      }
    },
  },
  {
    command: "openapp",
    description: "Abre qualquer aplicativo (Win+S > app > Enter)",
    args: ["appname"],
    handler: async ([appName]) => {
      if (!appName) {
        return "❌ Nome do app não fornecido. Use: /cc openapp word";
      }

      try {
        // 1. Pressiona Win+S para abrir busca
        await computerUseClient.pressKey("Meta+s");
        await new Promise((resolve) => setTimeout(resolve, 800));

        // 2. Digita o nome do app
        await computerUseClient.type(appName);
        await new Promise((resolve) => setTimeout(resolve, 500));

        // 3. Pressiona Enter
        await computerUseClient.pressKey("Return");

        return `✅ Abrindo "${appName}"...\n\n📝 Sequência executada:\n1. Win+S (Busca)\n2. Digitou "${appName}"\n3. Enter`;
      } catch (error) {
        throw new Error(
          `Erro ao abrir ${appName}: ${error instanceof Error ? error.message : "Desconhecido"}`
        );
      }
    },
  },
];

// Verificar se é um comando /cc
export function isComputerUseCommand(input: string): boolean {
  return input.trim().startsWith("/cc ");
}

// Regex para split (declarada no top level)
const WHITESPACE_REGEX = /\s+/;

// Processar comando /cc
export function processComputerUseCommand(
  input: string
): Promise<{ success: boolean; message: string }> {
  // Verificar se está no Electron
  if (!isElectron() || !hasComputerUse()) {
    return Promise.resolve({
      success: false,
      message: "❌ Comandos /cc só estão disponíveis no Electron Desktop App",
    });
  }

  // Parse do comando
  const parts = input.trim().split(WHITESPACE_REGEX);
  const [_cc, commandName, ...args] = parts;

  if (!commandName) {
    return Promise.resolve({
      success: false,
      message: "❌ Comando não especificado. Use: /cc help",
    });
  }

  // Buscar comando
  const command = computerUseCommands.find(
    (cmd) => cmd.command === commandName
  );

  if (!command) {
    return Promise.resolve({
      success: false,
      message: `❌ Comando desconhecido: ${commandName}\nUse: /cc help`,
    });
  }

  // Executar comando
  return command
    .handler(args)
    .then((result) => ({
      success: true,
      message: result,
    }))
    .catch((error) => {
      console.error("[Computer-Use Command] Erro:", error);
      return {
        success: false,
        message: `❌ Erro ao executar comando: ${error instanceof Error ? error.message : String(error)}`,
      };
    });
}
