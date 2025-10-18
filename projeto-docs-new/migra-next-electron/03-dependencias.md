# 03 - Instalação de Dependências

## ✅ Objetivos desta Etapa

- Instalar Electron e ferramentas relacionadas
- Instalar MCP SDK e Playwright MCP
- Instalar utilitários de desenvolvimento
- Atualizar package.json com scripts

---

## 📦 1. Dependências Necessárias

### 1.1 Visão Geral

| Pacote | Tipo | Propósito |
|--------|------|-----------|
| `electron` | devDep | Framework desktop |
| `electron-builder` | devDep | Build e empacotamento |
| `@modelcontextprotocol/sdk` | dep | SDK oficial MCP |
| `@playwright/mcp` | dep | Servidor Playwright MCP |
| `concurrently` | devDep | Rodar múltiplos comandos |
| `wait-on` | devDep | Esperar servidor Next.js |
| `cross-env` | devDep | Variáveis de ambiente cross-platform |

---

## 🔧 2. Instalação

### 2.1 Dependências de Produção

```bash
pnpm add @modelcontextprotocol/sdk @playwright/mcp
```

**Ou com npm**:
```bash
npm install @modelcontextprotocol/sdk @playwright/mcp
```

**Ou com yarn**:
```bash
yarn add @modelcontextprotocol/sdk @playwright/mcp
```

### 2.2 Dependências de Desenvolvimento

```bash
pnpm add -D electron electron-builder concurrently wait-on cross-env
```

**Ou com npm**:
```bash
npm install --save-dev electron electron-builder concurrently wait-on cross-env
```

**Ou com yarn**:
```bash
yarn add -D electron electron-builder concurrently wait-on cross-env
```

### 2.3 Verificar Instalação

```bash
# Verificar versões instaladas
pnpm list electron
pnpm list @playwright/mcp
pnpm list @modelcontextprotocol/sdk

# Deve mostrar algo como:
# electron 38.x.x
# @playwright/mcp 0.0.x
# @modelcontextprotocol/sdk 1.x.x
```

---

## ⚙️ 3. Atualizar package.json

**📦 Template completo disponível**: [13-arquivos-config.md](./13-arquivos-config.md)

### 3.1 Adicionar Campo `main`

Editar `package.json`, adicionar/atualizar:

```json
{
  "name": "seu-projeto",
  "version": "1.0.0",
  "main": "electron/main/index.js",
  ...
}
```

⚠️ **Importante**: `main` aponta para `.js` (compilado), não `.ts`

### 3.2 Adicionar Scripts Electron

Adicionar na seção `scripts`:

```json
{
  "scripts": {
    "dev": "next dev --turbo",
    "build": "next build",
    "start": "next start",
    
    "electron:compile": "tsc -p electron/tsconfig.json",
    "electron:watch": "tsc -p electron/tsconfig.json --watch",
    "electron:start": "electron .",
    "electron:dev": "concurrently \"pnpm dev\" \"pnpm electron:watch\" \"wait-on http://localhost:3000 && cross-env NODE_ENV=development electron .\"",
    "electron:build": "pnpm build && pnpm electron:compile && electron-builder",
    "dist": "pnpm electron:build --publish never",
    "dist:win": "pnpm electron:build --win --publish never",
    "dist:mac": "pnpm electron:build --mac --publish never",
    "dist:linux": "pnpm electron:build --linux --publish never"
  }
}
```

**Explicação dos scripts**:

| Script | O que faz |
|--------|-----------|
| `electron:compile` | Compila TypeScript do Electron para JavaScript |
| `electron:watch` | Compila em modo watch (auto-recompila) |
| `electron:start` | Inicia Electron (Next.js deve estar rodando) |
| `electron:dev` | Inicia tudo: Next.js + Electron em modo dev |
| `electron:build` | Build completo: Next.js + Electron + binário |
| `dist:*` | Build para plataforma específica |

### 3.3 Adicionar Configuração electron-builder

Adicionar na raiz do `package.json`:

```json
{
  ...
  "build": {
    "appId": "com.seudominio.seuapp",
    "productName": "Seu App",
    "directories": {
      "output": "electron-dist",
      "buildResources": "electron/builder"
    },
    "files": [
      "electron/main/**/*.js",
      "electron/preload/**/*.js",
      "node_modules/**/*",
      "package.json"
    ],
    "win": {
      "target": ["nsis", "portable"],
      "artifactName": "${productName}-Setup-${version}.${ext}"
    },
    "mac": {
      "target": ["dmg"],
      "category": "public.app-category.productivity"
    },
    "linux": {
      "target": ["AppImage"],
      "category": "Utility"
    }
  }
}
```

**Personalize**:
- `appId`: Seu identificador único (formato reverse domain)
- `productName`: Nome do app que aparecerá para usuário

---

## 📝 4. Atualizar tsconfig.json (Raiz)

### 4.1 Adicionar Paths Electron

Editar `tsconfig.json` na raiz, adicionar em `compilerOptions`:

```json
{
  "compilerOptions": {
    ...
    "paths": {
      "@/*": ["./*"],
      "@electron/*": ["./electron/*"]
    }
  },
  "include": [
    "next-env.d.ts",
    "**/*.ts",
    "**/*.tsx",
    ".next/types/**/*.ts",
    "electron/**/*"
  ]
}
```

**Se já tiver `paths`**, apenas adicionar `@electron/*`:

```json
"paths": {
  "@/*": ["./*"],
  "@electron/*": ["./electron/*"]
}
```

---

## 🔧 5. Criar electron/tsconfig.json

Criar arquivo `electron/tsconfig.json`:

```json
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "commonjs",
    "lib": ["ES2020"],
    "outDir": "./",
    "rootDir": "./",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "moduleResolution": "node",
    "resolveJsonModule": true,
    "declaration": false,
    "sourceMap": true,
    "types": ["node"]
  },
  "include": ["**/*.ts"],
  "exclude": ["node_modules", "**/*.js"]
}
```

⚠️ **Importante**: `outDir: "./"` compila `.ts` para `.js` no mesmo diretório.

---

## ✅ 6. Verificação de Dependências

### 6.1 Listar Dependências Instaladas

```bash
pnpm list | grep -E "(electron|mcp|playwright|concurrently|wait-on)"
```

**Deve mostrar**:
```
electron 38.x.x
electron-builder 26.x.x
@modelcontextprotocol/sdk 1.x.x
@playwright/mcp 0.0.x
concurrently 9.x.x
wait-on 9.x.x
cross-env 10.x.x
```

### 6.2 Verificar Scripts

```bash
pnpm run electron:compile --help
# Deve mostrar opções do TypeScript Compiler
```

### 6.3 Testar Compilação TypeScript

```bash
# Tentar compilar (mesmo com arquivos vazios)
pnpm electron:compile

# Deve criar:
# electron/main/index.js
# electron/preload/index.js
# (arquivos vazios por enquanto, mas sem erros)
```

---

## 📦 7. Versões Recomendadas

### 7.1 Tabela de Compatibilidade

| Pacote | Versão Min | Versão Recomendada | Notas |
|--------|-----------|-------------------|-------|
| electron | 28.0.0 | **38.x** | Mais recente |
| @modelcontextprotocol/sdk | 1.0.0 | **1.20.x** | SDK oficial |
| @playwright/mcp | 0.0.1 | **0.0.43+** | Em desenvolvimento |
| electron-builder | 24.0.0 | **26.x** | Build system |
| Node.js | 18.0.0 | **20.x LTS** | Runtime |

### 7.2 Dependências Peer

Electron requer `node-gyp` para algumas dependências nativas. Já está incluído no Node.js.

**Se tiver problemas no Windows**:
```bash
npm install -g node-gyp
npm config set msvs_version 2019
```

---

## 🚨 Problemas Comuns

### ❌ Erro: "electron-builder not found"

```bash
# Reinstalar
pnpm add -D electron-builder

# Ou globalmente
pnpm add -g electron-builder
```

### ❌ Erro: "Cannot find module '@modelcontextprotocol/sdk'"

```bash
# Verificar instalação
pnpm list @modelcontextprotocol/sdk

# Se não estiver, instalar:
pnpm add @modelcontextprotocol/sdk
```

### ❌ Erro: "tsc: command not found"

```bash
# TypeScript deve estar instalado (geralmente já está com Next.js)
pnpm add -D typescript

# Verificar
pnpm tsc --version
```

### ❌ Erro na compilação: "Cannot write file ... overwrite"

```bash
# Limpar arquivos compilados
rm -rf electron/main/*.js electron/main/*.js.map
rm -rf electron/preload/*.js electron/preload/*.js.map

# Tentar novamente
pnpm electron:compile
```

### ❌ Erro: "node-gyp" no Windows

- Instalar Visual Studio Build Tools 2019+ (ver etapa 01)
- Reiniciar terminal após instalação
- Tentar novamente: `pnpm install`

---

## 📋 Checklist da Etapa

Antes de continuar:

- [ ] Dependências instaladas: `electron`, `electron-builder`, etc
- [ ] Dependências MCP instaladas: `@modelcontextprotocol/sdk`, `@playwright/mcp`
- [ ] `package.json` atualizado com campo `main`
- [ ] Scripts electron adicionados
- [ ] Configuração `build` adicionada
- [ ] `tsconfig.json` (raiz) atualizado com `electron/**/*`
- [ ] `electron/tsconfig.json` criado
- [ ] `pnpm electron:compile` executa sem erros
- [ ] Arquivos `.js` criados em `electron/main/` e `electron/preload/`

---

## 💡 Dica: Scripts Helper (Windows)

Se estiver no Windows, considere criar scripts helper que facilitam o desenvolvimento:

```bash
# Ver guia completo
docs/migra-next-electron/12-scripts-helper-windows.md
```

Scripts disponíveis:
- `run-electron.bat` - Verifica Next.js, compila e inicia Electron
- `start-electron.ps1` - Versão PowerShell
- `dev-full.bat` - Tudo automático

**Opcional**: Criar agora ou depois da etapa 04.

---

## 🎯 Próxima Etapa

Dependências instaladas! Agora vamos implementar o core do Electron.

**[04-electron-core.md](./04-electron-core.md)** - Implementação do Electron Core

---

**Status**: ✅ Dependências Instaladas

