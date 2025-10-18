# 01 - Preparação e Pré-requisitos

## ✅ Objetivos desta Etapa

- Verificar requisitos do sistema
- Preparar ambiente de desenvolvimento
- Fazer backup do projeto
- Entender a estrutura atual do Next.js

---

## 🔍 1. Verificação de Requisitos

### 1.1 Node.js e Package Manager

```bash
# Verificar versões
node --version    # Precisa: >= 18.0.0
pnpm --version    # Recomendado: >= 8.0.0

# Se não tiver pnpm, instalar:
npm install -g pnpm@latest
```

**Versões recomendadas**:
- Node.js: **20.x** (LTS)
- pnpm: **9.x**

### 1.2 Sistema Operacional

| OS | Versão Mínima | Notas |
|----|---------------|-------|
| Windows | 10 (64-bit) | Visual Studio Build Tools necessário para build |
| macOS | 12 (Monterey) | Xcode CLI Tools necessário |
| Linux | Ubuntu 20.04+ | build-essential necessário |

### 1.3 Verificar Estrutura do Projeto

Seu projeto Next.js deve ter:

```bash
seu-projeto/
├── app/           # (App Router) ou pages/ (Pages Router)
├── components/    # Componentes React
├── lib/          # (Opcional) Lógica/utils
├── public/       # Assets estáticos
├── package.json
├── next.config.ts (ou .js)
└── tsconfig.json  # (se usar TypeScript)
```

✅ **Funciona com**:
- Next.js 13, 14, 15
- App Router OU Pages Router
- JavaScript OU TypeScript
- Qualquer biblioteca de UI (Tailwind, MUI, etc)

---

## 🛡️ 2. Backup e Controle de Versão

### 2.1 Criar Branch de Migração

```bash
# Garantir que está na branch main/master limpa
git status

# Se tiver mudanças não commitadas, commitar:
git add .
git commit -m "chore: backup before electron migration"

# Criar branch para migração
git checkout -b feature/electron-migration
```

### 2.2 Tag de Backup (Opcional)

```bash
# Criar tag de backup
git tag -a pre-electron-v1.0 -m "Backup before Electron migration"
git push origin pre-electron-v1.0
```

### 2.3 Verificar .gitignore

**📦 Template completo disponível**: [13-arquivos-config.md](./13-arquivos-config.md)

Adicionar ao `.gitignore`:

```bash
# Electron
electron-dist/
electron/main/**/*.js
electron/main/**/*.js.map
electron/preload/**/*.js
electron/preload/**/*.js.map
*.app
*.dmg
*.exe
*.msi
*.deb
*.rpm
*.AppImage
```

---

## 📊 3. Análise do Projeto Atual

### 3.1 Inventário de Funcionalidades

Listar funcionalidades críticas do seu app:

```markdown
**Exemplo**:
- [ ] Login/Autenticação (NextAuth, Supabase, etc)
- [ ] Chat/Mensagens
- [ ] Upload de arquivos
- [ ] API Routes
- [ ] Database (Prisma, Drizzle, etc)
- [ ] Outras...
```

⚠️ **Importante**: Todas essas funcionalidades continuarão funcionando na web e no desktop.

### 3.2 Identificar Pontos de Integração

Onde você quer integrar recursos desktop:

- **Sidebar/Menu**: Onde adicionar botões MCP?
- **Input/Chat**: Onde interceptar comandos `/pw`?
- **Configurações**: Onde mostrar info sobre desktop?

📝 **Anote** esses pontos - usaremos na etapa 7.

---

## 🔧 4. Preparar Ambiente de Desenvolvimento

### 4.1 Instalar Ferramentas de Build

#### Windows

```powershell
# Opção 1: Visual Studio Build Tools (Recomendado)
# Baixar e instalar: https://visualstudio.microsoft.com/downloads/
# Selecionar: "Desktop development with C++"

# Opção 2: Via Chocolatey
choco install visualstudio2019-workload-vctools

# Verificar instalação
npm config get msvs_version
```

#### macOS

```bash
# Instalar Xcode Command Line Tools
xcode-select --install

# Verificar instalação
xcode-select -p
# Deve mostrar: /Library/Developer/CommandLineTools
```

#### Linux (Ubuntu/Debian)

```bash
# Instalar build-essential
sudo apt update
sudo apt install -y build-essential

# Verificar instalação
gcc --version
make --version
```

### 4.2 Verificar Playwright (Opcional)

```bash
# Playwright será instalado automaticamente
# Mas você pode pré-instalar browsers:
pnpm dlx playwright install chromium

# Ou esperar - será instalado na primeira execução
```

---

## 📋 5. Checklist de Preparação

Antes de continuar, confirme:

- [ ] Node.js 18+ instalado
- [ ] pnpm (ou npm/yarn) funcionando
- [ ] Projeto Next.js funcionando: `pnpm dev`
- [ ] Build atual funciona: `pnpm build`
- [ ] Git configurado e branch criada
- [ ] .gitignore atualizado
- [ ] Backup/tag criado
- [ ] Ferramentas de build instaladas (Windows/macOS/Linux)
- [ ] Inventário de funcionalidades feito
- [ ] Pontos de integração identificados

---

## 🎯 6. Teste do Projeto Atual

Antes de começar, **garanta que tudo funciona**:

```bash
# 1. Instalar dependências
pnpm install

# 2. Rodar em dev
pnpm dev

# 3. Abrir http://localhost:3000
# Navegar pelo app, testar funcionalidades

# 4. Build de produção
pnpm build
pnpm start

# 5. Testar novamente
```

✅ **Tudo funcionando?** Prosseguir para próxima etapa.  
❌ **Algo quebrado?** Corrigir antes de migrar.

---

## 📝 7. Documentar Estado Atual

Criar arquivo `MIGRATION_LOG.md` (opcional, mas recomendado):

```markdown
# Migration Log - Electron + MCP

## Data Início
[DATA]

## Versão Next.js
[VERSÃO]

## Funcionalidades Críticas
- [x] Login
- [x] Chat
- [x] Upload
...

## Notas
...
```

---

## 🚨 Problemas Comuns

### ❌ pnpm não encontrado
```bash
npm install -g pnpm@latest
```

### ❌ Node.js versão antiga
```bash
# Usar nvm (Node Version Manager)
nvm install 20
nvm use 20
```

### ❌ Erro de permissões (Linux/macOS)
```bash
# NÃO usar sudo npm install
# Corrigir permissões:
mkdir ~/.npm-global
npm config set prefix '~/.npm-global'
echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.bashrc
source ~/.bashrc
```

### ❌ Build tools não instaladas (Windows)
- Instalar Visual Studio Build Tools 2019+
- Reiniciar terminal após instalação

---

## ✅ Validação da Etapa

Antes de prosseguir, confirme:

1. ✅ Projeto Next.js rodando normalmente
2. ✅ Build funcionando
3. ✅ Git branch criado
4. ✅ Backup feito
5. ✅ Ferramentas de build instaladas

---

## ➡️ Próxima Etapa

**[02-estrutura-arquivos.md](./02-estrutura-arquivos.md)** - Criar estrutura de pastas Electron

---

**Status**: ✅ Preparação Concluída

