# 📦 Arquivos de Referência - Migração Next.js + Electron

Este diretório contém **todos os arquivos necessários** para implementar a migração completa de Next.js + Electron + MCP Playwright.

---

## 📋 Estrutura do Diretório

```
docs/migra-next-electron/
├── 📚 DOCUMENTAÇÃO (14 guias)
│   ├── 00-README.md                    # Índice principal
│   ├── 01-preparacao.md                # Pré-requisitos
│   ├── 02-estrutura-arquivos.md        # Estrutura de pastas
│   ├── 03-dependencias.md              # Instalação
│   ├── 04-electron-core.md             # Electron básico
│   ├── 05-mcp-playwright.md            # MCP Playwright
│   ├── 06-adaptacao-nextjs.md          # Adaptar Next.js
│   ├── 07-integracao-ui.md             # Integração UI
│   ├── 08-build-deploy.md              # Build e distribuição
│   ├── 09-troubleshooting.md           # Resolução de problemas
│   ├── 10-checklist.md                 # Checklist completo
│   ├── 11-dev-vs-prod.md               # Dev vs Prod
│   ├── 12-scripts-helper-windows.md    # Scripts Windows
│   ├── 13-arquivos-config.md           # Configs
│   └── 14-recursos-extras.md           # Recursos extras
│
├── 🔧 SCRIPTS (Prontos para usar!)
│   ├── build-production.ps1            # Build profissional ⭐⭐⭐
│   ├── run-electron.bat                # Iniciar dev (Windows)
│   └── start-electron.ps1              # Iniciar dev (PowerShell)
│
├── ⚙️ CONFIGURAÇÕES
│   ├── package.json                    # Scripts + deps + electron-builder
│   ├── tsconfig.json                   # TypeScript raiz
│   ├── next.config.ts                  # Next.js config
│   ├── biome.jsonc                     # Linter/formatter
│   ├── components.json                 # shadcn/ui config
│   ├── playwright.config.ts            # Testes E2E
│   ├── electron.env.example            # Template env vars (189 linhas!)
│   └── CHANGELOG.md                    # Estrutura de versionamento
│
├── 💻 CÓDIGO ELECTRON (Copiar completo)
│   └── electron/
│       ├── tsconfig.json               # TypeScript Electron
│       ├── main/
│       │   ├── index.ts                # Entry point principal
│       │   ├── window.ts               # Gerenciamento de janela
│       │   ├── utils.ts                # Utilitários
│       │   └── mcp/
│       │       ├── index.ts            # Cliente MCP Playwright
│       │       ├── handlers.ts         # IPC Handlers
│       │       ├── manager.ts          # Gerenciador MCP
│       │       └── computer-use/       # (Opcional - não incluir)
│       ├── preload/
│       │   └── index.ts                # Context bridge
│       └── types/
│           └── native.d.ts             # Tipos Window
│
├── 🔌 CÓDIGO RUNTIME (Copiar completo)
│   └── lib-runtime/
│       ├── detection.ts                # Detecção de ambiente
│       ├── electron-client.ts          # Cliente Electron wrapper
│       ├── computer-use-client.ts      # (Opcional - não incluir)
│       └── computer-use-commands.ts    # (Opcional - não incluir)
│
│   ⚠️ NOTA: playwright-commands.ts foi removido (sem comandos /pw no chat)
│
└── 🎨 COMPONENTES UI (Copiar apenas novos)
    └── mcp-menu.tsx                    # Menu MCP Playwright ⭐

⚠️ NOTA: Não copie app-sidebar.tsx ou outros componentes existentes!
         A documentação explica O QUE fazer neles, não copiar.

```

---

## 🎯 Como Usar Este Diretório

### 1️⃣ Ler a Documentação (Ordem)

**Comece por aqui**: `00-README.md`

Siga os guias na ordem:
```
01 → 02 → 03 → 04 → 05 → 06 → 07 → 08 → 09 → 10
```

**Extras úteis**:
- `11-dev-vs-prod.md` - Diferenças dev/prod
- `12-scripts-helper-windows.md` - Scripts Windows
- `13-arquivos-config.md` - Templates configs
- `14-recursos-extras.md` - Boas práticas ⭐

### 2️⃣ Copiar Scripts para Seu Projeto

```bash
# Do diretório docs/migra-next-electron/ para raiz do seu projeto

# Windows (CMD)
copy build-production.ps1 ..\..\seu-projeto\
copy run-electron.bat ..\..\seu-projeto\
copy start-electron.ps1 ..\..\seu-projeto\

# PowerShell
Copy-Item build-production.ps1 ..\..\seu-projeto\
Copy-Item run-electron.bat ..\..\seu-projeto\
Copy-Item start-electron.ps1 ..\..\seu-projeto\
```

### 3️⃣ Copiar Configurações

```bash
# Configurações base
copy package.json ..\..\seu-projeto\package.json.example
copy tsconfig.json ..\..\seu-projeto\tsconfig.json.example
copy next.config.ts ..\..\seu-projeto\next.config.ts.example
copy biome.jsonc ..\..\seu-projeto\
copy components.json ..\..\seu-projeto\
copy playwright.config.ts ..\..\seu-projeto\
copy electron.env.example ..\..\seu-projeto\docs\

# ATENÇÃO: Não sobrescreva seu package.json diretamente!
# Use como referência e merge manualmente
```

### 4️⃣ Copiar Código Electron

```bash
# Copiar estrutura completa
xcopy electron ..\..\seu-projeto\electron\ /E /I /Y

# Ou criar manualmente seguindo os guias
```

### 5️⃣ Copiar Código Runtime

```bash
# Copiar detecção e clientes
xcopy lib-runtime ..\..\seu-projeto\lib\runtime\ /E /I /Y

# Ou criar manualmente seguindo os guias
```

### 6️⃣ Copiar Componente UI Novo

```bash
# Copiar APENAS o componente novo
copy mcp-menu.tsx ..\..\seu-projeto\components\

# ⚠️ NÃO copie app-sidebar.tsx ou outros componentes existentes!
# A documentação (07-integracao-ui.md) explica como adaptar seus componentes existentes
```

---

## ⭐ Arquivos Mais Importantes

### Prioridade ALTA (Copiar sempre)

| Arquivo | Prioridade | Por Quê |
|---------|-----------|---------|
| `build-production.ps1` | ⭐⭐⭐ | Build profissional com validações |
| `electron.env.example` | ⭐⭐⭐ | 189 linhas de env vars |
| `electron/` (pasta completa) | ⭐⭐⭐ | Core do Electron |
| `lib-runtime/` (pasta completa) | ⭐⭐⭐ | Detecção + clientes |
| `run-electron.bat` | ⭐⭐⭐ | Helper Windows essencial |
| `start-electron.ps1` | ⭐⭐⭐ | Helper PowerShell |

### Prioridade MÉDIA (Muito úteis)

| Arquivo | Prioridade | Por Quê |
|---------|-----------|---------|
| `biome.jsonc` | ⭐⭐ | Linter 100x mais rápido |
| `components.json` | ⭐⭐ | Config shadcn/ui |
| `CHANGELOG.md` | ⭐⭐ | Estrutura de versionamento |
| `mcp-menu.tsx` | ⭐⭐ | UI de exemplo |

### Prioridade BAIXA (Referência)

| Arquivo | Prioridade | Por Quê |
|---------|-----------|---------|
| `playwright.config.ts` | ⭐ | Se usar testes E2E |
| `middleware.ts` | ⭐ | Exemplo Next.js |
| `app-sidebar.tsx` | ⭐ | Exemplo integração |

---

## 📦 Dependências Necessárias

Após copiar os arquivos, instale as dependências:

```bash
# Dependências principais
pnpm add electron @modelcontextprotocol/sdk @playwright/mcp sonner

# Dev dependencies
pnpm add -D electron-builder concurrently wait-on cross-env

# TypeScript (se não tiver)
pnpm add -D typescript @types/node @types/react

# Ultracite (linter - opcional mas recomendado)
pnpm add -D ultracite
```

**Ver detalhes**: `03-dependencias.md`

---

## 🔄 Fluxo de Migração Recomendado

1. ✅ **Backup**: Crie branch `feature/electron-migration`
2. ✅ **Leia**: `00-README.md` até `10-checklist.md`
3. ✅ **Copie**: Scripts helper (`.bat`, `.ps1`)
4. ✅ **Copie**: Configurações (package.json, tsconfig, etc)
5. ✅ **Copie**: Pasta `electron/` completa
6. ✅ **Copie**: Pasta `lib-runtime/` completa
7. ✅ **Copie**: Componentes UI (adaptar ao seu projeto)
8. ✅ **Instale**: Dependências
9. ✅ **Teste**: `pnpm electron:dev`
10. ✅ **Build**: `.\build-production.ps1`

---

## 🧪 Validação

Depois de copiar e configurar, valide:

### Desenvolvimento
```bash
# Iniciar Next.js + Electron
.\run-electron.bat

# Ou
.\start-electron.ps1

# Ou manualmente
pnpm dev           # Terminal 1
pnpm electron:dev  # Terminal 2
```

### Comandos MCP
No chat do app desktop, teste:
```
/pw help
/pw navigate https://google.com
/pw snapshot
/pw screenshot
/pw tools
```

### Build Produção
```bash
.\build-production.ps1
```

**Ver**: `09-troubleshooting.md` se tiver problemas

---

## 📝 Arquivos Compilados (.js, .js.map)

**⚠️ ATENÇÃO**: Os arquivos `.js` e `.js.map` em `electron/` são **compilados**:

```
electron/
├── main/
│   ├── index.js        # ❌ Não copiar (compilado)
│   ├── index.js.map    # ❌ Não copiar (compilado)
│   └── index.ts        # ✅ COPIAR (source)
```

**Você deve**:
- ✅ Copiar apenas arquivos `.ts`
- ✅ Compilar no seu projeto: `pnpm electron:compile`
- ❌ Não copiar `.js` e `.js.map`

**Ou use o script que já remove**:
```bash
# Copiar apenas TypeScript
for /r electron %f in (*.ts) do copy "%f" ..\..\seu-projeto\electron\
```

---

## 🗂️ Estrutura no Seu Projeto

Após migração, seu projeto deve ter:

```
seu-projeto/
├── app/                        # Next.js (existente)
├── components/                 # React (existente)
│   └── mcp-menu.tsx           # NOVO
├── lib/
│   └── runtime/               # NOVO
│       ├── detection.ts
│       ├── electron-client.ts
│       └── playwright-commands.ts
├── electron/                   # NOVO
│   ├── main/
│   ├── preload/
│   └── types/
├── docs/
│   └── electron.env.example   # NOVO
├── build-production.ps1        # NOVO
├── run-electron.bat           # NOVO
├── start-electron.ps1         # NOVO
├── biome.jsonc                # NOVO (ou merge)
├── components.json            # NOVO (ou merge)
├── package.json               # ATUALIZAR (merge)
├── tsconfig.json              # ATUALIZAR (merge)
└── next.config.ts             # ATUALIZAR (merge)
```

---

## 🎁 Recursos Extras

### VSCode Debugging

Criar `.vscode/launch.json`:
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
    }
  ]
}
```

### Git Ignore

Adicionar ao `.gitignore`:
```gitignore
# Electron
electron-dist/
electron/**/*.js
electron/**/*.js.map
*.app
*.dmg
*.exe
.env.electron
```

**Ver**: `13-arquivos-config.md`

---

## ❓ Precisa de Ajuda?

1. **Consulte**: `09-troubleshooting.md`
2. **Revise logs**: Terminal + DevTools (Ctrl+Shift+I)
3. **Compare código**: Use os arquivos aqui como referência
4. **Checklist**: `10-checklist.md`

---

## ✅ Status dos Arquivos

| Categoria | Status | Arquivos |
|-----------|--------|----------|
| 📚 Documentação | ✅ Completa | 14 guias |
| 🔧 Scripts | ✅ Prontos | 3 scripts |
| ⚙️ Configurações | ✅ Completas | 9 arquivos |
| 💻 Electron | ✅ Completo | 29 arquivos |
| 🔌 Runtime | ✅ Completo | 5 arquivos |
| 🎨 UI | ✅ Exemplos | 3 componentes |

**Total**: ~150+ arquivos de referência!

---

## 🚀 Próximos Passos

1. ✅ Leia `00-README.md`
2. ✅ Siga os guias 01-10
3. ✅ Copie os arquivos necessários
4. ✅ Teste no seu projeto
5. ✅ Build produção
6. ✅ Distribua! 🎉

---

**Boa sorte com a migração!** 🚀

**Este diretório contém TUDO que você precisa para adicionar Electron + MCP Playwright ao seu projeto Next.js!**

