/*
╔══════════════════════════════════════════════════════════════════════════╗
║                                                                          ║
║  ⚠️  ⚠️  ⚠️  ATENÇÃO! ADAPTAÇÃO NECESSÁRIA! ⚠️  ⚠️  ⚠️                ║
║                                                                          ║
╚══════════════════════════════════════════════════════════════════════════╝

❌ ❌ ❌ NÃO COPIE ESTE ARQUIVO CEGAMENTE! ❌ ❌ ❌

Este arquivo TEM DEPENDÊNCIAS ESPECÍFICAS que podem NÃO existir no seu projeto!

╔══════════════════════════════════════════════════════════════════════════╗
║  DEPENDÊNCIAS REQUERIDAS:                                                ║
╠══════════════════════════════════════════════════════════════════════════╣
║                                                                          ║
║  1. shadcn/ui Button                                                     ║
║     import { Button } from "./ui/button"                                 ║
║     → Se não tiver: Substitua pelo SEU componente Button                ║
║     → Ou use <button> HTML simples                                       ║
║                                                                          ║
║  2. sonner (Toast Notifications)                                         ║
║     import { toast } from "sonner"                                       ║
║     → Se não tiver: pnpm add sonner                                      ║
║     → Ou substitua por alert() / console.log                             ║
║     → Ou use seu sistema de notificação                                  ║
║                                                                          ║
║  3. lucide-react (Ícones)                                                ║
║     import { Camera, Chrome, Loader2, X } from "lucide-react"            ║
║     → Se não tiver: pnpm add lucide-react                                ║
║     → Ou use react-icons, heroicons, ou emojis                           ║
║                                                                          ║
║  4. Tailwind CSS                                                         ║
║     className="border-gray-200 p-4 ..."                                  ║
║     → Se não tiver: Substitua por CSS modules ou styled-components       ║
║                                                                          ║
╚══════════════════════════════════════════════════════════════════════════╝

✅ ✅ ✅ CHECKLIST ANTES DE USAR: ✅ ✅ ✅

  [ ] Verificou se tem shadcn/ui Button?
  [ ] Verificou se tem sonner instalado?
  [ ] Verificou se tem lucide-react instalado?
  [ ] Verificou se usa Tailwind CSS?
  [ ] Adaptou os imports se necessário?
  [ ] Testou o componente no seu projeto?

⚠️ SE ALGUM ITEM ACIMA FOR "NÃO", VOCÊ PRECISA ADAPTAR O CÓDIGO!

📖 VER: docs/migra-next-electron/AVISOS-ADAPTACAO.md
📖 VER: docs/migra-next-electron/07-integracao-ui.md (Seção 5 - Customizações)

╔══════════════════════════════════════════════════════════════════════════╗
║                                                                          ║
║  IMPORTANTE: Este é um MODELO FUNCIONAL, não código universal!          ║
║  Adapte conforme a stack do SEU projeto!                                ║
║                                                                          ║
╚══════════════════════════════════════════════════════════════════════════╝
*/

"use client";

// ⚠️ ADAPTAR: Se não usar lucide-react, substitua pelos seus ícones
import { Camera, Chrome, Loader2, X } from "lucide-react";
import { useCallback, useEffect, useState } from "react";

// ⚠️ ADAPTAR: Se não usar sonner, substitua pelo seu sistema de toast
import { toast } from "sonner";

import { hasMCP, isElectron } from "@/lib/runtime/detection";
import { mcpClient } from "@/lib/runtime/electron-client";

// ⚠️ ADAPTAR: Substitua pelo SEU componente Button ou use <button>
import { Button } from "./ui/button";

export function MCPMenu() {
  const [tools, setTools] = useState<any[]>([]);
  const [loading, setLoading] = useState(false);
  const [executing, setExecuting] = useState<string | null>(null);

  const loadTools = useCallback(async () => {
    setLoading(true);
    try {
      const result = await mcpClient.listTools();
      setTools(result.tools ?? []);
    } catch (error) {
      console.error("Erro ao carregar tools MCP:", error);
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    if (isElectron() && hasMCP()) {
      loadTools();
    }
  }, [loadTools]);

  async function executeAction(action: string) {
    setExecuting(action);
    try {
      let result;

      switch (action) {
        case "navigate":
          const url = prompt("Digite a URL para navegar:");
          if (!url) return;
          result = await mcpClient.callTool("browser_navigate", { url });
          toast.success("Navegação iniciada!", {
            description: `Abrindo: ${url}`,
          });
          break;

        case "snapshot":
          result = await mcpClient.callTool("browser_snapshot", {});
          toast.success("Snapshot capturado!", {
            description: "Estrutura da página coletada",
          });
          break;

        case "screenshot":
          result = await mcpClient.callTool("browser_take_screenshot", {});
          toast.success("Screenshot capturado!", {
            description: "Imagem salva com sucesso",
          });
          break;

        case "close":
          result = await mcpClient.callTool("browser_close", {});
          toast.success("Browser fechado!", {
            description: "Página fechada com sucesso",
          });
          break;

        default:
          console.warn("Ação não implementada:", action);
      }

      console.log(`[MCP Menu] ${action} result:`, result);
    } catch (error) {
      console.error(`[MCP Menu] Erro ao executar ${action}:`, error);
      toast.error("Erro ao executar comando", {
        description:
          error instanceof Error ? error.message : "Erro desconhecido",
      });
    } finally {
      setExecuting(null);
    }
  }

  // Não renderizar se não estiver no Electron
  if (!isElectron() || !hasMCP()) {
    return null;
  }

  return (
    <div className="border-gray-200 border-b p-4 dark:border-gray-800">
      <div className="mb-3 flex items-center justify-between">
        <div className="flex items-center gap-2">
          <Chrome className="h-4 w-4" />
          <h3 className="font-semibold text-sm">Browser Control</h3>
        </div>
        {tools.length > 0 && (
          <span className="text-gray-500 text-xs">{tools.length} tools</span>
        )}
      </div>

      {loading ? (
        <div className="flex items-center gap-2 text-gray-500 text-xs">
          <Loader2 className="h-3 w-3 animate-spin" />
          <span>Carregando...</span>
        </div>
      ) : (
        <div className="flex flex-col gap-2">
          <Button
            size="sm"
            variant="outline"
            onClick={() => executeAction("navigate")}
            disabled={executing !== null}
            className="justify-start"
          >
            {executing === "navigate" ? (
              <>
                <Loader2 className="mr-2 h-3 w-3 animate-spin" />
                Navegando...
              </>
            ) : (
              <>
                <Chrome className="mr-2 h-3 w-3" />
                Navegar
              </>
            )}
          </Button>

          <Button
            size="sm"
            variant="outline"
            onClick={() => executeAction("snapshot")}
            disabled={executing !== null}
            className="justify-start"
          >
            {executing === "snapshot" ? (
              <>
                <Loader2 className="mr-2 h-3 w-3 animate-spin" />
                Capturando...
              </>
            ) : (
              <>
                <Camera className="mr-2 h-3 w-3" />
                Snapshot
              </>
            )}
          </Button>

          <Button
            size="sm"
            variant="outline"
            onClick={() => executeAction("screenshot")}
            disabled={executing !== null}
            className="justify-start"
          >
            {executing === "screenshot" ? (
              <>
                <Loader2 className="mr-2 h-3 w-3 animate-spin" />
                Capturando...
              </>
            ) : (
              <>
                <Camera className="mr-2 h-3 w-3" />
                Screenshot
              </>
            )}
          </Button>

          <Button
            size="sm"
            variant="outline"
            onClick={() => executeAction("close")}
            disabled={executing !== null}
            className="justify-start"
          >
            {executing === "close" ? (
              <>
                <Loader2 className="mr-2 h-3 w-3 animate-spin" />
                Fechando...
              </>
            ) : (
              <>
                <X className="mr-2 h-3 w-3" />
                Fechar
              </>
            )}
          </Button>
        </div>
      )}
    </div>
  );
}
