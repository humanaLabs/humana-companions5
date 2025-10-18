# 🚀 Guia de Migração: Next.js → Electron + MCP Playwright

**Guia completo para adicionar Electron e MCP Playwright em qualquer aplicação Next.js existente**

---

## 🎯 INÍCIO RÁPIDO

### 🚀 Migração Passo a Passo
- 🌟 **[COMECE AQUI](./00-COMECE-AQUI.md)** 🌟 - **GUIA MASTER** com testes e sequenciamento!

### ⚠️ Avisos Críticos (Ler Antes!)
- 🚨 **[LEIA PRIMEIRO](./LEIA-PRIMEIRO.md)** - Componentes que NÃO copiar
- 🚨 **[AVISOS DE ADAPTAÇÃO](./AVISOS-ADAPTACAO.md)** - O QUE adaptar antes de copiar

### 📖 Referências
- 🔄 **[MUDANÇAS IMPORTANTES](./MUDANCAS-IMPORTANTES.md)** - Simplificações feitas
- 📑 **[ÍNDICE VISUAL](./00-INDEX-VISUAL.md)** - Visão geral completa
- 📦 **[GUIA DE ARQUIVOS](./README-ARQUIVOS.md)** - Lista de arquivos

---

## 📋 Índice da Documentação

1. **[01-preparacao.md](./01-preparacao.md)** - Pré-requisitos e Preparação
2. **[02-estrutura-arquivos.md](./02-estrutura-arquivos.md)** - Estrutura de Pastas
3. **[03-dependencias.md](./03-dependencias.md)** - Instalação de Dependências
4. **[04-electron-core.md](./04-electron-core.md)** - Implementação do Electron Core
5. **[05-mcp-playwright.md](./05-mcp-playwright.md)** - Implementação do MCP Playwright
6. **[06-adaptacao-nextjs.md](./06-adaptacao-nextjs.md)** - Adaptação do Next.js
7. **[07-integracao-ui.md](./07-integracao-ui.md)** - Integração com UI
8. **[08-build-deploy.md](./08-build-deploy.md)** - Build e Distribuição
9. **[09-troubleshooting.md](./09-troubleshooting.md)** - Troubleshooting
10. **[10-checklist.md](./10-checklist.md)** - Checklist Completo
11. **[11-dev-vs-prod.md](./11-dev-vs-prod.md)** - Desenvolvimento vs Produção
12. **[12-scripts-helper-windows.md](./12-scripts-helper-windows.md)** - Scripts Helper Windows
13. **[13-arquivos-config.md](./13-arquivos-config.md)** - Arquivos de Configuração (Templates)
14. **[14-recursos-extras.md](./14-recursos-extras.md)** - Recursos Extras & Boas Práticas ⭐

---

## 🎯 O que você vai conseguir

Após seguir este guia, sua aplicação Next.js terá:

✅ **Desktop App com Electron** - Aplicativo nativo para Windows, macOS e Linux  
✅ **MCP Playwright Integrado** - Automação de browser embutida  
✅ **100% Compatibilidade Web** - Mesma base de código, zero bifurcação  
✅ **Comandos /pw** - Controle do browser via chat  
✅ **Menu MCP** - Interface visual para ferramentas Playwright  
✅ **Segurança Total** - Isolamento de processos e allowlists  
✅ **Deploy Independente** - Atualize web sem recompilar binário  

---

## 🏗️ Arquitetura em Resumo

```
┌─────────────────────────────────────────┐
│  Next.js (localhost:3000)               │
│  └─ Seu código existente + detecção     │
└─────────────────┬───────────────────────┘
                  │ BrowserWindow
                  ▼
┌─────────────────────────────────────────┐
│  Electron Main Process                  │
│  ├─ MCP Manager (Playwright)            │
│  ├─ IPC Handlers (Segurança)            │
│  └─ Context Bridge (Preload)            │
└─────────────────────────────────────────┘
```

**Filosofia**:
- **Zero Bifurcação**: Mesmo código Next.js funciona em web e desktop
- **Feature Detection**: Recursos desktop aparecem apenas quando disponíveis
- **Não-invasivo**: Não quebra funcionalidades existentes
- **Segurança First**: Isolamento completo, allowlists, validações

---

## ⚠️ Importante: Migração Não-Destrutiva

Este guia é projetado para **não quebrar nada** no seu app:

1. ✅ Todo código Next.js existente continua funcionando
2. ✅ Rotas, API routes, autenticação permanecem intactas
3. ✅ Componentes existentes não precisam de mudanças
4. ✅ Deploy web continua normal
5. ✅ Apenas **adicionamos** recursos desktop

**Princípio**: Tudo novo vai em pastas/arquivos separados. Apenas pequenas adições pontuais no código existente (sempre opcionais e com feature detection).

**Simplificação** (v1.1.0):
- ✅ **Apenas 1 componente novo** (`mcp-menu.tsx`)
- ✅ **Apenas 1 ponto de integração** (sidebar)
- ❌ **Sem modificação no chat/input** (removido)
- ✅ **Menos conflitos, mais simples!**

---

## 🕐 Tempo Estimado

| Etapa | Tempo | Dificuldade |
|-------|-------|-------------|
| Preparação | 30min | ⭐ Fácil |
| Estrutura | 15min | ⭐ Fácil |
| Dependências | 20min | ⭐ Fácil |
| Electron Core | 1h | ⭐⭐ Médio |
| MCP Playwright | 45min | ⭐⭐ Médio |
| Adaptação Next.js | 1h | ⭐⭐ Médio |
| Integração UI | 1h | ⭐⭐⭐ Avançado |
| Build & Deploy | 45min | ⭐⭐ Médio |
| **Total** | **~5-6h** | - |

*Tempo pode variar com experiência e complexidade do projeto*

---

## 📚 Pré-requisitos Técnicos

- Node.js 18+ (recomendado 20+)
- pnpm 8+ (ou npm/yarn)
- Next.js 13+ (App Router ou Pages Router)
- TypeScript (recomendado, mas não obrigatório)
- Conhecimento básico de:
  - React/Next.js
  - Electron (conceitos básicas)
  - Terminal/CLI

## 📦 Recursos Prontos

Este guia inclui **templates prontos** para copiar:
- ✅ Scripts helper Windows (`.bat`, `.ps1`)
- ✅ Configurações completas (`package.json`, `tsconfig.json`)
- ✅ `.gitignore` com regras Electron
- ✅ `.env.example` template
- ✅ Guia de ícones e assets

**Ver**: [13-arquivos-config.md](./13-arquivos-config.md)

## 🎁 Recursos Extras ⭐

**NOVO**: Documentação de recursos avançados e boas práticas:
- ⭐ **build-production.ps1** - Script de build PROFISSIONAL (UI bonita, checks, validações)
- ⭐ **electron.env.example** - Template completo com 189 linhas de variáveis
- ⭐ **biome.jsonc** - Linter/formatter 100x mais rápido que ESLint
- ⭐ **CHANGELOG.md** - Estrutura de versionamento
- ⭐ **Debugging configs** - VSCode launch.json prontos
- ⭐ **Estrutura de testes** - Playwright organizado
- ⭐ **Boas práticas** - Segurança, performance, DX

**Ver**: [14-recursos-extras.md](./14-recursos-extras.md)

---

## 🎓 Como Usar Este Guia

1. **Leia na ordem**: Os documentos são sequenciais
2. **Não pule etapas**: Cada parte depende da anterior
3. **Teste incrementalmente**: Teste após cada etapa
4. **Faça backup**: Commit antes de começar
5. **Use controle de versão**: Cada etapa = 1 commit

### 📝 Formato dos Documentos

Cada documento tem:
- ✅ **Objetivos** - O que você vai implementar
- 📋 **Conceitos** - Explicações necessárias
- 💻 **Código** - Implementação passo a passo
- 🔍 **Validação** - Como testar se funcionou
- 🚨 **Problemas Comuns** - O que pode dar errado

---

## 🔄 Fluxo de Trabalho Recomendado

```bash
# 1. Backup
git checkout -b feature/electron-migration
git commit -m "backup: before electron migration"

# 2. Seguir guia (01 → 10)
# ... implementar cada etapa ...

# 3. Testar
pnpm electron:dev

# 4. Validar
# Verificar funcionalidades web + desktop

# 5. Commit
git commit -m "feat: add electron + mcp playwright"
```

---

## 🆘 Suporte

Se encontrar problemas:

1. Consulte **[09-troubleshooting.md](./09-troubleshooting.md)**
2. Revise logs no terminal
3. Verifique console do DevTools (Ctrl+Shift+I)
4. Compare com código de referência deste projeto

---

## 📖 Começar Agora

➡️ **Próximo**: [01-preparacao.md](./01-preparacao.md) - Pré-requisitos e Preparação

---

**Boa sorte com a migração! 🚀**

