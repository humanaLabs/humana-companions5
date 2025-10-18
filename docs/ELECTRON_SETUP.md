# Configuração do Electron - Humana Companions

## Visão Geral

Este documento descreve a implementação do Electron no projeto Humana Companions. A estratégia implementada é baseada em uma arquitetura híbrida que permite que a aplicação Next.js funcione tanto como web app quanto como aplicação desktop.

## Estrutura de Arquivos

```
electron/
├── builder/                 # Recursos para electron-builder (ícones, etc)
├── main/                    # Processo principal do Electron
│   ├── index.ts            # Ponto de entrada principal
│   ├── window.ts           # Gerenciamento de janela
│   └── utils.ts            # Funções utilitárias
├── preload/                # Scripts de preload
│   └── index.ts            # Exposição de APIs via contextBridge
├── types/                  # Definições de tipos TypeScript
│   └── native.d.ts         # Tipos globais do Electron
└── tsconfig.json           # Configuração TypeScript para Electron
```

## Scripts Disponíveis

### Desenvolvimento

```bash
# Compilar TypeScript do Electron
pnpm electron:compile

# Compilar TypeScript em modo watch
pnpm electron:watch

# Iniciar Electron (requer Next.js rodando)
pnpm electron:start

# Desenvolvimento completo (Next.js + Electron + watch)
pnpm electron:dev

# Desenvolvimento no Windows (alternativa)
pnpm electron:dev:win
```

### Scripts de Automação

#### Windows PowerShell
```powershell
.\start-electron.ps1
```
Este script:
1. Compila o TypeScript do Electron
2. Configura variável de ambiente `NODE_ENV=development`
3. Inicia o Electron

#### Windows Batch
```cmd
.\run-electron.bat
```
Este script:
1. Verifica se Next.js está rodando
2. Compila o TypeScript do Electron
3. Inicia o Electron em processo separado

### Build para Produção

```bash
# Build completo
pnpm dist

# Build apenas para Windows
pnpm dist:win

# Build apenas para macOS
pnpm dist:mac

# Build apenas para Linux
pnpm dist:linux
```

## Como Usar

### Desenvolvimento (Método 1 - Automático)

1. Inicie o servidor Next.js:
```bash
pnpm dev
```

2. Em outro terminal, inicie o Electron em modo dev:
```bash
pnpm electron:dev
```

### Desenvolvimento (Método 2 - Manual)

1. Inicie o servidor Next.js:
```bash
pnpm dev
```

2. Use um dos scripts de automação:
```bash
# PowerShell
.\start-electron.ps1

# ou Batch
.\run-electron.bat
```

### Build de Produção

1. Execute o build:
```bash
pnpm dist:win
```

2. Os executáveis serão gerados em `electron-dist/`

## Configuração

### Arquivo Principal (electron/main/index.ts)

O arquivo principal gerencia o ciclo de vida da aplicação:
- Cria a janela principal
- Gerencia eventos do app (ready, window-all-closed, activate)
- Carrega a URL do Next.js (localhost em dev, produção em build)

### Janela (electron/main/window.ts)

Configurações da janela:
- Dimensões: 1280x800 (min: 800x600)
- Menu oculto automaticamente
- Segurança:
  - `nodeIntegration: false`
  - `contextIsolation: true`
  - `sandbox: true`
  - `webSecurity: true`
- Navegação restrita a origens permitidas
- Links externos abrem no navegador padrão

### Preload (electron/preload/index.ts)

Expõe APIs seguras para o renderer via `contextBridge`:
- `window.env`: Informações do ambiente Electron
  - `isElectron`: boolean
  - `platform`: NodeJS.Platform
  - `version`: string (versão do Electron)

### Utilitários (electron/main/utils.ts)

Funções auxiliares:
- `isDevelopment()`: Verifica se está em modo desenvolvimento
- `npxCmd()`: Retorna o comando npx correto para a plataforma
- `getStartUrl()`: Retorna a URL inicial (localhost ou produção)

## Configuração do electron-builder

No `package.json`:

```json
{
  "build": {
    "appId": "com.humana.companions",
    "productName": "Humana Companions",
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
    }
  }
}
```

## Segurança

A implementação segue as melhores práticas de segurança do Electron:

1. **Isolamento de Contexto**: `contextIsolation: true`
2. **Sem Integração Node**: `nodeIntegration: false`
3. **Sandbox Ativo**: `sandbox: true`
4. **Segurança Web**: `webSecurity: true`
5. **Navegação Restrita**: Whitelist de origens permitidas
6. **Links Externos**: Abrem no navegador padrão

## Variáveis de Ambiente

### ELECTRON_START_URL
Define a URL inicial do Electron (padrão: `http://localhost:3000`)

Exemplo:
```bash
$env:ELECTRON_START_URL = "http://localhost:3001"
```

### NODE_ENV
Define o ambiente (development ou production)

## Detecção no Frontend

Para detectar se a aplicação está rodando no Electron:

```typescript
// TypeScript
if (window.env?.isElectron) {
  console.log('Rodando no Electron');
  console.log('Plataforma:', window.env.platform);
  console.log('Versão:', window.env.version);
}
```

## Troubleshooting

### Erro: "Cannot find module 'electron'"
Instale as dependências:
```bash
pnpm install
```

### Erro na compilação TypeScript
Verifique se o tsconfig.json do Electron está correto:
```bash
pnpm electron:compile
```

### Next.js não está rodando
O Electron precisa do Next.js rodando. Inicie em outro terminal:
```bash
pnpm dev
```

### Janela em branco
Verifique se a URL está correta:
1. Em dev: Next.js deve estar em http://localhost:3000
2. Verifique o console do Electron para erros

## Próximos Passos

Esta é a implementação básica do Electron. Para adicionar funcionalidades:

1. **Ícones**: Adicione ícones em `electron/builder/`
2. **Menu Personalizado**: Crie menu customizado em `electron/main/menu.ts`
3. **IPC Handlers**: Adicione comunicação entre processos
4. **Auto-Update**: Configure atualização automática
5. **Notificações**: Implemente notificações nativas

## Referências

- [Documentação Oficial do Electron](https://www.electronjs.org/docs)
- [Electron Security Best Practices](https://www.electronjs.org/docs/tutorial/security)
- [electron-builder Documentation](https://www.electron.build/)

