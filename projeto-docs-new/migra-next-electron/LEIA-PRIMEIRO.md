# ⚠️ LEIA PRIMEIRO - Avisos Importantes!

---

## 🚨 ATENÇÃO: Componentes UI

### ❌ NÃO Copiar Estes Componentes

Os seguintes componentes **NÃO devem ser copiados** para o próximo projeto:

- ❌ `app-sidebar.tsx` - Vai conflitar com o sidebar existente
- ❌ `computer-use-menu.tsx` - Não será usado (foco apenas MCP Playwright)
- ❌ `multimodal-input.tsx` - Vai conflitar com o input existente
- ❌ Qualquer outro componente que JÁ EXISTE no seu projeto

**Por quê?**
- Esses arquivos vão **sobrescrever** seus componentes existentes
- Você vai **perder** suas customizações
- Vai **quebrar** sua UI atual

---

## ✅ O Que Copiar

### Copie APENAS o Componente Novo:

```bash
# ✅ COPIAR (componente novo)
copy mcp-menu.tsx ..\..\seu-projeto\components\
```

**Este é o ÚNICO componente novo que deve ser copiado!**

---

## 📝 O Que a Documentação Faz

A documentação (especialmente `07-integracao-ui.md`) **explica O QUE fazer** nos seus componentes existentes:

### Exemplo: Sidebar

**❌ NÃO FAÇA**:
```bash
copy app-sidebar.tsx ..\..\seu-projeto\components\
# Isso vai sobrescrever seu sidebar!
```

**✅ FAÇA**:
1. Abra o `app-sidebar.tsx` que JÁ EXISTE no seu projeto
2. Adicione o import: `import { MCPMenu } from "@/components/mcp-menu";`
3. Adicione `<MCPMenu />` onde fizer sentido
4. Pronto!

### ⚠️ Integração de Chat Removida

**IMPORTANTE**: Este guia NÃO inclui integração com chat/input!

**Foco**: Apenas menu visual com botões na sidebar.

**Sem**: Comandos `/pw` no chat.

**Por quê**: Evitar complexidade desnecessária e conflitos com input existente.

---

## 🗂️ Arquivos de Referência vs Arquivos para Copiar

### Para Copiar (Novos)

```
✅ electron/               (pasta completa)
✅ lib-runtime/            (pasta completa)
✅ mcp-menu.tsx            (componente novo)
✅ build-production.ps1    (script)
✅ run-electron.bat        (script)
✅ start-electron.ps1      (script)
✅ biome.jsonc             (config)
✅ electron.env.example    (template)
```

### Para Referenciar (NÃO copiar)

```
📖 app-sidebar.tsx         (VER o código, NÃO copiar)
📖 computer-use-menu.tsx   (Ignorar - não será usado)
```

**Estes arquivos estão aqui como REFERÊNCIA** para você ver como foi feito no projeto original, mas você deve **implementar a lógica no SEU código existente**, não copiar.

**Nota**: Não há integração com chat/input neste guia - apenas menu visual.

---

## 📚 Como Usar a Documentação

### 1. Leia os Guias

Os guias **explicam COMO integrar**, não são para copiar código cegamente:

- `04-electron-core.md` - Código novo (pode copiar)
- `05-mcp-playwright.md` - Código novo (pode copiar)
- `06-adaptacao-nextjs.md` - Código novo (pode copiar)
- `07-integracao-ui.md` - **Apenas menu na sidebar** (adapte seu sidebar) ⚠️
- `08-build-deploy.md` - Scripts e configs (pode copiar)

### 2. Entenda a Diferença

**Código Novo** (criar do zero):
- `electron/` - Não existe no Next.js
- `lib/runtime/` - Não existe no Next.js
- `mcp-menu.tsx` - Componente totalmente novo

**Código Existente** (adaptar):
- Sidebar - JÁ existe no seu projeto (adicionar `<MCPMenu />`)
- Input de chat - **NÃO** será modificado (sem integração)
- Outros componentes UI - JÁ existem

---

## 🎯 Regra de Ouro

### Pergunte-se:

**"Este arquivo JÁ EXISTE no meu projeto?"**

- ✅ **NÃO existe** → Pode copiar do guia
- ❌ **JÁ existe** → Apenas ADAPTE seguindo a documentação

---

## 🔍 Checklist Antes de Copiar

Antes de copiar qualquer arquivo, verifique:

- [ ] O arquivo é NOVO (não existe no meu projeto)?
- [ ] Não vou sobrescrever código existente?
- [ ] Não vou perder minhas customizações?
- [ ] Li a documentação sobre como integrar?

Se respondeu SIM para todas, pode copiar!

---

## 📞 Em Caso de Dúvida

**Antes de copiar qualquer componente UI**:

1. Leia `07-integracao-ui.md` COMPLETAMENTE
2. Verifique se o componente existe no seu projeto
3. Se existe, apenas adapte (não copie)
4. Se não existe, pode copiar

**Componentes seguros para copiar**:
- ✅ `mcp-menu.tsx` (novo, não vai conflitar)

**Componentes que NÃO devem ser copiados**:
- ❌ `app-sidebar.tsx` (conflita - adapte o seu)
- ❌ `computer-use-menu.tsx` (não será usado)
- ❌ Qualquer outro que já exista

**Integração de chat removida**:
- ℹ️ Sem comandos `/pw` no input
- ℹ️ Apenas menu visual com botões
- ℹ️ Simplificação proposital

---

## 🎉 Resumo

```
┌──────────────────────────────────────────────────┐
│  RESUMO IMPORTANTE                               │
├──────────────────────────────────────────────────┤
│                                                  │
│  ✅ COPIAR:                                      │
│     - electron/ (pasta completa)                │
│     - lib-runtime/ (pasta completa)             │
│     - mcp-menu.tsx (componente novo)            │
│     - Scripts (.ps1, .bat)                      │
│     - Configs (biome, env.example)              │
│                                                  │
│  ❌ NÃO COPIAR:                                  │
│     - app-sidebar.tsx                           │
│     - computer-use-menu.tsx                     │
│     - Qualquer componente que já existe         │
│                                                  │
│  📖 REFERENCIAR:                                 │
│     - Ver COMO foi feito                        │
│     - ADAPTAR no seu código                     │
│     - NÃO copiar direto                         │
│                                                  │
└──────────────────────────────────────────────────┘
```

---

## 🚀 Próximos Passos

**Começar Agora**:

1. ⭐ **[00-COMECE-AQUI.md](./00-COMECE-AQUI.md)** - Guia master passo a passo (RECOMENDADO)
2. 🚨 **[AVISOS-ADAPTACAO.md](./AVISOS-ADAPTACAO.md)** - O QUE adaptar
3. ⚡ **[QUICK-START.md](./QUICK-START.md)** - Migração express (25min)

**Entender Organização**:

4. 📚 **[INDICE-ORDEM.md](./INDICE-ORDEM.md)** - Ordem de leitura
5. 📑 **[00-INDEX-VISUAL.md](./00-INDEX-VISUAL.md)** - Visão geral

---

## ✅ Pronto!

Agora você está **preparado** para migrar sem quebrar nada!

**Boa migração! 🚀**

---

**Versão**: 1.0.0  
**Data**: 2025-10-18  
**Status**: ⚠️ LEIA ANTES DE COMEÇAR!

