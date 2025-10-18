# 🚀 Electron - Início Rápido

## Desenvolvimento

### Opção 1: Script Automático (Recomendado)

```bash
# Terminal 1 - Next.js
pnpm dev

# Terminal 2 - Electron
.\run-electron.bat
```

### Opção 2: Modo Dev Completo

```bash
pnpm electron:dev
```

Este comando inicia automaticamente:
- ✅ Next.js dev server
- ✅ Compilação TypeScript em watch mode
- ✅ Electron em modo desenvolvimento

### Opção 3: PowerShell

```powershell
# Terminal 1 - Next.js
pnpm dev

# Terminal 2 - Electron
.\start-electron.ps1
```

## Build de Produção

```bash
# Windows
pnpm dist:win

# macOS
pnpm dist:mac

# Linux
pnpm dist:linux
```

Os executáveis ficam em: `electron-dist/`

## Comandos Úteis

```bash
# Compilar TypeScript do Electron
pnpm electron:compile

# Compilar em modo watch
pnpm electron:watch

# Iniciar apenas o Electron (requer Next.js rodando)
pnpm electron:start
```

## Estrutura

```
electron/
├── main/       # Processo principal
├── preload/    # Scripts de preload
├── types/      # Tipos TypeScript
└── builder/    # Recursos (ícones, etc)
```

## Documentação Completa

Para mais detalhes, consulte: [docs/ELECTRON_SETUP.md](docs/ELECTRON_SETUP.md)

## Detecção no Frontend

```typescript
if (window.env?.isElectron) {
  console.log('Rodando no Electron');
}
```

## Troubleshooting

### ❌ "Cannot find module 'electron'"
```bash
pnpm install
```

### ❌ Janela em branco
Verifique se o Next.js está rodando em http://localhost:3000

### ❌ Erro na compilação
```bash
pnpm electron:compile
```

