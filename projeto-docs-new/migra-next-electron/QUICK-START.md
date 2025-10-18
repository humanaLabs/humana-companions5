# ⚡ Quick Start - Migração Express (25min)

**Para quem quer migrar RÁPIDO sem ler tudo!**

---

## 🚨 ANTES DE COMEÇAR

**⚠️ PREFERE GUIA COMPLETO COM TESTES?**
👉 **[00-COMECE-AQUI.md](./00-COMECE-AQUI.md)** - Guia master passo a passo!

**⚠️ LEIA OBRIGATORIAMENTE**:
- 📖 [AVISOS-ADAPTACAO.md](./AVISOS-ADAPTACAO.md) - **O QUE adaptar** (5min)

**Nem todos os arquivos podem ser copiados "cegamente"!**  
**Alguns precisam de adaptação (deps, configs)!**

---

## 🎯 Objetivo

Adicionar **Electron + MCP Playwright** ao seu projeto Next.js em **~25 minutos**.

---

## ✅ Pré-requisitos (5min)

```bash
# Verificar
node --version    # >= 18
pnpm --version    # >= 8

# Backup
git checkout -b feature/electron-quick
git commit -m "backup: before electron migration"
```

---

## 📦 1. Copiar Arquivos (3min)

**Do diretório `docs/migra-next-electron/` para raiz do seu projeto:**

```bash
# Windows CMD
cd docs\migra-next-electron

# Scripts
copy build-production.ps1 ..\..\
copy run-electron.bat ..\..\
copy start-electron.ps1 ..\..\

# Configs
copy biome.jsonc ..\..\
copy components.json ..\..\

# Electron
xcopy electron ..\..\electron\ /E /I /Y

# Runtime
xcopy lib-runtime ..\..\lib\runtime\ /E /I /Y

# Componente (apenas o NOVO)
copy mcp-menu.tsx ..\..\components\

# ⚠️ NÃO copie app-sidebar ou outros existentes!

# Voltar para raiz
cd ..\..
```

---

## 📝 2. Atualizar package.json (5min)

**Abra `package.json` e adicione:**

### Scripts
```json
{
  "scripts": {
    "dev": "next dev --turbo",
    "electron:compile": "tsc --project electron/tsconfig.json",
    "electron:watch": "tsc --project electron/tsconfig.json --watch",
    "electron:start": "cross-env NODE_ENV=development electron .",
    "electron:dev": "concurrently \"pnpm dev\" \"wait-on http://localhost:3000 && pnpm electron:watch\" \"wait-on http://localhost:3000 && wait-on electron/main/index.js && pnpm electron:start\"",
    "electron:build": "pnpm build && pnpm electron:compile",
    "dist": "pnpm electron:build && electron-builder",
    "dist:win": "pnpm electron:build && electron-builder --win",
    "dist:mac": "pnpm electron:build && electron-builder --mac",
    "dist:linux": "pnpm electron:build && electron-builder --linux"
  }
}
```

### Campo main
```json
{
  "main": "electron/main/index.js"
}
```

### electron-builder config
```json
{
  "build": {
    "appId": "com.seuapp.id",
    "productName": "Seu App",
    "directories": {
      "buildResources": "public"
    },
    "files": [
      "electron/main/**/*",
      "electron/preload/**/*",
      "!electron/**/*.ts",
      "!electron/**/*.map",
      "package.json"
    ],
    "win": {
      "target": ["nsis", "portable"],
      "icon": "public/icon.ico"
    },
    "mac": {
      "target": ["dmg", "zip"],
      "icon": "public/icon.icns",
      "category": "public.app-category.productivity"
    },
    "linux": {
      "target": ["AppImage", "deb"],
      "icon": "public/icon.png",
      "category": "Utility"
    }
  }
}
```

---

## 🔧 3. Instalar Dependências (3min)

```bash
pnpm add electron @modelcontextprotocol/sdk @playwright/mcp sonner

pnpm add -D electron-builder concurrently wait-on cross-env
```

---

## 🎨 4. Integrar UI - APENAS Menu (3min)

**⚠️ IMPORTANTE**: Edite o sidebar que JÁ EXISTE no seu projeto, não copie nenhum!

**Edite `components/app-sidebar.tsx`** (ou seu sidebar existente):

```typescript
import { MCPMenu } from "@/components/mcp-menu";

export function AppSidebar() {
  return (
    <Sidebar>
      {/* ... seu conteúdo existente ... */}
      
      <MCPMenu /> {/* ADICIONAR AQUI */}
      
      {/* ... resto do conteúdo ... */}
    </Sidebar>
  );
}
```

**Pronto!** A integração UI é **APENAS isso** - adicionar o menu na sidebar.

**Sem**: Comandos `/pw` no chat - foco apenas no menu visual com botões.

---

## 🔐 5. Atualizar .gitignore (1min)

**Adicione ao `.gitignore`:**

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

---

## 🧪 6. Testar (5min)

```bash
# Opção 1: Script helper
.\run-electron.bat

# Opção 2: Manual
pnpm dev           # Terminal 1
pnpm electron:dev  # Terminal 2
```

**Deve abrir**:
- ✅ App Electron com Next.js carregado
- ✅ Menu "Browser Control" na sidebar (só no desktop)

**Teste os botões do menu**:
- ✅ Clicar em "Navegar" (insira uma URL)
- ✅ Clicar em "Snapshot" (captura estrutura)
- ✅ Clicar em "Screenshot" (tira foto)
- ✅ Clicar em "Fechar" (fecha browser)

---

## 🏗️ 7. Build Produção (3min)

```bash
.\build-production.ps1
```

**Resultado**: `electron-dist/*.exe`

---

## ❌ Problemas Comuns

### Electron não abre
```bash
# Compilar TypeScript manualmente
pnpm electron:compile

# Verificar arquivo gerado
ls electron/main/index.js
```

### MCP não funciona
- Verifique internet (precisa baixar @playwright/mcp)
- Veja logs no terminal
- Tente: `npx @playwright/mcp@latest` (deve funcionar sozinho)

### Menu MCP não aparece
- Verifique se está rodando no Electron (não no browser)
- Console: `window.mcp` deve existir
- Tente reabrir o app

---

## ✅ Checklist Final

- [ ] Scripts copiados (`.bat`, `.ps1`)
- [ ] Pasta `electron/` copiada
- [ ] Pasta `lib/runtime/` copiada
- [ ] `package.json` atualizado
- [ ] Dependências instaladas
- [ ] UI integrada (apenas menu na sidebar)
- [ ] `.gitignore` atualizado
- [ ] App desktop abre (`.\run-electron.bat`)
- [ ] Menu MCP aparece
- [ ] Botões do menu funcionam
- [ ] Build produção OK (`.\build-production.ps1`)

---

## 📚 Próximos Passos

### Se Funcionou ✅
- Leia **[14-recursos-extras.md](./14-recursos-extras.md)** (boas práticas)
- Customize UI/UX conforme necessário
- Adicione ícones personalizados
- Configure auto-update (opcional)

### Se Teve Problemas ❌
- Leia **[09-troubleshooting.md](./09-troubleshooting.md)**
- Siga guia completo: **[00-README.md](./00-README.md)**
- Compare código com `electron/` e `lib-runtime/` aqui

---

## 🎓 Para Entender Melhor

**Recomendado ler (ordem de prioridade)**:

1. **[00-README.md](./00-README.md)** - Overview completo
2. **[04-electron-core.md](./04-electron-core.md)** - Como Electron funciona
3. **[05-mcp-playwright.md](./05-mcp-playwright.md)** - Como MCP funciona
4. **[06-adaptacao-nextjs.md](./06-adaptacao-nextjs.md)** - Feature detection
5. **[14-recursos-extras.md](./14-recursos-extras.md)** - Boas práticas

**Total**: ~2h de leitura para entender tudo

---

## 🚀 Resultado

Você agora tem:

✅ **Desktop app** funcionando  
✅ **MCP Playwright** integrado  
✅ **Comandos /pw** no chat  
✅ **Menu MCP** na sidebar  
✅ **Build** automatizado  

**Tempo total**: ~30min

---

## 🎉 Parabéns!

Você migrou seu projeto Next.js para Electron + MCP Playwright em tempo recorde!

**Para migração completa e detalhada**:  
➡️ [00-README.md](./00-README.md) (guia completo de 14 docs)

**Para ver todos os arquivos de referência**:  
➡️ [README-ARQUIVOS.md](./README-ARQUIVOS.md)

**Para visão geral visual**:  
➡️ [00-INDEX-VISUAL.md](./00-INDEX-VISUAL.md)

---

**Boa sorte! 🚀**

