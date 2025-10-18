# 13 - Arquivos de Configuração (Templates Prontos)

## ✅ Objetivo

Templates de todos os arquivos de configuração necessários para copiar direto no novo projeto.

---

## 📂 Arquivos Incluídos

1. `.gitignore` - Regras Electron
2. `package.json` - Scripts e electron-builder config
3. `tsconfig.json` (raiz) - Config TypeScript principal
4. `electron/tsconfig.json` - Config TypeScript Electron
5. `.env.example` - Variáveis de ambiente
6. Estrutura de ícones

---

## 🔧 1. .gitignore

**Adicionar ao `.gitignore` existente ou criar se não existir**:

```gitignore
# ========================================
# ELECTRON - Adicionar estas linhas
# ========================================

# Electron build output
electron-dist/
dist-electron/

# Electron compiled files
electron/**/*.js
electron/**/*.js.map
electron/**/*.d.ts
!electron/**/*.config.js

# Electron installers
*.app
*.dmg
*.exe
*.msi
*.deb
*.rpm
*.AppImage
*.zip
*.tar.gz

# Electron builder
electron-builder.yml
build/

# ========================================
# Next.js (já deve ter, verificar)
# ========================================
.next/
out/
build
.turbo

# ========================================
# Dependencies (já deve ter)
# ========================================
node_modules/
.pnp
.pnp.js

# ========================================
# Environment variables
# ========================================
.env
.env.local
.env*.local
.env.development.local
.env.test.local
.env.production.local

# ========================================
# Logs
# ========================================
npm-debug.log*
yarn-debug.log*
yarn-error.log*
.pnpm-debug.log*

# ========================================
# OS
# ========================================
.DS_Store
Thumbs.db

# ========================================
# IDE
# ========================================
.vscode/
.idea/
*.swp
*.swo
*~

# ========================================
# Testing
# ========================================
coverage/
.nyc_output/
/test-results/
/playwright-report/
/blob-report/
```

---

## 📦 2. package.json

**Adicionar/atualizar no `package.json` existente**:

### 2.1 Campo `main`

```json
{
  "name": "seu-projeto",
  "version": "1.0.0",
  "main": "electron/main/index.js",
  "description": "Seu app Next.js + Electron",
  "author": "Seu Nome <email@exemplo.com>",
  "license": "MIT"
}
```

### 2.2 Scripts

**Adicionar na seção `scripts`**:

```json
{
  "scripts": {
    "dev": "next dev --turbo",
    "build": "next build",
    "start": "next start",
    "lint": "next lint",
    
    "electron:compile": "tsc -p electron/tsconfig.json",
    "electron:watch": "tsc -p electron/tsconfig.json --watch",
    "electron:start": "electron .",
    "electron:dev": "concurrently \"pnpm dev\" \"pnpm electron:watch\" \"wait-on http://localhost:3000 && cross-env NODE_ENV=development electron .\"",
    "electron:dev:win": "powershell -ExecutionPolicy Bypass -File start-electron.ps1",
    "electron:build": "pnpm build && pnpm electron:compile && electron-builder",
    "dist": "pnpm electron:build --publish never",
    "dist:win": "pnpm electron:build --win --publish never",
    "dist:mac": "pnpm electron:build --mac --publish never",
    "dist:linux": "pnpm electron:build --linux --publish never"
  }
}
```

### 2.3 Configuração electron-builder

**Adicionar na raiz do `package.json`**:

```json
{
  "build": {
    "appId": "com.seudominio.seuapp",
    "productName": "Seu App Nome",
    "copyright": "Copyright © 2024 Seu Nome",
    "directories": {
      "output": "electron-dist",
      "buildResources": "electron/builder"
    },
    "files": [
      "electron/main/**/*.js",
      "electron/preload/**/*.js",
      "node_modules/**/*",
      "!node_modules/@types/**",
      "!node_modules/.cache/**",
      "package.json"
    ],
    "win": {
      "target": [
        {
          "target": "nsis",
          "arch": ["x64"]
        },
        {
          "target": "portable",
          "arch": ["x64"]
        }
      ],
      "icon": "public/icon.ico",
      "artifactName": "${productName}-Setup-${version}.${ext}",
      "publish": null
    },
    "nsis": {
      "oneClick": false,
      "allowToChangeInstallationDirectory": true,
      "createDesktopShortcut": "always",
      "createStartMenuShortcut": true,
      "shortcutName": "Seu App"
    },
    "mac": {
      "target": [
        {
          "target": "dmg",
          "arch": ["x64", "arm64"]
        }
      ],
      "icon": "public/icon.icns",
      "category": "public.app-category.productivity",
      "hardenedRuntime": false,
      "gatekeeperAssess": false
    },
    "dmg": {
      "contents": [
        {
          "x": 130,
          "y": 220
        },
        {
          "x": 410,
          "y": 220,
          "type": "link",
          "path": "/Applications"
        }
      ]
    },
    "linux": {
      "target": [
        {
          "target": "AppImage",
          "arch": ["x64"]
        }
      ],
      "icon": "public/icon.png",
      "category": "Utility",
      "maintainer": "seu-email@exemplo.com"
    }
  }
}
```

**Personalize**:
- `appId` - Reverse domain notation (ex: `com.suaempresa.seuapp`)
- `productName` - Nome que aparece para o usuário
- `icon` - Caminhos para os ícones
- `copyright` - Informações de copyright
- `author` e `maintainer` - Suas informações

---

## 📝 3. tsconfig.json (Raiz)

**Se já existir, APENAS adicionar/atualizar as partes necessárias**:

```json
{
  "compilerOptions": {
    "target": "ESNext",
    "lib": ["dom", "dom.iterable", "esnext"],
    "allowJs": true,
    "skipLibCheck": true,
    "strict": true,
    "noEmit": true,
    "esModuleInterop": true,
    "module": "esnext",
    "moduleResolution": "bundler",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "jsx": "preserve",
    "incremental": true,
    "plugins": [
      {
        "name": "next"
      }
    ],
    "paths": {
      "@/*": ["./*"]
    }
  },
  "include": [
    "next-env.d.ts",
    "**/*.ts",
    "**/*.tsx",
    ".next/types/**/*.ts",
    "next.config.js",
    "electron/types/**/*.ts"
  ],
  "exclude": [
    "node_modules",
    "electron/main",
    "electron/preload"
  ]
}
```

**Importante**:
- Adicionar `"electron/types/**/*.ts"` em `include`
- Adicionar `"electron/main"` e `"electron/preload"` em `exclude`

---

## 🔧 4. electron/tsconfig.json

**Criar arquivo `electron/tsconfig.json`**:

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

**Não modificar**: Este é o config padrão para Electron.

---

## 🔐 5. .env.example

**Criar arquivo `.env.example`** (template para outros devs):

```bash
# ========================================
# DATABASE
# ========================================
DATABASE_URL=postgresql://user:password@localhost:5432/dbname

# ========================================
# AUTHENTICATION
# ========================================
AUTH_SECRET=your-secret-key-here
AUTH_GITHUB_ID=your-github-app-id
AUTH_GITHUB_SECRET=your-github-app-secret

# ========================================
# AI PROVIDERS
# ========================================
OPENAI_API_KEY=sk-...
ANTHROPIC_API_KEY=sk-ant-...

# ========================================
# ELECTRON (Development)
# ========================================
# URL que Electron carregará em dev
ELECTRON_START_URL=http://localhost:3000

# ========================================
# NEXT.JS PUBLIC (acessível no client)
# ========================================
NEXT_PUBLIC_API_URL=http://localhost:3000/api
NEXT_PUBLIC_APP_URL=http://localhost:3000
```

**E criar `.env.local`** (ignorado pelo git):

```bash
# Copiar .env.example e preencher com valores reais
# Este arquivo NÃO deve ser commitado
```

---

## 🎨 6. Estrutura de Ícones

### 6.1 Arquivos Necessários

```
seu-projeto/
├── public/
│   ├── icon.ico       # Windows (256x256)
│   ├── icon.icns      # macOS (512x512)
│   └── icon.png       # Linux (512x512)
└── app/
    └── favicon.ico    # Favicon web (32x32)
```

### 6.2 Gerar Ícones

**Opção 1: Online** (Fácil)
1. Ter logo PNG de alta resolução (1024x1024)
2. Ir para: https://www.icoconverter.com/
3. Gerar `.ico` (Windows)
4. Ir para: https://cloudconvert.com/png-to-icns
5. Gerar `.icns` (macOS)
6. `.png` já está pronto (Linux)

**Opção 2: Ferramenta** (Automático)

```bash
# Instalar electron-icon-maker
pnpm add -D electron-icon-maker

# Gerar todos os ícones de uma vez
pnpx electron-icon-maker --input=./logo-1024.png --output=./public/
```

**Opção 3: ImageMagick** (Linha de comando)

```bash
# Windows (.ico)
magick convert logo.png -resize 256x256 public/icon.ico

# macOS (.icns) - requer iconutil (macOS only)
mkdir icon.iconset
sips -z 512 512 logo.png --out icon.iconset/icon_512x512.png
iconutil -c icns icon.iconset -o public/icon.icns

# Linux (.png)
convert logo.png -resize 512x512 public/icon.png
```

### 6.3 Tamanhos Recomendados

| Plataforma | Formato | Tamanho Ideal | Localização |
|-----------|---------|---------------|-------------|
| Windows | `.ico` | 256x256 | `public/icon.ico` |
| macOS | `.icns` | 512x512 (1024x1024 retina) | `public/icon.icns` |
| Linux | `.png` | 512x512 | `public/icon.png` |
| Web | `.ico` | 32x32 (16x16, 32x32, 48x48) | `app/favicon.ico` |

---

## ⚙️ 7. next.config.ts (Opcional)

**Se precisar de configurações específicas para Electron**:

```typescript
import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  // Configurações existentes
  experimental: {
    ppr: true,
  },
  
  // Para imagens externas (se necessário)
  images: {
    remotePatterns: [
      {
        hostname: "avatar.vercel.sh",
      },
    ],
  },
  
  // Headers de segurança (opcional)
  async headers() {
    return [
      {
        source: "/:path*",
        headers: [
          {
            key: "Content-Security-Policy",
            value: "default-src 'self' 'unsafe-inline' 'unsafe-eval' data: blob:;",
          },
        ],
      },
    ];
  },
};

export default nextConfig;
```

**Nota**: Na maioria dos casos, o `next.config.ts` padrão funciona perfeitamente. Apenas adicione configurações se necessário.

---

## 📋 8. Checklist de Arquivos

### Copiar do Projeto de Referência

- [ ] `.gitignore` - Copiar regras Electron
- [ ] `package.json` - Copiar seção `build` e scripts `electron:*`
- [ ] `electron/tsconfig.json` - Copiar completo
- [ ] Scripts Windows:
  - [ ] `run-electron.bat`
  - [ ] `start-electron.ps1`
  - [ ] `dev-full.bat` (opcional)
  - [ ] `build-production.bat` (opcional)

### Criar do Zero

- [ ] `.env.example` - Template de variáveis
- [ ] `.env.local` - Valores reais (não commitar)
- [ ] `public/icon.ico` - Ícone Windows
- [ ] `public/icon.icns` - Ícone macOS
- [ ] `public/icon.png` - Ícone Linux

### Atualizar no Projeto Existente

- [ ] `tsconfig.json` - Adicionar `electron/types/**/*.ts` em `include`
- [ ] `tsconfig.json` - Adicionar `electron/main` e `electron/preload` em `exclude`
- [ ] `package.json` - Adicionar campo `main`
- [ ] `next.config.ts` - Adicionar configs se necessário

---

## 🚀 9. Quick Start para Novo Projeto

### Passo 1: Copiar Arquivos

```bash
# No projeto de referência (este)
cd ai-chatbot-elec-webwiew

# Copiar para novo projeto
cp .gitignore ../novo-projeto/
cp run-electron.bat ../novo-projeto/
cp start-electron.ps1 ../novo-projeto/
cp -r electron/tsconfig.json ../novo-projeto/electron/

# Copiar ícones (se já tiver)
cp public/icon.* ../novo-projeto/public/
```

### Passo 2: Atualizar package.json

```bash
# No novo projeto
cd ../novo-projeto

# Abrir package.json e adicionar:
# 1. Campo "main"
# 2. Scripts "electron:*"
# 3. Seção "build"
```

### Passo 3: Atualizar tsconfig.json

```bash
# Adicionar em include:
# "electron/types/**/*.ts"

# Adicionar em exclude:
# "electron/main", "electron/preload"
```

### Passo 4: Personalizar

```bash
# package.json
# - appId
# - productName
# - author

# .env.example
# - Suas variáveis de ambiente

# electron/main/utils.ts
# - URL de produção em getStartUrl()
```

---

## 💡 10. Template Completo package.json

**Template pronto para copiar**:

```json
{
  "name": "seu-projeto",
  "version": "1.0.0",
  "main": "electron/main/index.js",
  "description": "Seu app com Next.js + Electron + MCP",
  "author": "Seu Nome <email@exemplo.com>",
  "license": "MIT",
  "scripts": {
    "dev": "next dev --turbo",
    "build": "next build",
    "start": "next start",
    "lint": "next lint",
    "electron:compile": "tsc -p electron/tsconfig.json",
    "electron:watch": "tsc -p electron/tsconfig.json --watch",
    "electron:start": "electron .",
    "electron:dev": "concurrently \"pnpm dev\" \"pnpm electron:watch\" \"wait-on http://localhost:3000 && cross-env NODE_ENV=development electron .\"",
    "electron:dev:win": "powershell -ExecutionPolicy Bypass -File start-electron.ps1",
    "electron:build": "pnpm build && pnpm electron:compile && electron-builder",
    "dist": "pnpm electron:build --publish never",
    "dist:win": "pnpm electron:build --win --publish never",
    "dist:mac": "pnpm electron:build --mac --publish never",
    "dist:linux": "pnpm electron:build --linux --publish never"
  },
  "dependencies": {
    "@modelcontextprotocol/sdk": "^1.20.1",
    "@playwright/mcp": "^0.0.43",
    "next": "^15.0.0",
    "react": "^19.0.0",
    "react-dom": "^19.0.0"
  },
  "devDependencies": {
    "@types/node": "^22.0.0",
    "@types/react": "^18.0.0",
    "concurrently": "^9.0.0",
    "cross-env": "^10.0.0",
    "electron": "^38.0.0",
    "electron-builder": "^26.0.0",
    "typescript": "^5.0.0",
    "wait-on": "^9.0.0"
  },
  "build": {
    "appId": "com.seudominio.seuapp",
    "productName": "Seu App",
    "directories": {
      "output": "electron-dist"
    },
    "files": [
      "electron/main/**/*.js",
      "electron/preload/**/*.js",
      "node_modules/**/*",
      "package.json"
    ],
    "win": {
      "target": ["nsis", "portable"],
      "icon": "public/icon.ico"
    },
    "mac": {
      "target": ["dmg"],
      "icon": "public/icon.icns",
      "category": "public.app-category.productivity"
    },
    "linux": {
      "target": ["AppImage"],
      "icon": "public/icon.png",
      "category": "Utility"
    }
  }
}
```

---

## 📦 11. Arquivos de Referência

**No projeto atual, consultar**:

- ✅ `package.json` (raiz) - Config completa
- ✅ `.gitignore` (raiz) - Regras Electron
- ✅ `electron/tsconfig.json` - Config TypeScript Electron
- ✅ `tsconfig.json` (raiz) - Includes e paths
- ✅ `run-electron.bat` - Script Windows
- ✅ `start-electron.ps1` - Script PowerShell

---

## ✅ Resumo Rápido

**Arquivos obrigatórios para migração**:

1. ✅ `.gitignore` - Adicionar regras Electron
2. ✅ `package.json` - Adicionar `main`, scripts, `build`
3. ✅ `tsconfig.json` (raiz) - Adicionar electron em `include`
4. ✅ `electron/tsconfig.json` - Criar novo
5. ✅ Ícones - `icon.ico`, `icon.icns`, `icon.png`

**Arquivos opcionais mas recomendados**:

1. ⭐ `run-electron.bat` - Script helper Windows
2. ⭐ `start-electron.ps1` - Script helper PowerShell
3. ⭐ `.env.example` - Template env vars
4. ⭐ `dev-full.bat` - Script automático completo

---

**Status**: ✅ Templates de Configuração Prontos

**Uso**: Copiar e personalizar conforme necessário no novo projeto!

