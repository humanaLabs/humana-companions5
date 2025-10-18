# 08 - Build e Distribuição

## ✅ Objetivos desta Etapa

- Build de produção do Next.js
- Build de produção do Electron
- Gerar instaladores (Windows, macOS, Linux)
- Configurar auto-update (opcional)

---

## 🏗️ 1. Processo de Build

### 1.1 Entender o Fluxo

```
1. Build Next.js     → .next/ (otimizado)
2. Compile Electron  → electron/**/*.js
3. electron-builder  → Instaladores (.exe, .dmg, .AppImage)
```

**Importante**: Build Next.js **antes** de empacotar Electron.

---

## 📦 2. Build Next.js

### 2.1 Build Padrão

```bash
pnpm build
```

**O que faz**:
- Compila Next.js para produção
- Gera pasta `.next/`
- Otimiza assets

**Verificar**:
```bash
# Deve ter pasta .next/ criada
ls -la .next/

# Testar build
pnpm start
# Abrir http://localhost:3000
```

### 2.2 Build com Variáveis de Ambiente

Se precisar de env vars de produção:

```bash
# .env.production
NEXT_PUBLIC_API_URL=https://api.seudominio.com
DATABASE_URL=postgresql://...
```

Build:
```bash
NODE_ENV=production pnpm build
```

---

## 🔧 3. Compile Electron

### 3.1 Compilar TypeScript

```bash
pnpm electron:compile
```

**Verifica**:
```bash
# Deve ter arquivos .js criados
ls electron/main/*.js
ls electron/preload/*.js

# Verificar sem erros
cat electron/main/index.js  # Deve ter código compilado
```

### 3.2 Limpar Builds Anteriores (Opcional)

```bash
# Limpar arquivos compilados
rm -rf electron/main/*.js electron/main/*.js.map
rm -rf electron/preload/*.js electron/preload/*.js.map
rm -rf electron-dist/

# Recompilar
pnpm electron:compile
```

---

## 📦 4. Build Completo (Next.js + Electron)

### 4.1 Build Tudo de Uma Vez

```bash
pnpm electron:build
```

**O que faz**:
1. `pnpm build` - Build Next.js
2. `pnpm electron:compile` - Compile Electron
3. `electron-builder` - Gera instalador

**Tempo**: ~5-15 minutos (primeira vez)

### 4.2 Build por Plataforma

#### Windows

```bash
pnpm dist:win
```

**Gera**:
- `electron-dist/Seu App-Setup-1.0.0.exe` (instalador NSIS)
- `electron-dist/Seu App-1.0.0.exe` (portable)

**Tamanho**: ~150-200 MB

#### macOS

```bash
pnpm dist:mac
```

**Gera**:
- `electron-dist/Seu App-1.0.0.dmg` (instalador)

**Tamanho**: ~150-200 MB

⚠️ **Nota**: Em macOS, precisa de assinatura de código (ver seção 7).

#### Linux

```bash
pnpm dist:linux
```

**Gera**:
- `electron-dist/Seu App-1.0.0.AppImage` (executável)

**Tamanho**: ~150-200 MB

---

## ⚙️ 5. Configuração Avançada

### 5.1 Customizar package.json Build

Editar `package.json`, seção `build`:

```json
{
  "build": {
    "appId": "com.seudominio.seuapp",
    "productName": "Seu App Nome",
    "directories": {
      "output": "electron-dist",
      "buildResources": "electron/builder"
    },
    "files": [
      "electron/main/**/*.js",
      "electron/preload/**/*.js",
      "node_modules/**/*",
      "package.json",
      ".next/**/*",
      "public/**/*"
    ],
    "win": {
      "target": ["nsis", "portable"],
      "artifactName": "${productName}-Setup-${version}.${ext}",
      "icon": "public/icon.ico"
    },
    "mac": {
      "target": ["dmg"],
      "category": "public.app-category.productivity",
      "icon": "public/icon.icns"
    },
    "linux": {
      "target": ["AppImage"],
      "category": "Utility",
      "icon": "public/icon.png"
    }
  }
}
```

**Personalize**:
- `appId` - Identificador único (reverse domain)
- `productName` - Nome que usuário vê
- `icon` - Ícone do app (ver seção 5.2)

### 5.2 Adicionar Ícones

**Formatos necessários**:

| Plataforma | Formato | Tamanho | Caminho |
|-----------|---------|---------|---------|
| Windows | `.ico` | 256x256 | `public/icon.ico` |
| macOS | `.icns` | 512x512 | `public/icon.icns` |
| Linux | `.png` | 512x512 | `public/icon.png` |

**Gerar ícones**:

1. Ter imagem PNG de alta resolução (1024x1024)
2. Usar ferramenta online: [https://www.icoconverter.com/](https://www.icoconverter.com/)
3. Ou usar `electron-icon-maker`:

```bash
pnpm add -D electron-icon-maker

# Gerar todos os ícones
pnpx electron-icon-maker --input=./logo.png --output=./public/
```

---

## 🚀 6. Testar Build Local

### 6.1 Testar Antes de Distribuir

**Após build**:

```bash
# Build
pnpm dist:win  # (ou :mac ou :linux)

# Executar instalador gerado
# Windows
.\electron-dist\Seu App-Setup-1.0.0.exe

# macOS
open electron-dist/Seu App-1.0.0.dmg

# Linux
./electron-dist/Seu App-1.0.0.AppImage
```

### 6.2 Verificações

**Checklist**:
- [ ] App inicia normalmente
- [ ] Next.js carrega (localhost OU produção)
- [ ] MCP Playwright funciona
- [ ] Comandos `/pw` funcionam
- [ ] Menu MCP aparece
- [ ] Ícone correto
- [ ] Nome correto na barra de tarefas

---

## 📡 7. Distribuição

### 7.1 Distribuição Simples (GitHub Releases)

```bash
# 1. Criar tag
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0

# 2. Build para todas as plataformas
pnpm dist:win
pnpm dist:mac
pnpm dist:linux

# 3. Criar release no GitHub
# Ir para: https://github.com/seu-usuario/seu-repo/releases/new
# Anexar arquivos:
# - Seu App-Setup-1.0.0.exe
# - Seu App-1.0.0.dmg
# - Seu App-1.0.0.AppImage
```

### 7.2 Distribuição via GitHub Actions (CI/CD)

Criar `.github/workflows/build.yml`:

```yaml
name: Build Desktop App

on:
  push:
    tags:
      - 'v*'

jobs:
  build:
    strategy:
      matrix:
        os: [windows-latest, macos-latest, ubuntu-latest]
    
    runs-on: ${{ matrix.os }}
    
    steps:
      - uses: actions/checkout@v4
      
      - uses: pnpm/action-setup@v2
        with:
          version: 9
      
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: 'pnpm'
      
      - run: pnpm install
      
      - run: pnpm build
      - run: pnpm electron:compile
      
      - run: pnpm dist:win
        if: matrix.os == 'windows-latest'
      
      - run: pnpm dist:mac
        if: matrix.os == 'macos-latest'
      
      - run: pnpm dist:linux
        if: matrix.os == 'ubuntu-latest'
      
      - uses: actions/upload-artifact@v4
        with:
          name: app-${{ matrix.os }}
          path: electron-dist/*
```

**Uso**:
```bash
# Push tag
git tag v1.0.0
git push origin v1.0.0

# GitHub Actions builda automaticamente
# Baixar artifacts na página Actions
```

### 7.3 Code Signing (macOS/Windows)

**macOS** (obrigatório para distribuição):

```bash
# Precisa de:
# 1. Apple Developer Account ($99/ano)
# 2. Certificado de desenvolvedor

# Configurar em package.json
{
  "build": {
    "mac": {
      "identity": "Developer ID Application: Seu Nome (TEAM_ID)",
      "hardenedRuntime": true,
      "gatekeeperAssess": false,
      "entitlements": "build/entitlements.mac.plist",
      "entitlementsInherit": "build/entitlements.mac.plist"
    }
  }
}
```

Criar `build/entitlements.mac.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
  <dict>
    <key>com.apple.security.cs.allow-unsigned-executable-memory</key>
    <true/>
  </dict>
</plist>
```

**Windows** (opcional mas recomendado):

```bash
# Precisa de certificado code signing
# Custo: ~$100-300/ano

# Configurar em package.json
{
  "build": {
    "win": {
      "certificateFile": "path/to/cert.pfx",
      "certificatePassword": "password"
    }
  }
}
```

---

## 🔄 8. Auto-Update (Opcional)

### 8.1 Configurar electron-updater

Instalar:

```bash
pnpm add electron-updater
```

Atualizar `electron/main/index.ts`:

```typescript
import { autoUpdater } from "electron-updater";

// Após initialize()
if (!isDevelopment()) {
  autoUpdater.checkForUpdatesAndNotify();
}
```

Configurar `package.json`:

```json
{
  "build": {
    "publish": {
      "provider": "github",
      "owner": "seu-usuario",
      "repo": "seu-repo"
    }
  }
}
```

### 8.2 Publicar com Auto-Update

```bash
# Build e publica
pnpm electron:build --publish=always
```

---

## 🚨 Problemas Comuns

### ❌ Erro: "node-gyp rebuild failed"

**Causa**: Build tools não instaladas (Windows).

**Solução**: Instalar Visual Studio Build Tools (ver etapa 01).

### ❌ Build muito lento

**Causa**: Incluindo node_modules desnecessários.

**Solução**: Configurar `files` em `package.json`:

```json
{
  "build": {
    "files": [
      "!node_modules/@types/**",
      "!node_modules/.cache/**",
      "!**/*.ts",
      "!**/*.md"
    ]
  }
}
```

### ❌ Erro: "Cannot find module 'next'"

**Causa**: Next.js não incluído no build.

**Solução**: Adicionar em `files`:

```json
{
  "build": {
    "files": [
      ".next/**/*",
      "node_modules/**/*"
    ]
  }
}
```

### ❌ App abre mas tela branca

**Causa**: URL de produção incorreta.

**Verificar** `electron/main/utils.ts`:

```typescript
export function getStartUrl(): string {
  if (isDevelopment()) {
    return "http://localhost:3000";
  }
  // Em produção, usar URL pública
  return "https://seuapp.seudominio.com";
}
```

---

## 📋 Checklist da Etapa

Antes de distribuir:

- [ ] `pnpm build` funciona sem erros
- [ ] `pnpm electron:compile` funciona sem erros
- [ ] `pnpm electron:build` gera instalador
- [ ] Instalador testado localmente
- [ ] App funciona após instalação
- [ ] Ícone correto
- [ ] Nome correto
- [ ] MCP funciona
- [ ] URL de produção configurada (se aplicável)
- [ ] Code signing configurado (macOS/Windows)

---

## 🎯 Próxima Etapa

Build configurado! Agora vamos ver problemas comuns e soluções.

**[09-troubleshooting.md](./09-troubleshooting.md)** - Troubleshooting

---

**Status**: ✅ Build e Distribuição Configurados

