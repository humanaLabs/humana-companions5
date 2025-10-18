# 07 - Integração com UI

## ✅ Objetivos desta Etapa

- Criar componente MCPMenu (menu visual com botões)
- Integrar menu na sidebar existente
- Tudo opcional e não-destrutivo
- **APENAS menu** - sem integração no chat/input

---

## ⚠️ Importante: Adaptação ao SEU Projeto

Esta etapa é **altamente específica** do seu projeto. Os exemplos assumem:
- Sidebar existente (ou local para adicionar o menu)
- Sistema de toast para notificações (sonner)

**Adapte conforme sua estrutura!**

**Foco**: Adicionar menu MCP com botões para controlar Playwright.  
**Sem**: Comandos `/pw` no chat - apenas menu visual.

---

## 🎨 1. Criar components/mcp-menu.tsx

**Menu visual com botões quick-action**

### 1.1 Código Completo

```typescript
"use client";

import { Camera, Chrome, Loader2, X } from "lucide-react";
import { useCallback, useEffect, useState } from "react";
import { toast } from "sonner"; // Ajuste se usar outro toast
import { hasMCP, isElectron } from "@/lib/runtime/detection";
import { mcpClient } from "@/lib/runtime/electron-client";
import { Button } from "./ui/button"; // Ajuste para seu componente Button

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
```

### 1.2 Explicação do Código

**Feature Detection** (linha 87-90):
- Retorna `null` se não estiver no Electron
- Componente não renderiza no browser web
- Zero impacto na versão web

**Estados**:
- `loading` - Carregando lista de tools
- `executing` - Qual ação está executando (loading state)
- `tools` - Lista de ferramentas MCP disponíveis

**Actions** (função `executeAction`):
- `navigate` - Abre prompt para URL e navega
- `snapshot` - Captura estrutura da página
- `screenshot` - Tira screenshot
- `close` - Fecha browser

**Feedback**:
- Loading state nos botões durante execução
- Toast notifications (sucesso/erro)
- Disable de todos os botões durante execução

⚠️ **Personalize**:
- Classes CSS (Tailwind)
- Componente `Button` (ajuste para seu design system)
- Sistema de toast (se não usar sonner)
- Ícones (lucide-react ou sua biblioteca)

---

## 🔌 2. Integrar Menu na Sidebar

**⚠️ IMPORTANTE**: NÃO copie nenhum `app-sidebar.tsx` do projeto de referência!  
Você vai **editar o sidebar que JÁ EXISTE** no seu projeto.

**Exemplo de como integrar no SEU sidebar existente**:

Se seu projeto tem sidebar (`components/app-sidebar.tsx` ou similar), adicione MCPMenu:

```typescript
"use client";

import { MCPMenu } from "@/components/mcp-menu"; // Importar

// ... resto dos imports

export function AppSidebar() {
  // ... código existente

  return (
    <Sidebar>
      <SidebarHeader>
        {/* Logo, título, etc */}
        <h1>Meu App</h1>
        
        {/* 🆕 Adicionar MCPMenu */}
        <MCPMenu />
      </SidebarHeader>
      
      <SidebarContent>
        {/* Conteúdo da sidebar (histórico, etc) */}
      </SidebarContent>
      
      <SidebarFooter>
        {/* Footer (user, config, etc) */}
      </SidebarFooter>
    </Sidebar>
  );
}
```

**💡 Explicação**:

**Como integrar no SEU projeto**:
1. ✅ Abra o componente sidebar que JÁ EXISTE no seu projeto
2. ✅ Adicione o import: `import { MCPMenu } from "@/components/mcp-menu";`
3. ✅ Adicione `<MCPMenu />` onde fizer sentido na sua UI
4. ❌ NÃO copie o `app-sidebar.tsx` do projeto de referência (vai conflitar!)

**Onde adicionar**:
- Pode ser no header, body, ou footer da sidebar
- No exemplo acima, está no `SidebarHeader`
- Componente não renderiza no browser (feature detection)
- Escolha o local mais apropriado para sua UI

⚠️ **Personalize**: Ajuste conforme sua estrutura de sidebar.

---

## 📝 3. Exemplo de Integração Mínima

Se não tiver sidebar complexa, pode adicionar em qualquer lugar:

### Opção 1: Layout Principal

**app/layout.tsx**:

```typescript
import { MCPMenu } from "@/components/mcp-menu";

export default function RootLayout({ children }) {
  return (
    <html>
      <body>
        <div className="flex">
          {/* Sidebar simples */}
          <aside className="w-64 border-r p-4">
            <MCPMenu />
          </aside>
          
          {/* Conteúdo principal */}
          <main className="flex-1">
            {children}
          </main>
        </div>
      </body>
    </html>
  );
}
```

### Opção 2: Página Específica

**app/page.tsx**:

```typescript
import { MCPMenu } from "@/components/mcp-menu";

export default function HomePage() {
  return (
    <div>
      <div className="mb-4">
        <MCPMenu />
      </div>
      {/* Resto do conteúdo */}
    </div>
  );
}
```

### Opção 3: Floating Menu

**app/layout.tsx** (menu flutuante):

```typescript
import { MCPMenu } from "@/components/mcp-menu";

export default function RootLayout({ children }) {
  return (
    <html>
      <body>
        {/* Menu flutuante no canto */}
        <div className="fixed top-4 right-4 z-50 bg-white shadow-lg rounded-lg">
          <MCPMenu />
        </div>
        
        {children}
      </body>
    </html>
  );
}
```

---

## ✅ 4. Validação da Integração

### 4.1 Testar no Browser (Web)

```bash
pnpm dev
# Abrir http://localhost:3000
```

**Verificar**:
- ✅ App funciona normalmente
- ✅ MCPMenu **não** aparece (feature detection)
- ✅ Nenhum erro no console
- ✅ Zero impacto na versão web

### 4.2 Testar no Electron

```bash
pnpm electron:dev
```

**Verificar**:
- ✅ MCPMenu aparece no local configurado
- ✅ Título "Browser Control" visível
- ✅ Lista de ferramentas carregada
- ✅ Botões renderizados corretamente

### 4.3 Testes Funcionais

**Testar cada botão**:

1. **Navigate**:
   ```
   - Clicar no botão
   - Inserir URL (ex: https://google.com)
   - Verificar: toast de sucesso
   - Verificar: navegação aconteceu (se tiver browser aberto)
   ```

2. **Snapshot**:
   ```
   - Navegar para uma página primeiro
   - Clicar em Snapshot
   - Verificar: toast de sucesso
   - Verificar: logs no console com dados
   ```

3. **Screenshot**:
   ```
   - Navegar para uma página primeiro
   - Clicar em Screenshot
   - Verificar: toast de sucesso
   - Verificar: arquivo salvo (checar logs)
   ```

4. **Close**:
   ```
   - Ter uma página aberta
   - Clicar em Close
   - Verificar: toast de sucesso
   - Verificar: página fechou
   ```

### 4.4 Validar Estados

**Loading State**:
- Botão mostra "Carregando..." ou spinner
- Outros botões desabilitados
- UI responsiva

**Error Handling**:
- Toast de erro aparece quando falha
- App não quebra
- Pode tentar novamente

---

## 🎨 5. Customizações Opcionais

### 5.1 Adicionar Mais Ações

Edite `mcp-menu.tsx`, adicione case no `executeAction`:

```typescript
case "back":
  result = await mcpClient.callTool("browser_navigate_back", {});
  toast.success("Voltou!", { description: "Página anterior" });
  break;

case "forward":
  result = await mcpClient.callTool("browser_navigate_forward", {});
  toast.success("Avançou!", { description: "Próxima página" });
  break;

case "refresh":
  result = await mcpClient.callTool("browser_refresh", {});
  toast.success("Recarregou!", { description: "Página atualizada" });
  break;
```

E adicione os botões correspondentes no JSX.

### 5.2 Estilização Custom

**Tema Dark/Light**:
```typescript
<div className="border-b p-4 bg-white dark:bg-gray-900">
  {/* conteúdo */}
</div>
```

**Cores Custom**:
```typescript
<Button
  variant="outline"
  className="bg-blue-50 hover:bg-blue-100 text-blue-600"
>
  Navegar
</Button>
```

### 5.3 Ícones Diferentes

Se não usar `lucide-react`, substitua:

```typescript
// Heroicons
import { GlobeAltIcon, CameraIcon } from "@heroicons/react/24/outline";

// React Icons
import { FaChrome, FaCamera } from "react-icons/fa";

// Ou emojis
<span className="mr-2">🌐</span>
```

---

## 🐛 6. Troubleshooting

### Menu não aparece no Electron

**Debug**:
```typescript
// Adicionar no mcp-menu.tsx
useEffect(() => {
  console.log("isElectron():", isElectron());
  console.log("hasMCP():", hasMCP());
  console.log("window.mcp:", window.mcp);
}, []);
```

**Verificar**:
- `isElectron()` deve retornar `true`
- `hasMCP()` deve retornar `true`
- `window.mcp` deve existir

**Solução**:
- Verificar preload script carregou (`electron/preload/index.ts`)
- Verificar MCP está rodando (logs do Electron)

### Botões não funcionam

**Verificar**:
```bash
# No console do DevTools (Electron)
await window.mcp.listTools()
await window.mcp.callTool("browser_navigate", { url: "https://google.com" })
```

**Se falhar**:
- Ver logs do terminal (processo Electron)
- Verificar MCP Playwright iniciou corretamente
- Verificar allowlist em `electron/main/mcp/handlers.ts`

### Toast não aparece

**Verificar**:
- `sonner` está instalado: `pnpm add sonner`
- `<Toaster />` está no layout: `import { Toaster } from "sonner";`

**Alternativa** (console.log):
```typescript
// Substituir toast por console
console.log("Sucesso:", "Navegação iniciada");
console.error("Erro:", error.message);
```

---

## 📦 7. Dependências Necessárias

```bash
# Toast notifications
pnpm add sonner

# Ícones
pnpm add lucide-react

# Se não tiver shadcn/ui Button
pnpx shadcn@latest add button
```

---

## ✅ Resumo desta Etapa

### O que fizemos

1. ✅ Criamos `components/mcp-menu.tsx` (menu visual)
2. ✅ Integramos na sidebar (ou outro local)
3. ✅ Testamos no browser (não aparece)
4. ✅ Testamos no Electron (aparece e funciona)
5. ✅ Validamos todas as ações
6. ❌ **NÃO** integramos comandos no chat (foco apenas no menu)

### Resultado

- ✅ Menu MCP funcionando no desktop
- ✅ Botões para controlar Playwright
- ✅ Feature detection (zero impacto web)
- ✅ Feedback via toast
- ✅ UI integrada no projeto

### Próximos Passos

- ✅ **Integração UI completa!**
- ➡️ Próximo: **[08-build-deploy.md](./08-build-deploy.md)** - Build e distribuição

---

**Status**: ✅ UI integrada (apenas menu, sem chat)

**Foco**: Controle via menu visual com botões.  
**Sem**: Comandos `/pw` no input de chat.
