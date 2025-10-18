# 14 - Recursos Extras & Boas Práticas

## ✅ Objetivo

Documentar recursos avançados e boas práticas que este projeto implementa e que são **extremamente úteis** para o próximo projeto.

---

## 📦 1. build-production.ps1 (Script Profissional)

### 1.1 O Script Mais Completo

**Copiar `build-production.ps1` do projeto atual - É EXCELENTE!**

**Features**:
- ✅ Interface visual bonita (ASCII art)
- ✅ Verificação de requisitos (Node, pnpm, MSVS)
- ✅ Flags de configuração (Skip checks, skip tests, portable)
- ✅ Limpeza automática de builds antigos
- ✅ Feedback colorido em cada etapa
- ✅ Tratamento de erros robusto
- ✅ Exibe arquivos gerados com tamanhos
- ✅ Próximos passos após build
- ✅ Help integrado (`-Help`)

### 1.2 Uso

```powershell
# Build completo
.\build-production.ps1

# Apenas portable
.\build-production.ps1 -Portable

# Sem testes
.\build-production.ps1 -SkipTests

# Ver ajuda
.\build-production.ps1 -Help
```

### 1.3 Output Exemplo

```
╔═══════════════════════════════════════════════════════════╗
║       AI CHATBOT ELECTRON - BUILD DE PRODUÇÃO            ║
╚═══════════════════════════════════════════════════════════╝

🔍 VERIFICANDO REQUISITOS...
  → Node.js: ✅ v20.10.0
  → pnpm:    ✅ v9.12.3
  → MSVS:    ✅ 2019

✅ REQUISITOS OK!

🧹 LIMPANDO BUILDS ANTERIORES...
  ✅ electron-dist/ removido
  ✅ .next/ removido

📦 INSTALANDO DEPENDÊNCIAS...
✅ Dependências instaladas!

⚙️  BUILD NEXT.JS...
✅ Next.js buildado!

⚙️  COMPILANDO ELECTRON...
✅ Electron compilado!

🏗️  BUILDING ELECTRON...
✅ BUILD CONCLUÍDO COM SUCESSO!

📦 ARQUIVOS GERADOS:
  ✅ AI Chatbot-Setup-3.1.3.exe
     Tamanho: 187.54 MB
```

**⭐ ALTAMENTE RECOMENDADO COPIAR ESTE ARQUIVO!**

---

## 🔧 2. biome.jsonc (Linter/Formatter)

### 2.1 Configuração Ultracite

**Copiar `biome.jsonc` do projeto atual**:

```jsonc
{
  "$schema": "./node_modules/@biomejs/biome/configuration_schema.json",
  "extends": ["ultracite"],
  "files": {
    "includes": [
      "**/*",
      "!components/ui",
      "!lib/utils.ts",
      "!hooks/use-mobile.ts"
    ]
  },
  "linter": {
    "rules": {
      "suspicious": {
        "noExplicitAny": "off",
        "noUnknownAtRules": "off",
        "noConsole": "off",
        "noBitwiseOperators": "off"
      },
      "style": {
        "noMagicNumbers": "off",
        "noNestedTernary": "off"
      },
      "nursery": {
        "noUnnecessaryConditions": "off"
      },
      "complexity": {
        "noExcessiveCognitiveComplexity": "off",
        "useSimplifiedLogicExpression": "off"
      },
      "a11y": {
        "noSvgWithoutTitle": "off"
      }
    }
  }
}
```

### 2.2 Scripts package.json

```json
{
  "scripts": {
    "lint": "npx ultracite@latest check",
    "format": "npx ultracite@latest fix"
  }
}
```

### 2.3 Por Que Biome/Ultracite?

- ✅ **100x mais rápido** que ESLint + Prettier
- ✅ **Zero configuração** (extends ultracite)
- ✅ **Format + Lint** em uma ferramenta
- ✅ **Subsecond** performance
- ✅ **AI-friendly** (regras consistentes)

---

## 🎨 3. components.json (shadcn/ui)

### 3.1 Configuração

**Copiar `components.json` se usar shadcn/ui**:

```json
{
  "$schema": "https://ui.shadcn.com/schema.json",
  "style": "default",
  "rsc": true,
  "tsx": true,
  "tailwind": {
    "config": "",
    "css": "app/globals.css",
    "baseColor": "zinc",
    "cssVariables": true,
    "prefix": ""
  },
  "aliases": {
    "components": "@/components",
    "utils": "@/lib/utils",
    "ui": "@/components/ui",
    "lib": "@/lib",
    "hooks": "@/hooks"
  }
}
```

### 3.2 Comandos Úteis

```bash
# Adicionar componente
pnpx shadcn@latest add button

# Adicionar múltiplos
pnpx shadcn@latest add button card dialog

# Listar disponíveis
pnpx shadcn@latest add
```

---

## 🔐 4. electron.env.example (Template Completo)

### 4.1 Template de Variáveis de Ambiente

**Copiar `docs/electron.env.example` - É MUITO COMPLETO (189 linhas)**

**Seções incluídas**:
- 🌐 Application URLs
- 🔐 OAuth/Authentication
- 🎭 MCP Configuration
- 🛡️ Security
- 📦 Build Configuration
- 🔄 Auto Update
- 📊 Telemetry/Analytics
- 🐛 Debug/Development
- 🗄️ Database
- 🔧 Paths & Directories
- 🎨 UI Configuration
- 🚀 Performance
- 🌍 Localization

**Uso**:
```bash
# Copiar template
cp docs/electron.env.example .env.electron

# Adicionar ao .gitignore
echo ".env.electron" >> .gitignore

# Carregar no Electron
# electron/main/index.ts
import dotenv from 'dotenv';
dotenv.config({ path: '.env.electron' });
```

**⭐ TEMPLATE GOLD! Copiar completo!**

---

## 📝 5. CHANGELOG.md (Versionamento)

### 5.1 Estrutura de Changelog

**Copiar estrutura do `CHANGELOG.md`**:

```markdown
# 📝 Changelog

## [1.0.3] - 2025-10-17

### 🐛 Correções de Bugs
- **Corrigido erro X**
  - Detalhes da correção
  - Impacto

### ✨ Novas Features
- **Feature Y**
  - Como usar
  - Benefícios

### 🔧 Melhorias
- **Melhoria Z**
  - O que mudou
  - Por que mudou

### 📝 Arquivos Modificados
- `arquivo1.ts` - O que mudou
- `arquivo2.tsx` - O que mudou

---

## [1.0.2] - 2025-10-16
...
```

### 5.2 Emojis Úteis

| Emoji | Uso |
|-------|-----|
| ✨ | Nova feature |
| 🐛 | Bug fix |
| 🔧 | Melhoria |
| 📝 | Documentação |
| 🚀 | Performance |
| 🔐 | Segurança |
| 💥 | Breaking change |
| ♻️ | Refactor |
| 🎨 | UI/UX |
| 🧪 | Testes |

---

## 🧪 6. Estrutura de Testes

### 6.1 Organização (Playwright)

```
tests/
├── e2e/              # Testes end-to-end
│   ├── auth.ts       # Testes de autenticação
│   ├── chat.ts       # Testes de chat
│   └── ...
├── fixtures.ts       # Fixtures compartilhadas
├── helpers.ts        # Funções auxiliares
├── pages/            # Page Objects
│   ├── chat.ts
│   ├── login.ts
│   └── ...
└── prompts/          # Prompts de teste
    └── ...
```

### 6.2 playwright.config.ts

```typescript
import { defineConfig } from '@playwright/test';

export default defineConfig({
  testDir: './tests',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: 'html',
  use: {
    baseURL: 'http://localhost:3000',
    trace: 'on-first-retry',
  },
  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
  ],
  webServer: {
    command: 'pnpm dev',
    url: 'http://localhost:3000',
    reuseExistingServer: !process.env.CI,
  },
});
```

---

## 📦 7. Dependências Recomendadas

### 7.1 Essenciais Electron

```json
{
  "dependencies": {
    "@modelcontextprotocol/sdk": "^1.20.1",
    "@playwright/mcp": "^0.0.43",
    "sonner": "^1.5.0"
  },
  "devDependencies": {
    "electron": "^38.0.0",
    "electron-builder": "^26.0.0",
    "concurrently": "^9.0.0",
    "wait-on": "^9.0.0",
    "cross-env": "^10.0.0"
  }
}
```

### 7.2 UI/UX Recomendadas

```json
{
  "dependencies": {
    "lucide-react": "^0.446.0",
    "sonner": "^1.5.0",
    "class-variance-authority": "^0.7.1",
    "clsx": "^2.1.1",
    "tailwind-merge": "^2.5.2"
  }
}
```

---

## 🗂️ 8. Estrutura de Pastas Detalhada

### 8.1 Estrutura Ideal

```
seu-projeto/
├── app/                    # Next.js App Router
│   ├── (auth)/            # Grupo de autenticação
│   ├── (chat)/            # Grupo de chat
│   ├── layout.tsx
│   └── globals.css
├── components/            # Componentes React
│   ├── ui/               # shadcn/ui components
│   ├── mcp-menu.tsx      # Menu MCP (Electron)
│   └── ...
├── electron/              # Electron desktop
│   ├── main/
│   │   ├── index.ts      # Entry point
│   │   ├── window.ts     # Window management
│   │   ├── utils.ts      # Utilities
│   │   └── mcp/          # MCP Playwright
│   ├── preload/
│   │   └── index.ts      # Context bridge
│   └── types/
│       └── native.d.ts   # Window types
├── lib/                   # Lógica compartilhada
│   ├── runtime/          # Runtime detection
│   │   ├── detection.ts
│   │   ├── electron-client.ts
│   │   └── playwright-commands.ts
│   ├── ai/               # AI providers
│   ├── db/               # Database
│   └── utils.ts
├── hooks/                 # React hooks
├── tests/                 # Testes Playwright
│   ├── e2e/
│   ├── fixtures.ts
│   └── helpers.ts
├── public/                # Assets estáticos
│   ├── icon.ico
│   ├── icon.icns
│   └── icon.png
├── docs/                  # Documentação
│   ├── migra-next-electron/  # Guia de migração
│   └── ...
├── .gitignore
├── .env.example
├── biome.jsonc
├── components.json
├── package.json
├── tsconfig.json
├── next.config.ts
├── tailwind.config.ts
├── run-electron.bat
├── start-electron.ps1
├── build-production.ps1
└── CHANGELOG.md
```

---

## 🎯 9. Boas Práticas Implementadas

### 9.1 Segurança

✅ **Context Isolation**
```typescript
webPreferences: {
  nodeIntegration: false,
  contextIsolation: true,
  sandbox: true,
}
```

✅ **Allowlist de Navegação**
```typescript
const allowedOrigins = [
  "http://localhost:3000",
  "https://app.seudominio.com",
];
```

✅ **Allowlist de MCP Tools**
```typescript
const ALLOWED_TOOLS = new Set([
  "browser_navigate",
  "browser_snapshot",
  // ...
]);
```

### 9.2 Performance

✅ **Lazy Loading MCP**
- MCP só inicia quando necessário
- Não bloqueia startup do app

✅ **TypeScript Watch Mode**
```bash
pnpm electron:watch  # Auto-recompila
```

✅ **Turbo Mode Next.js**
```bash
pnpm dev --turbo  # Mais rápido
```

### 9.3 Developer Experience

✅ **Hot Reload Next.js**
- Mudanças refletem instantaneamente

✅ **Scripts Helper**
- `run-electron.bat` - Um clique
- `build-production.ps1` - Build profissional

✅ **Logs Organizados**
```typescript
console.log("[MCP]", "Mensagem");
console.log("[Electron]", "Mensagem");
console.log("[Renderer]", "Mensagem");
```

### 9.4 Manutenibilidade

✅ **Feature Detection**
- Código compartilhado web/desktop
- Zero bifurcação

✅ **Modularização**
- `mcp/index.ts` - Cliente
- `mcp/handlers.ts` - IPC
- `mcp/manager.ts` - Coordenação

✅ **Tipos TypeScript**
- `native.d.ts` - Window types
- Autocomplete funciona

---

## 📋 10. Checklist de Recursos Extras

### Para Copiar no Próximo Projeto

- [ ] `build-production.ps1` - Script profissional de build
- [ ] `biome.jsonc` - Config Ultracite
- [ ] `components.json` - Config shadcn/ui (se usar)
- [ ] `docs/electron.env.example` - Template env vars completo
- [ ] `CHANGELOG.md` - Estrutura de versionamento
- [ ] `playwright.config.ts` - Config de testes (se usar)
- [ ] Estrutura de pastas documentada
- [ ] Logs padronizados (`[Prefix]`)
- [ ] Error handling consistente
- [ ] Feature detection pattern

### Para Implementar

- [ ] CI/CD para builds automáticos
- [ ] Auto-update com electron-updater
- [ ] Crash reporting (Sentry)
- [ ] Analytics/Telemetry
- [ ] Code signing (certificados)
- [ ] Testes E2E automatizados
- [ ] Performance monitoring
- [ ] User feedback system

---

## 💡 11. Tips & Tricks

### 11.1 Debugging Avançado

**VSCode Launch Config** (`.vscode/launch.json`):

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Debug Electron Main",
      "type": "node",
      "request": "launch",
      "cwd": "${workspaceFolder}",
      "runtimeExecutable": "${workspaceFolder}/node_modules/.bin/electron",
      "windows": {
        "runtimeExecutable": "${workspaceFolder}/node_modules/.bin/electron.cmd"
      },
      "args": ["."],
      "outputCapture": "std"
    },
    {
      "name": "Debug Next.js",
      "type": "node",
      "request": "launch",
      "runtimeExecutable": "pnpm",
      "runtimeArgs": ["dev"],
      "port": 9229
    }
  ]
}
```

### 11.2 Performance Profiling

```typescript
// Medir tempo de inicialização
console.time("[MCP] Startup");
await startMcp();
console.timeEnd("[MCP] Startup");

// Medir memória
console.log(process.memoryUsage());
```

### 11.3 Environment-Specific Code

```typescript
// Diferentes comportamentos por ambiente
if (isDevelopment()) {
  window.webContents.openDevTools();
  console.log("[Debug] Modo desenvolvimento ativo");
}

if (process.env.ENABLE_ANALYTICS === "true") {
  initializeAnalytics();
}
```

---

## 🎁 12. Recursos Prontos para Copiar

### Lista Final de Arquivos

| Arquivo | Prioridade | Descrição |
|---------|-----------|-----------|
| `build-production.ps1` | ⭐⭐⭐ | Script profissional de build |
| `run-electron.bat` | ⭐⭐⭐ | Script helper Windows |
| `start-electron.ps1` | ⭐⭐⭐ | Script helper PowerShell |
| `docs/electron.env.example` | ⭐⭐⭐ | Template env vars (189 linhas!) |
| `biome.jsonc` | ⭐⭐ | Config linter/formatter |
| `components.json` | ⭐⭐ | Config shadcn/ui |
| `CHANGELOG.md` | ⭐⭐ | Estrutura de versionamento |
| `playwright.config.ts` | ⭐ | Config testes |
| `.vscode/launch.json` | ⭐ | Debug configs |

### Comando de Cópia Rápida

```bash
# Do projeto de referência para novo projeto
cp build-production.ps1 ../novo-projeto/
cp run-electron.bat ../novo-projeto/
cp start-electron.ps1 ../novo-projeto/
cp biome.jsonc ../novo-projeto/
cp components.json ../novo-projeto/
cp CHANGELOG.md ../novo-projeto/
cp docs/electron.env.example ../novo-projeto/docs/
cp playwright.config.ts ../novo-projeto/
cp -r .vscode ../novo-projeto/
```

---

## ✅ Resumo

### O Que Este Documento Cobre

1. ✅ **build-production.ps1** - Build profissional (MUST HAVE!)
2. ✅ **biome.jsonc** - Linter ultrarrápido
3. ✅ **components.json** - shadcn/ui config
4. ✅ **electron.env.example** - Template completo (189 linhas!)
5. ✅ **CHANGELOG.md** - Versionamento estruturado
6. ✅ **Estrutura de testes** - Playwright organizado
7. ✅ **Dependências recomendadas** - Curadas
8. ✅ **Estrutura de pastas** - Organização ideal
9. ✅ **Boas práticas** - Segurança, performance, DX
10. ✅ **Tips & tricks** - Debugging, profiling

### Impacto

Adicionar estes recursos no próximo projeto:
- ✅ **Build 10x melhor** (script profissional)
- ✅ **Lint/format 100x mais rápido** (Biome)
- ✅ **Env vars organizadas** (template completo)
- ✅ **Versionamento claro** (CHANGELOG)
- ✅ **Debugging fácil** (VSCode configs)

---

**Status**: ✅ Recursos Extras Documentados

**Próximo**: Usar tudo isso no próximo projeto! 🚀

