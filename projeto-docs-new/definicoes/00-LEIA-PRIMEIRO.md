# 🚀 LEIA PRIMEIRO - Guia de Navegação

## 📌 Ordem de Leitura Recomendada

Esta pasta contém a documentação completa da estrutura do projeto Humana AI Companions, incluindo o estado ATUAL e o estado IDEAL (alvo da migração).

### **Para Novos Desenvolvedores:**

1. **`README.md`** ← Comece aqui
   - Visão geral do sistema
   - Hierarquia e conceitos principais
   - Sistema de roles e permissões

2. **`Definicoes_banco_de_dados.txt`**
   - Entenda a modelagem do banco
   - Sistema de organizações, workspaces, companions
   - Uso de pgvector, RLS, ACL

3. **`Definicoes_estrutura_codigo_atual.txt`**
   - Veja como o código está HOJE
   - Entenda v1, v5, estrutura atual
   - Componentes compartilhados existentes

4. **`COMPARACAO-ATUAL-VS-IDEAL.md`**
   - Entenda os problemas atuais
   - Veja o que precisa mudar
   - Dependências críticas identificadas

5. **`Definicoes_estrutura_codigo.txt`**
   - Veja para onde estamos indo
   - Estrutura ideal pós-migração
   - Boas práticas e padrões

---

### **Para Desenvolvimento Imediato:**

Se você precisa **codar agora no sistema atual**, leia:
1. `Definicoes_estrutura_codigo_atual.txt` (estrutura real)
2. `Definicoes_banco_de_dados.txt` (modelagem do banco)
3. `README.md` (conceitos do sistema)

Se você está **planejando a migração**, leia:
1. `COMPARACAO-ATUAL-VS-IDEAL.md` (análise completa)
2. `Definicoes_estrutura_codigo.txt` (estrutura alvo)
3. `Definicoes_estrutura_codigo_atual.txt` (ponto de partida)

---

## 🎯 Contexto Rápido

### **Estado Atual do Projeto:**
- ✅ V1 operacional (sistema legado)
- ✅ V5 em desenvolvimento (AI SDK 5.0)
- ❌ V5 depende de V1/shared (problema crítico)
- ❌ 50+ componentes desorganizados
- ❌ Pastas experimentais e obsoletas

### **Objetivo da Migração:**
- ✅ V5 → nova V0 (versão única)
- ✅ V1 removida completamente
- ✅ Chat modular e organizado
- ✅ Backend reconstruído do zero
- ✅ Limpeza completa de código legado

---

## ⚠️ SEPARAÇÃO CRÍTICA: FRONTEND vs BACKEND

### 🎨 **FRONTEND (Reorganização)**
**Esta documentação foca no FRONTEND:**
- Reorganizar componentes V5 → V0 (estrutura modular)
- Limpar dependências de V1/shared
- **MANTER interface visual IGUAL** (zero quebra para usuário)
- **MANTER todas as funcionalidades** (chat, skills, multimodal)
- Não mexer em backend nessa etapa

### 🔧 **BACKEND (DO ZERO TOTAL)**
**Backend é trabalho separado, em paralelo:**
- ❌ Remover backend antigo completamente
- ✅ Criar banco de dados do zero (schema em `/projeto-docs-new/tabelas/`)
- ✅ Criar migrations novas (validação campo por campo - **EM ANDAMENTO**)
- ✅ Criar todas as API routes novas (`app/api/v0/*`)
- ✅ Criar todas as queries novas (`lib/db/queries.ts`)
- ✅ Validar TUDO contra `Definicoes_banco_de_dados.txt`

### 🎯 **RESULTADO ESPERADO**
- Interface IGUAL (zero mudanças visuais)
- Funcionalidades IGUAIS (zero quebras)
- Arquitetura LIMPA (front organizado + back moderno)

---

## 📂 Estrutura dos Arquivos

```
/definicoes/
├── 00-LEIA-PRIMEIRO.md                    # Este arquivo
├── README.md                              # Visão geral e conceitos
├── Definicoes_banco_de_dados.txt          # Schema e modelagem
├── Definicoes_estrutura_codigo_atual.txt  # Como está (REAL)
├── Definicoes_estrutura_codigo.txt        # Como deve ser (IDEAL)
└── COMPARACAO-ATUAL-VS-IDEAL.md           # Análise e roadmap
```

---

## 🚨 Problema Crítico Identificado

**V5 importa componentes de V1/shared:**

```typescript
// ❌ ATUAL (errado) - PROIBIDO NO CHAT V0
import { AnimatedHeader } from "../../v1/shared/animated-header";
import { LoaderIcon } from "../../v1/shared/icons";
import { ContextMultiSelector } from "../../v1/shared/context-multi-selector";
import { MCPMultiSelector } from "../../v1/shared/mcp-multi-selector";
import { PreviewAttachment } from "../../v1/shared/preview-attachment";
import { ArrowUpIcon, PaperclipIcon, StopIcon } from "../../v1/shared/icons";

// ✅ IDEAL (correto) - PADRÃO CHAT V0
import { AnimatedHeader } from "@/components/chat/headers/animated-header";
import { Loader2 } from "lucide-react"; // ✅ Lucide direto
import { ContextSelector } from "@/components/chat/context/context-selector";
import { MCPSelector } from "@/components/chat/context/mcp-selector";
import { AttachmentPreview } from "@/components/chat/multimodal/attachment-preview";
import { ArrowUp, Paperclip, StopCircle } from "lucide-react"; // ✅ Lucide
```

**5 arquivos afetados que precisam migração:**
- `multimodal-input-v5.tsx` → `components/chat/multimodal/multimodal-input.tsx`
- `chat-v5-foundations.tsx` → `components/chat/core/chat-container.tsx`
- `chat-header-v5.tsx` → `components/chat/headers/chat-header.tsx`
- `chat-container-v1-layout.tsx` → REMOVER (obsoleto)
- `workflow-execution-layout.tsx` → `components/workflows/workflow-layout.tsx`

**✅ SOLUÇÃO COMPLETA:**
Documento **`Definicoes_estrutura_codigo.txt`** (IDEAL) contém:
- ✅ Estrutura completa de pastas
- ✅ Templates de componentes prontos para usar
- ✅ Exemplos de código completos (ChatContainer, ChatInput, ChatHeader)
- ✅ Checklist de compliance detalhado
- ✅ Guia de migração passo a passo (6 fases)

---

## 📊 Migração em 5 Fases

### **Fase 1: Preparação**
- Backup completo
- Documentar dependências
- Mapear componentes
- Criar estrutura de pastas

### **Fase 2: Migração de Componentes**
- Criar `/components/chat/` modular
- Migrar de V1/shared → estrutura modular
- Migrar de V5/chat → /components/chat/
- Atualizar imports
- Testar cada componente

### **Fase 3: Limpeza**
- Remover v1, v2, experimental
- Consolidar flow → workflows
- Consolidar generative-ui → chat
- Organizar arquivos soltos

### **Fase 4: Backend**
- Reconstruir schema.ts
- Criar migrations limpas
- Reescrever queries.ts
- Implementar RLS completo

### **Fase 5: Testes e Validação**
- Atualizar testes
- Validar BDD
- Testar staging
- Documentar APIs

---

## 🎓 Conceitos-Chave

### **Sistema de Versões:**
- **V0**: Não existe hoje, será criada a partir de V5
- **V1**: Sistema legado com /shared, será removida
- **V5**: Sistema novo com AI SDK 5.0, base da nova V0

### **Componentes Shared:**
- **Atual**: V1 tem `/shared` com 18 componentes
- **Problema**: V5 importa de V1/shared (acoplamento)
- **Ideal**: Cada sistema organizado em pastas modulares

### **Estrutura de Chat Ideal:**
```
/components/chat/
├── /core/           # Funcionalidades essenciais
├── /ai-elements/    # Integrações AI SDK
├── /headers/        # Navegação e headers
├── /skills/         # Sistema de skills
├── /multimodal/     # Input multimodal
├── /context/        # Gerenciamento de contexto
├── /ui/             # Componentes UI
└── /utils/          # Utilitários
```

---

## 🔗 Links Úteis

### Documentação Interna:
- `/projeto-bdd/` - Features BDD para testes
- `/projeto-sdk5/` - Documentação AI SDK 5.0
- `/projeto-docs-new/tabelas/` - Análises de tabelas do banco
- `/projeto-docs-new/diagramas/` - Diagramas de arquitetura

### Documentação Externa:
- [AI SDK 5.0 Docs](https://sdk.vercel.ai/docs)
- [Next.js 15 Docs](https://nextjs.org/docs)
- [Drizzle ORM](https://orm.drizzle.team/)
- [shadcn/ui](https://ui.shadcn.com/)

---

## ❓ FAQ Rápido

**Q: Qual estrutura devo seguir no código novo?**
A: `Definicoes_estrutura_codigo.txt` (IDEAL) tem toda a estrutura Chat V0 + `COMPARACAO-ATUAL-VS-IDEAL.md` (plano de migração)

**Q: Como implementar Chat V0 limpo?**
A: **`Definicoes_estrutura_codigo.txt`** (IDEAL) tem template de componente Chat V0 e checklist pré-commit completo.

**Q: Como está organizado o código atual?**
A: `Definicoes_estrutura_codigo_atual.txt` (REAL)

**Q: Onde vejo os problemas e o plano de migração?**
A: `COMPARACAO-ATUAL-VS-IDEAL.md`

**Q: Como funciona o banco de dados?**
A: `Definicoes_banco_de_dados.txt`

**Q: Quais são os conceitos principais do sistema?**
A: `README.md` (Hierarquia, Roles, Conhecimento, Permissões)

**Q: Posso importar de /components/v1/shared no código novo?**
A: ❌ **NÃO! PROIBIDO!** Isso é um problema crítico. Use Lucide React e componentes em `/components/chat/`.

**Q: Onde colocar novos componentes de chat?**
A: **`/components/chat/`** com estrutura modular (core, ai-elements, headers, skills, multimodal, context, ui, utils).

**Q: V0 existe?**
A: Não hoje. Será criada a partir de V5. Veja `COMPARACAO-ATUAL-VS-IDEAL.md` para o plano completo (6 fases).

**Q: Quais ícones usar?**
A: **Lucide React** (`import { Send, Menu } from 'lucide-react'`). NUNCA usar `v1/shared/icons.tsx`.

**Q: Como fazer input multimodal sem deps V1?**
A: Veja template de componente em `Definicoes_estrutura_codigo.txt` seção "TEMPLATE DE COMPONENTE CHAT V0".

**Q: ⚠️ Como validar backend com banco de dados?**
A: **SEMPRE** validar contra `Definicoes_banco_de_dados.txt` antes de criar/modificar qualquer backend (API routes, Server Actions, queries). Verificar: tabelas existem? colunas corretas? FKs corretas? RLS configurado? Tipos TypeScript com InferSelectModel?

---

## 📞 Contato

Para dúvidas sobre:
- **Arquitetura**: Revise `COMPARACAO-ATUAL-VS-IDEAL.md`
- **Banco de Dados**: Revise `Definicoes_banco_de_dados.txt`
- **Código Atual**: Revise `Definicoes_estrutura_codigo_atual.txt`
- **Código Ideal**: Revise `Definicoes_estrutura_codigo.txt`

---

**Última atualização:** 10/10/2025
**Versão da Documentação:** 2.0
**Status:** 🚧 Em Planejamento de Migração

