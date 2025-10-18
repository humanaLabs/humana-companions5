# 10 - Checklist Completo de Migração

## 📋 Uso deste Checklist

- ✅ Marque cada item conforme completa
- ⚠️ Não pule etapas - são sequenciais
- 🔄 Teste após cada seção principal
- 📝 Anote problemas encontrados

---

## 🎯 Pré-Migração

### Preparação (Etapa 01)

- [ ] Node.js 18+ instalado e funcionando
- [ ] pnpm 8+ instalado (ou npm/yarn)
- [ ] Projeto Next.js atual funcionando: `pnpm dev`
- [ ] Build atual funciona: `pnpm build`
- [ ] Git configurado, working directory limpo
- [ ] Branch de migração criada: `feature/electron-migration`
- [ ] Backup/tag criado
- [ ] .gitignore atualizado com regras Electron
- [ ] Build tools instaladas:
  - [ ] Windows: Visual Studio Build Tools
  - [ ] macOS: Xcode CLI Tools
  - [ ] Linux: build-essential

**Teste**: `git status` deve mostrar working tree clean.

---

## 📂 Estrutura de Arquivos (Etapa 02)

### Diretórios Criados

- [ ] `electron/main/` criado
- [ ] `electron/main/mcp/` criado
- [ ] `electron/preload/` criado
- [ ] `electron/types/` criado
- [ ] `lib/runtime/` criado (ou verificado se existe)

### Arquivos Placeholders Criados

#### Electron Main
- [ ] `electron/main/index.ts`
- [ ] `electron/main/window.ts`
- [ ] `electron/main/utils.ts`
- [ ] `electron/main/mcp/index.ts`
- [ ] `electron/main/mcp/handlers.ts`
- [ ] `electron/main/mcp/manager.ts`

#### Preload e Types
- [ ] `electron/preload/index.ts`
- [ ] `electron/types/native.d.ts`
- [ ] `electron/tsconfig.json`

#### Runtime
- [ ] `lib/runtime/detection.ts`
- [ ] `lib/runtime/electron-client.ts`
- [ ] `lib/runtime/playwright-commands.ts`

**Teste**: `ls -R electron lib/runtime` deve mostrar todos os arquivos.

---

## 📦 Dependências (Etapa 03)

### Pacotes Instalados

#### Produção
- [ ] `@modelcontextprotocol/sdk` instalado
- [ ] `@playwright/mcp` instalado

#### Desenvolvimento
- [ ] `electron` instalado
- [ ] `electron-builder` instalado
- [ ] `concurrently` instalado
- [ ] `wait-on` instalado
- [ ] `cross-env` instalado

### Configuração package.json

- [ ] Campo `"main": "electron/main/index.js"` adicionado
- [ ] Scripts electron adicionados:
  - [ ] `electron:compile`
  - [ ] `electron:watch`
  - [ ] `electron:start`
  - [ ] `electron:dev`
  - [ ] `electron:build`
  - [ ] `dist:win`, `dist:mac`, `dist:linux`
- [ ] Seção `"build"` configurada (electron-builder)
- [ ] `appId` e `productName` personalizados

### Configuração TypeScript

- [ ] `tsconfig.json` (raiz) atualizado com `electron/**/*` em `include`
- [ ] Path alias `@electron/*` configurado (opcional)
- [ ] `electron/tsconfig.json` criado

**Teste**: `pnpm electron:compile` deve executar sem erros.

---

## ⚡ Electron Core (Etapa 04)

### Arquivos Implementados

- [ ] `electron/main/utils.ts` implementado
  - [ ] `isDevelopment()` funcional
  - [ ] `getStartUrl()` com URL correta (localhost em dev)
- [ ] `electron/main/window.ts` implementado
  - [ ] Configurações de segurança (`nodeIntegration: false`, etc)
  - [ ] Allowlist de navegação configurada
  - [ ] Preload path correto
- [ ] `electron/main/index.ts` implementado
  - [ ] Bootstrap principal
  - [ ] Ciclo de vida (ready, quit, activate)
  - [ ] `getMainWindow()` exportado
- [ ] `electron/preload/index.ts` implementado
  - [ ] `window.env` exposto
  - [ ] `window.mcp` exposto
  - [ ] Log de confirmação
- [ ] `electron/types/native.d.ts` implementado
  - [ ] Tipos para `window.env`
  - [ ] Tipos para `window.mcp`

### Compilação e Teste

- [ ] `pnpm electron:compile` sem erros
- [ ] Arquivos `.js` gerados em `electron/main/` e `electron/preload/`
- [ ] Next.js rodando: `pnpm dev`
- [ ] Electron inicia: `pnpm electron:start`
- [ ] Janela abre com Next.js carregado
- [ ] DevTools acessível: `Ctrl+Shift+I`
- [ ] No DevTools: `window.env.isElectron === true`
- [ ] No DevTools: `window.mcp` existe
- [ ] Allowlist de navegação funciona (bloqueia domínios externos)

**Teste**: Script completo `pnpm electron:dev` funciona.

---

## 🎭 MCP Playwright (Etapa 05)

### Arquivos Implementados

- [ ] `electron/main/mcp/index.ts` implementado
  - [ ] `startMcp()` com StdioClientTransport
  - [ ] `getMcpClient()` funcional
  - [ ] `stopMcp()` implementado
- [ ] `electron/main/mcp/handlers.ts` implementado
  - [ ] `ALLOWED_TOOLS` configurado
  - [ ] `registerMcpIpc()` com handlers
  - [ ] Sanitização de argumentos
  - [ ] Validação de allowlist
- [ ] `electron/main/mcp/manager.ts` implementado
  - [ ] `MCPManager` class
  - [ ] `initializeAll()` funcional
  - [ ] `shutdownAll()` funcional
  - [ ] Singleton exportado

### Integração

- [ ] `electron/main/index.ts` atualizado
  - [ ] Import `mcpManager` e `registerMcpIpc`
  - [ ] MCP inicializado em `initialize()`
  - [ ] IPC handlers registrados
  - [ ] Shutdown em `window-all-closed` e `before-quit`

### Teste

- [ ] `pnpm electron:compile` sem erros
- [ ] `pnpm electron:dev` mostra logs MCP:
  - [ ] `[MCP] Iniciando Playwright MCP...`
  - [ ] `[MCP] Conectado com sucesso`
  - [ ] `[MCP Manager] ✅ Playwright MCP ativo`
- [ ] No DevTools: `await window.mcp.listTools()` retorna tools
- [ ] No DevTools: `await window.mcp.callTool("browser_navigate", {url: "https://google.com"})` funciona
- [ ] Browser Playwright abre e navega
- [ ] Fechar Electron: MCP desliga gracefully

**Teste**: Automação de browser funciona.

---

## 🔧 Adaptação Next.js (Etapa 06)

### Runtime Detection

- [ ] `lib/runtime/detection.ts` implementado
  - [ ] `isBrowser` definido
  - [ ] `isElectron()` funcional
  - [ ] `hasMCP()` funcional
  - [ ] `getPlatform()` funcional

### Client Wrapper

- [ ] `lib/runtime/electron-client.ts` implementado
  - [ ] `ElectronMCPClient` class
  - [ ] `listTools()` funcional
  - [ ] `callTool()` funcional
  - [ ] Métodos helper (navigateTo, screenshot, etc)
  - [ ] `mcpClient` singleton exportado

### Sistema de Comandos

- [ ] `lib/runtime/playwright-commands.ts` implementado
  - [ ] `PlaywrightCommand` type definido
  - [ ] `playwrightCommands` array com comandos:
    - [ ] `/pw navigate`
    - [ ] `/pw snapshot`
    - [ ] `/pw screenshot`
    - [ ] `/pw close`
    - [ ] `/pw tools`
    - [ ] `/pw help`
    - [ ] `/pw status`
  - [ ] `isPlaywrightCommand()` funcional
  - [ ] `processPlaywrightCommand()` funcional

### Teste

- [ ] TypeScript compila sem erros: `pnpm build` ou `tsc --noEmit`
- [ ] No browser web: `window.env === undefined`
- [ ] No Electron: `window.env.isElectron === true`
- [ ] Funções de detection funcionam em ambos ambientes

**Teste**: Detection funciona corretamente.

---

## 🎨 Integração UI (Etapa 07)

### Componente MCPMenu

- [ ] `components/mcp-menu.tsx` criado
- [ ] Feature detection implementada (return null no browser)
- [ ] Estado de loading implementado
- [ ] Quick actions com botões:
  - [ ] Navigate
  - [ ] Snapshot
  - [ ] Close
- [ ] Feedback via toast notifications
- [ ] Estados de loading/executing
- [ ] Tratamento de erros

### Integração na Sidebar

- [ ] MCPMenu importado no componente sidebar
- [ ] MCPMenu renderizado em posição apropriada
- [ ] Layout não quebrou

### Interceptação de Comandos /pw

- [ ] Input de chat identificado
- [ ] Import `isPlaywrightCommand` e `processPlaywrightCommand`
- [ ] Interceptação implementada em `handleSubmit`:
  - [ ] Detecta comando antes de submit normal
  - [ ] Limpa input
  - [ ] Processa comando
  - [ ] Mostra loading toast
  - [ ] Mostra resultado via toast
  - [ ] Return para não continuar submit
- [ ] Timeout de segurança (10s)

### Teste

#### Browser Web
- [ ] App funciona normalmente
- [ ] MCPMenu **não** aparece
- [ ] Comandos `/pw` não funcionam (esperado)
- [ ] Nenhum erro no console

#### Electron
- [ ] MCPMenu aparece
- [ ] Botões funcionam:
  - [ ] Navigate → Browser navega
  - [ ] Snapshot → Toast sucesso
  - [ ] Close → Browser fecha
- [ ] Toast notifications aparecem
- [ ] Comandos `/pw` funcionam:
  - [ ] `/pw help` → Lista comandos
  - [ ] `/pw status` → Mostra status
  - [ ] `/pw navigate github.com` → Navega
  - [ ] `/pw screenshot` → Salva screenshot
- [ ] Nenhum erro no console

**Teste**: UI funciona em ambos ambientes sem quebrar.

---

## 📦 Build e Deploy (Etapa 08)

### Build Next.js

- [ ] `pnpm build` executa sem erros
- [ ] Pasta `.next/` criada
- [ ] `pnpm start` funciona

### Build Electron

- [ ] `pnpm electron:compile` sem erros
- [ ] Arquivos `.js` gerados
- [ ] `pnpm electron:build` funciona
- [ ] Pasta `electron-dist/` criada

### Builds por Plataforma

- [ ] Windows: `pnpm dist:win`
  - [ ] `.exe` instalador criado
  - [ ] Instalador testado localmente
- [ ] macOS: `pnpm dist:mac` (se aplicável)
  - [ ] `.dmg` criado
  - [ ] App testado
- [ ] Linux: `pnpm dist:linux` (se aplicável)
  - [ ] `.AppImage` criado
  - [ ] App testado

### Configuração

- [ ] Ícone personalizado:
  - [ ] `public/icon.ico` (Windows)
  - [ ] `public/icon.icns` (macOS)
  - [ ] `public/icon.png` (Linux)
- [ ] `appId` e `productName` personalizados
- [ ] URL de produção configurada em `getStartUrl()` (se necessário)
- [ ] Files excludidos desnecessários em `package.json`

### Teste Instalador

- [ ] Instalador executa sem erros
- [ ] App instalado funciona:
  - [ ] Abre normalmente
  - [ ] Next.js carrega (localhost OU produção)
  - [ ] MCP funciona
  - [ ] Menu MCP aparece
  - [ ] Comandos `/pw` funcionam
  - [ ] Ícone correto
  - [ ] Nome correto

**Teste**: Instalador funciona end-to-end.

---

## ✅ Validação Final

### Funcionalidade Completa

#### Browser Web
- [ ] App Next.js funciona 100% normal
- [ ] Todas as funcionalidades existentes OK
- [ ] Rotas funcionam
- [ ] API routes funcionam
- [ ] Autenticação funciona (se tiver)
- [ ] Database funciona (se tiver)
- [ ] MCPMenu não aparece (correto)
- [ ] Nenhum erro no console

#### Electron Desktop
- [ ] App abre normalmente
- [ ] Next.js carrega
- [ ] Todas as funcionalidades web funcionam
- [ ] MCPMenu aparece
- [ ] Botões MCP funcionam
- [ ] Comandos `/pw` funcionam
- [ ] Browser Playwright funciona:
  - [ ] Navega para URLs
  - [ ] Captura snapshots
  - [ ] Tira screenshots
  - [ ] Fecha corretamente
- [ ] Toast notifications funcionam
- [ ] Performance aceitável (< 1GB RAM, < 10s startup)

### Documentação e Código

- [ ] Código commitado:
  - [ ] `git add .`
  - [ ] `git commit -m "feat: add electron + mcp playwright"`
- [ ] README atualizado (opcional)
- [ ] .gitignore com regras Electron
- [ ] Nenhum arquivo sensível commitado
- [ ] Build artifacts em .gitignore

### Deploy

- [ ] Build de produção testado
- [ ] Instaladores prontos para distribuição
- [ ] Releases criadas (GitHub, site, etc)
- [ ] Documentação de usuário (como instalar, usar)

---

## 🎉 Migração Completa!

### Conquistas

✅ Electron + Next.js híbrido funcionando  
✅ MCP Playwright integrado  
✅ Comandos `/pw` funcionais  
✅ Menu MCP na UI  
✅ Zero mudanças destrutivas  
✅ Build e distribuição configurados  

### Próximos Passos (Opcional)

- [ ] Implementar auto-update (electron-updater)
- [ ] Code signing (macOS/Windows)
- [ ] CI/CD para builds automáticos
- [ ] Adicionar mais comandos `/pw`
- [ ] Adicionar mais MCPs (filesystem, etc)
- [ ] Temas/customização do menu MCP
- [ ] Analytics e telemetria
- [ ] Crash reporting

### Métricas de Sucesso

- **Arquivos novos**: ~12 arquivos TypeScript
- **Linhas de código**: ~650 linhas
- **Tempo de migração**: ~5-6 horas
- **Breaking changes**: 0 (zero)
- **Funcionalidades quebradas**: 0 (zero)

---

## 📝 Notas Finais

**Manutenção**:
- Web deploy: Normal, sem mudanças
- Desktop deploy: Apenas quando mudar código Electron
- Updates Next.js: Refletem automaticamente no desktop (se usar URL remota)

**Suporte**:
- Documentação: `docs/migra-next-electron/`
- Troubleshooting: `09-troubleshooting.md`
- Issues: GitHub do projeto

---

## 🆘 Se Algo Não Funcionar

1. Verificar seção específica neste checklist
2. Consultar `09-troubleshooting.md`
3. Revisar logs (Electron terminal + DevTools)
4. Recompilar: `pnpm electron:compile`
5. Reinstalar: `pnpm install`
6. Criar issue no GitHub

---

**Status**: ✅ Migração Completa e Validada

**Parabéns! 🎉 Seu app Next.js agora é também um app desktop com automação de browser!**

