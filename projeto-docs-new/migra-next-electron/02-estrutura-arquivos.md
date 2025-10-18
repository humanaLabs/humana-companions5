# 02 - Estrutura de Arquivos

## ✅ Objetivos desta Etapa

- Criar diretório `electron/` e subpastas
- Criar diretório `lib/runtime/` (se não existir)
- Entender organização de arquivos
- Preparar estrutura para implementação

---

## 📂 1. Estrutura Completa

```
seu-projeto/
├── app/                    # Seu código Next.js existente (não mexer)
├── components/             # Seus componentes existentes (não mexer)
├── lib/
│   └── runtime/           # 🆕 NOVO - Runtime detection
│       ├── detection.ts
│       ├── electron-client.ts
│       └── playwright-commands.ts
├── electron/              # 🆕 NOVO - Toda lógica Electron
│   ├── main/
│   │   ├── index.ts
│   │   ├── window.ts
│   │   ├── utils.ts
│   │   └── mcp/
│   │       ├── index.ts
│   │       ├── handlers.ts
│   │       └── manager.ts
│   ├── preload/
│   │   └── index.ts
│   ├── types/
│   │   └── native.d.ts
│   └── tsconfig.json
├── docs/                  # Documentação
├── package.json           # Será atualizado
├── tsconfig.json          # Será atualizado
└── .gitignore            # Já atualizado na etapa 1
```

---

## 🔨 2. Criar Estrutura Electron

### 2.1 Criar Diretórios

```bash
# Na raiz do projeto

# Criar estrutura electron/
mkdir -p electron/main/mcp
mkdir -p electron/preload
mkdir -p electron/types

# Criar estrutura lib/runtime/ (se não existir)
mkdir -p lib/runtime
```

**Windows (PowerShell)**:
```powershell
New-Item -ItemType Directory -Force -Path electron\main\mcp
New-Item -ItemType Directory -Force -Path electron\preload
New-Item -ItemType Directory -Force -Path electron\types
New-Item -ItemType Directory -Force -Path lib\runtime
```

### 2.2 Verificar Estrutura Criada

```bash
# Listar estrutura
tree electron -L 2
# ou
ls -R electron
```

Deve mostrar:
```
electron/
├── main/
│   └── mcp/
├── preload/
└── types/
```

---

## 📝 3. Criar Arquivos Vazios (Placeholders)

Vamos criar arquivos vazios para organizar. Serão preenchidos nas próximas etapas.

### 3.1 Arquivos Electron Main

```bash
# Linux/macOS
touch electron/main/index.ts
touch electron/main/window.ts
touch electron/main/utils.ts
touch electron/main/mcp/index.ts
touch electron/main/mcp/handlers.ts
touch electron/main/mcp/manager.ts

# Windows (PowerShell)
New-Item -ItemType File electron\main\index.ts
New-Item -ItemType File electron\main\window.ts
New-Item -ItemType File electron\main\utils.ts
New-Item -ItemType File electron\main\mcp\index.ts
New-Item -ItemType File electron\main\mcp\handlers.ts
New-Item -ItemType File electron\main\mcp\manager.ts
```

### 3.2 Arquivos Preload e Types

```bash
# Linux/macOS
touch electron/preload/index.ts
touch electron/types/native.d.ts
touch electron/tsconfig.json

# Windows (PowerShell)
New-Item -ItemType File electron\preload\index.ts
New-Item -ItemType File electron\types\native.d.ts
New-Item -ItemType File electron\tsconfig.json
```

### 3.3 Arquivos Runtime

```bash
# Linux/macOS
touch lib/runtime/detection.ts
touch lib/runtime/electron-client.ts
touch lib/runtime/playwright-commands.ts

# Windows (PowerShell)
New-Item -ItemType File lib\runtime\detection.ts
New-Item -ItemType File lib\runtime\electron-client.ts
New-Item -ItemType File lib\runtime\playwright-commands.ts
```

---

## 📋 4. Descrição de Cada Arquivo

### 4.1 Electron Main Process

| Arquivo | Propósito |
|---------|-----------|
| `electron/main/index.ts` | Entry point do Electron, inicialização |
| `electron/main/window.ts` | Gerenciamento de janelas (BrowserWindow) |
| `electron/main/utils.ts` | Funções utilitárias (isDevelopment, etc) |
| `electron/main/mcp/index.ts` | Cliente MCP Playwright (conexão stdio) |
| `electron/main/mcp/handlers.ts` | IPC handlers para MCP (segurança) |
| `electron/main/mcp/manager.ts` | Gerenciador de MCPs (inicialização, status) |

### 4.2 Preload Script

| Arquivo | Propósito |
|---------|-----------|
| `electron/preload/index.ts` | Context Bridge - Expõe APIs seguras para renderer |

### 4.3 Types

| Arquivo | Propósito |
|---------|-----------|
| `electron/types/native.d.ts` | Tipos TypeScript para `window.mcp`, `window.env` |

### 4.4 Runtime (Next.js)

| Arquivo | Propósito |
|---------|-----------|
| `lib/runtime/detection.ts` | Feature detection (isElectron, hasMCP) |
| `lib/runtime/electron-client.ts` | Wrappers para APIs MCP |
| `lib/runtime/playwright-commands.ts` | Sistema de comandos `/pw` |

### 4.5 Configuração

| Arquivo | Propósito |
|---------|-----------|
| `electron/tsconfig.json` | Config TypeScript para Electron |

---

## 🎯 5. Princípios de Organização

### 5.1 Separação de Concerns

```
electron/           → Tudo relacionado ao Electron (não roda no browser)
lib/runtime/        → Feature detection (roda em ambos: web + electron)
components/         → UI (roda em ambos, com detecção condicional)
```

### 5.2 Não-invasivo

- ✅ Arquivos novos em pastas novas (`electron/`, `lib/runtime/`)
- ✅ Código existente permanece intacto
- ✅ Integração será feita na etapa 7 (pontual e opcional)

### 5.3 Modularidade

Cada módulo tem responsabilidade única:
- `mcp/index.ts` → Conectar com Playwright MCP
- `mcp/handlers.ts` → Expor via IPC
- `mcp/manager.ts` → Coordenar múltiplos MCPs (extensível)

---

## 📦 6. Estrutura Expandida (Referência)

Para entender melhor, estrutura completa após migração:

```
seu-projeto/
├── electron/
│   ├── main/
│   │   ├── index.ts              # ~75 linhas
│   │   ├── window.ts             # ~73 linhas
│   │   ├── utils.ts              # ~17 linhas
│   │   └── mcp/
│   │       ├── index.ts          # ~75 linhas (cliente Playwright)
│   │       ├── handlers.ts       # ~75 linhas (IPC + allowlist)
│   │       └── manager.ts        # ~120 linhas (gerenciador)
│   ├── preload/
│   │   └── index.ts              # ~25 linhas (context bridge)
│   ├── types/
│   │   └── native.d.ts           # ~23 linhas (tipos)
│   └── tsconfig.json             # ~21 linhas (config TS)
├── lib/runtime/
│   ├── detection.ts              # ~37 linhas (feature detection)
│   ├── electron-client.ts        # ~58 linhas (wrapper MCP)
│   └── playwright-commands.ts    # ~173 linhas (comandos /pw)
└── ... (resto do projeto intacto)

Total de linhas novas: ~650 linhas
Total de arquivos novos: 12 arquivos
```

**📊 Impacto**: ~650 linhas de código em arquivos isolados. Zero mudanças destrutivas.

---

## ✅ 7. Validação da Estrutura

### 7.1 Verificar Diretórios

```bash
# Deve existir:
ls -la electron/main
ls -la electron/main/mcp
ls -la electron/preload
ls -la electron/types
ls -la lib/runtime
```

### 7.2 Verificar Arquivos

```bash
# Listar todos os arquivos novos
find electron -type f -name "*.ts"
find lib/runtime -type f -name "*.ts"
```

Deve listar:
```
electron/main/index.ts
electron/main/window.ts
electron/main/utils.ts
electron/main/mcp/index.ts
electron/main/mcp/handlers.ts
electron/main/mcp/manager.ts
electron/preload/index.ts
electron/types/native.d.ts
electron/tsconfig.json
lib/runtime/detection.ts
lib/runtime/electron-client.ts
lib/runtime/playwright-commands.ts
```

✅ **12 arquivos criados?** Estrutura completa!

---

## 🚨 Problemas Comuns

### ❌ `mkdir: cannot create directory`

```bash
# Linux/macOS: Permissões
sudo chown -R $USER:$USER .

# Windows: Executar terminal como Administrador
```

### ❌ Diretórios não criados (Windows)

```powershell
# Usar -Force para criar recursivamente
New-Item -ItemType Directory -Force -Path electron\main\mcp
```

### ❌ `lib/runtime` já existe com arquivos

✅ **Tudo bem!** Adicione apenas os arquivos novos:
```bash
touch lib/runtime/detection.ts
touch lib/runtime/electron-client.ts
touch lib/runtime/playwright-commands.ts
```

---

## 📋 Checklist da Etapa

Antes de continuar:

- [ ] Diretórios criados: `electron/main`, `electron/main/mcp`, `electron/preload`, `electron/types`
- [ ] Diretório criado: `lib/runtime`
- [ ] 12 arquivos `.ts` criados (placeholders vazios)
- [ ] Estrutura validada com `ls` ou `tree`
- [ ] .gitignore já tem regras Electron (etapa 1)

---

## 🎯 Próxima Etapa

Estrutura pronta! Agora vamos instalar dependências.

**[03-dependencias.md](./03-dependencias.md)** - Instalação de Pacotes

---

**Status**: ✅ Estrutura Criada

