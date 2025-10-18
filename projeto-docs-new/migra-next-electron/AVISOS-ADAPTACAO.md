# ⚠️ AVISOS DE ADAPTAÇÃO - LEIA ANTES DE COPIAR!

**Data**: 2025-10-18  
**Versão**: 1.1.0  
**Status**: 🚨 CRÍTICO - LEIA ISTO!

---

## 🚨 ALERTA VERMELHO

**NEM TODOS OS ARQUIVOS podem ser copiados "cegamente"!**

Alguns arquivos têm **DEPENDÊNCIAS ESPECÍFICAS** que podem não existir no seu projeto!

---

## ✅ Arquivos SEGUROS (Copiar Direto - 100%)

Estes podem ser copiados **literalmente** sem modificação:

### 1. Electron (Pasta Completa) ✅
```
electron/
├── main/         ✅ Copiar TODO
├── preload/      ✅ Copiar TODO
└── types/        ✅ Copiar TODO
```

**Por quê**: Código 100% independente, não depende de nada do Next.js.

**Ação**: 
```bash
xcopy electron ..\..\seu-projeto\electron\ /E /I /Y
```

### 2. Runtime Detection/Client ✅
```
lib/runtime/
├── detection.ts       ✅ Copiar direto
└── electron-client.ts ✅ Copiar direto
```

**Por quê**: Apenas funções puras, sem deps externas.

**Ação**:
```bash
copy lib-runtime\detection.ts ..\..\seu-projeto\lib\runtime\
copy lib-runtime\electron-client.ts ..\..\seu-projeto\lib\runtime\
```

### 3. Scripts ✅
```
build-production.ps1  ✅ Copiar direto
run-electron.bat      ✅ Copiar direto
start-electron.ps1    ✅ Copiar direto
```

**Por quê**: Scripts shell, funcionam em qualquer projeto.

**Ação**:
```bash
copy *.ps1 ..\..\seu-projeto\
copy *.bat ..\..\seu-projeto\
```

### 4. Configs Simples ✅
```
biome.jsonc           ✅ Copiar direto (se não tiver outro linter)
components.json       ✅ Copiar direto (se usar shadcn/ui)
electron.env.example  ✅ Copiar direto (é template)
CHANGELOG.md          ✅ Copiar direto (é template)
```

---

## ⚠️ Arquivos que PRECISAM Adaptação

### 1. mcp-menu.tsx 🚨 ADAPTAÇÃO NECESSÁRIA

```
╔═══════════════════════════════════════════════════════╗
║  ⚠️  ESTE ARQUIVO TEM DEPENDÊNCIAS ESPECÍFICAS!      ║
╚═══════════════════════════════════════════════════════╝
```

**Dependências**:
- ❌ `shadcn/ui Button` - Pode não existir no seu projeto
- ❌ `sonner` (toast) - Pode não estar instalado
- ❌ `lucide-react` - Pode não estar instalado
- ❌ `Tailwind CSS` - Pode não usar

**O que fazer**:

#### Opção A: Instalar Dependências
```bash
pnpm add sonner lucide-react
pnpx shadcn@latest add button
```

#### Opção B: Adaptar Código

**Substituir Button**:
```typescript
// De:
import { Button } from "./ui/button";

// Para (exemplo Material UI):
import { Button } from "@mui/material";

// Ou HTML puro:
// Substituir <Button> por <button className="...">
```

**Substituir Toast**:
```typescript
// De:
import { toast } from "sonner";
toast.success("Mensagem");

// Para:
// alert("Mensagem");
// ou console.log("Mensagem");
// ou seu sistema de notificação
```

**Substituir Ícones**:
```typescript
// De:
import { Chrome, Camera } from "lucide-react";

// Para (react-icons):
import { FaChrome, FaCamera } from "react-icons/fa";

// Ou emojis:
// <span>🌐</span> ao invés de <Chrome />
```

**Substituir Tailwind**:
```typescript
// De:
className="border-gray-200 p-4"

// Para CSS Modules:
import styles from "./mcp-menu.module.css";
className={styles.container}

// Ou styled-components:
const Container = styled.div`
  border: 1px solid #e5e7eb;
  padding: 1rem;
`;
```

---

### 2. package.json 🚨 NÃO COPIAR DIRETO!

```
╔═══════════════════════════════════════════════════════╗
║  ❌ NUNCA SOBRESCREVA SEU package.json!              ║
╚═══════════════════════════════════════════════════════╝
```

**O que fazer**:

1. **Abra os DOIS** `package.json` (seu + referência)
2. **Copie MANUALMENTE** apenas:
   - Scripts do Electron (`electron:*`, `dist:*`)
   - Dependências novas (`electron`, `@modelcontextprotocol/sdk`, etc)
   - Config `electron-builder`
   - Campo `main`

**NÃO copie**:
- Nome do projeto
- Versão
- Dependências existentes
- Scripts existentes

---

### 3. tsconfig.json ⚠️ MERGE NECESSÁRIO

```
╔═══════════════════════════════════════════════════════╗
║  ⚠️  MERGE com seu tsconfig existente!               ║
╚═══════════════════════════════════════════════════════╝
```

**O que fazer**:

1. **Não sobrescreva** seu `tsconfig.json`
2. **Adicione** ao seu:
   ```json
   {
     "exclude": [
       "electron"
     ]
   }
   ```
3. **Use** o `electron/tsconfig.json` como está (novo)

---

### 4. next.config.ts ⚠️ REFERÊNCIA APENAS

```
╔═══════════════════════════════════════════════════════╗
║  ℹ️  Use como REFERÊNCIA, não copie direto!          ║
╚═══════════════════════════════════════════════════════╝
```

**O que fazer**:

- **NÃO copie** - Use o seu existente
- **Veja** se há configs interessantes
- **Adapte** se necessário

---

## 📋 Checklist de Adaptação

### Antes de Copiar Qualquer Arquivo

- [ ] Li os avisos no topo do arquivo?
- [ ] Verifiquei as dependências?
- [ ] Tenho as deps instaladas OU sei como substituir?
- [ ] Li a documentação sobre aquele arquivo?

### Específico para mcp-menu.tsx

- [ ] Tenho ou instalarei `sonner`?
- [ ] Tenho ou instalarei `lucide-react`?
- [ ] Tenho `shadcn/ui Button` OU adaptarei?
- [ ] Uso Tailwind OU adaptarei estilos?

### Específico para Configs

- [ ] NÃO vou sobrescrever `package.json` direto?
- [ ] Vou fazer MERGE do `tsconfig.json`?
- [ ] NÃO vou copiar `next.config.ts`?

---

## 🎯 Estratégia Recomendada

### 1. Copiar Arquivos Seguros (100%)
```bash
# Electron completo
xcopy electron ..\..\seu-projeto\electron\ /E /I /Y

# Runtime
copy lib-runtime\detection.ts ..\..\seu-projeto\lib\runtime\
copy lib-runtime\electron-client.ts ..\..\seu-projeto\lib\runtime\

# Scripts
copy *.ps1 ..\..\seu-projeto\
copy *.bat ..\..\seu-projeto\
```

### 2. Adaptar mcp-menu.tsx

**Opção A**: Instalar deps e copiar
```bash
pnpm add sonner lucide-react
pnpx shadcn@latest add button
copy mcp-menu.tsx ..\..\seu-projeto\components\
```

**Opção B**: Adaptar código antes de copiar
```bash
# 1. Copiar
copy mcp-menu.tsx ..\..\seu-projeto\components\

# 2. Abrir e adaptar imports/deps
code ..\..\seu-projeto\components\mcp-menu.tsx
```

### 3. Merge Configs Manualmente

**NÃO use `copy`!** Abra lado a lado e merge:
- `package.json` - Adicione scripts e deps
- `tsconfig.json` - Adicione exclude

---

## 🚨 Avisos nos Arquivos

Os seguintes arquivos têm **AVISOS GRANDES** no topo:

### mcp-menu.tsx
```typescript
/*
╔═══════════════════════════════════════════════════════╗
║  ⚠️  ⚠️  ⚠️  ATENÇÃO! ADAPTAÇÃO NECESSÁRIA!         ║
╚═══════════════════════════════════════════════════════╝

❌ NÃO COPIE CEGAMENTE!
...
*/
```

**Se você ver esses avisos, PARE e LEIA antes de copiar!**

---

## 📊 Resumo Visual

```
┌─────────────────────────────────────────────────┐
│  COPIAR DIRETO (✅)                             │
├─────────────────────────────────────────────────┤
│  electron/          (pasta completa)            │
│  lib-runtime/       (detection, client)         │
│  Scripts            (.ps1, .bat)                │
│  electron.env.example                           │
└─────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────┐
│  ADAPTAR/INSTALAR DEPS (⚠️)                     │
├─────────────────────────────────────────────────┤
│  mcp-menu.tsx       (deps: sonner, lucide, etc) │
└─────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────┐
│  MERGE MANUAL (🚨)                              │
├─────────────────────────────────────────────────┤
│  package.json       (NUNCA sobrescrever!)       │
│  tsconfig.json      (merge exclude)             │
└─────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────┐
│  REFERÊNCIA (ℹ️)                                │
├─────────────────────────────────────────────────┤
│  next.config.ts     (use o seu)                 │
│  playwright.config.ts (opcional)                │
└─────────────────────────────────────────────────┘
```

---

## ✅ Conclusão

### Regra de Ouro

```
╔════════════════════════════════════════════════════╗
║                                                    ║
║  SE O ARQUIVO TEM IMPORTS, VERIFIQUE AS DEPS!     ║
║                                                    ║
║  SE O ARQUIVO É CONFIG, FAÇA MERGE!               ║
║                                                    ║
║  SE TEM DÚVIDA, LEIA A DOCUMENTAÇÃO!              ║
║                                                    ║
╚════════════════════════════════════════════════════╝
```

### Em Caso de Erro

1. **Leu os avisos?** - Volte e leia
2. **Verificou deps?** - Instale ou adapte
3. **Fez merge correto?** - Não sobrescreva configs
4. **Consultou docs?** - Ver `07-integracao-ui.md`

---

**Versão**: 1.1.0  
**Data**: 2025-10-18  
**Status**: 🚨 AVISOS CRÍTICOS ADICIONADOS  
**Mensagem**: NÃO copie cegamente! Verifique deps!

