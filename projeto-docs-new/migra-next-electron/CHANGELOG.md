# 📝 Changelog - Electron Desktop App

## [1.0.3] - 2025-10-17

### 🐛 Correções de Bugs

- **Corrigido erro ao executar comandos /pw**
  - Removida tentativa de adicionar mensagens ao chat (causava erro de filtro)
  - Implementado sistema de Toast Notifications
  - Feedback imediato: Loading → Sucesso/Erro

- **Protocolo HTTPS Automático**
  - URLs sem protocolo agora recebem `https://` automaticamente
  - `/pw navigate google.com` → `https://google.com`

### ✨ Novas Features

- **Comando `/pw status`**
  - Verifica status da conexão MCP
  - Mostra número de ferramentas disponíveis
  - Debug rápido e fácil

### 🔧 Melhorias

- **Logs de Debug Detalhados**
  - Todos os comandos logam no console
  - Facilita troubleshooting
  - Logs: `[MCP Client]`, `[Playwright Command]`

- **Tratamento de Erros Melhorado**
  - Try/catch em todas as operações
  - Mensagens de erro mais claras
  - Stack traces no console

### 📝 Arquivos Modificados

- `components/multimodal-input.tsx` - Toast notifications
- `lib/runtime/playwright-commands.ts` - Protocolo auto + /pw status
- `lib/runtime/electron-client.ts` - Logs detalhados
- `docs/PLAYWRIGHT_COMMANDS.md` - Documentação atualizada

---

## [1.0.2] - 2025-10-17

### 🎭 Comandos Playwright no Chat

- **Adicionado sistema de comandos `/pw`**
  - Controle do Playwright diretamente pelo chat
  - 6 comandos disponíveis: help, navigate, snapshot, screenshot, tools, close
  - Interceptação inteligente no input
  - Respostas diretas no chat

- **Playwright MCP Local via Stdio**
  - Instalado `@playwright/mcp@0.0.43` localmente
  - Transport stdio usando módulo local
  - Não depende mais de `npx` externo
  - Melhor desempenho e confiabilidade

### 🎨 Melhorias de UI

- **Menu MCP Tools reposicionado**
  - Movido do rodapé para o topo do sidebar
  - Visual melhorado com contador de tools
  - Bordas e espaçamento otimizados

### 📝 Arquivos Criados

- `lib/runtime/playwright-commands.ts` - Sistema de comandos /pw
- `docs/PLAYWRIGHT_COMMANDS.md` - Documentação completa

### 📝 Arquivos Modificados

- `components/app-sidebar.tsx` - MCPMenu reposicionado
- `components/mcp-menu.tsx` - Visual melhorado
- `components/multimodal-input.tsx` - Interceptação de comandos /pw
- `electron/main/mcp/index.ts` - Stdio transport local
- `package.json` - Dependência @playwright/mcp adicionada

---

## [1.0.1] - 2025-10-17

### ✨ Melhorias de Interface

- **Removido menu superior** (`autoHideMenuBar: true`)
  - Interface mais limpa e moderna
  - Barra de menu oculta por padrão
  - Pode ser acessada temporariamente com a tecla `Alt`

- **Desabilitado DevTools automático**
  - Console de debug não abre mais automaticamente
  - Pode ser aberto manualmente com `Ctrl+Shift+I` quando necessário
  - Interface mais profissional para usuários finais

### 📝 Arquivos Modificados

- `electron/main/window.ts` - Adicionado `autoHideMenuBar: true`
- `electron/main/index.ts` - Removida abertura automática do DevTools

---

## [1.0.0] - 2025-10-17

### 🎉 Release Inicial

- ✅ Implementação completa do Electron shell
- ✅ Integração com Next.js via shell remoto
- ✅ MCP (Model Context Protocol) com Playwright
- ✅ Runtime detection (web vs desktop)
- ✅ Security hardening (contextIsolation, sandbox)
- ✅ IPC handlers seguros
- ✅ Componente MCP Menu no sidebar
- ✅ Documentação completa

### 🛠️ Stack Técnica

- Electron 38.3.0
- Next.js 15.3.0-canary.31
- React 19.0.0-rc
- @modelcontextprotocol/sdk 1.20.1
- TypeScript 5.9.3

### 📦 Build System

- electron-builder configurado
- Scripts para Windows/macOS/Linux
- Suporte a desenvolvimento sem Visual Studio Build Tools

---

## Notas

- Visual Studio Build Tools é **opcional** (só para build .exe final)
- Desenvolvimento funciona 100% sem dependências nativas
- Hot reload suportado em modo development

