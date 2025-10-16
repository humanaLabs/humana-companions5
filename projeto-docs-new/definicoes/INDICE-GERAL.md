# 📚 ÍNDICE GERAL - DOCUMENTAÇÃO HUMANA AI COMPANIONS
**Guia Completo de Navegação**

---

## ⚠️ IMPORTANTE: SEPARAÇÃO FRONTEND E BACKEND

**📖 Esta documentação foca em FRONTEND (reorganização)**
- Componentes V5 → V0 (estrutura modular)
- Interface visual MANTIDA (zero quebra)
- Não mexe em backend

**🔧 Backend é reconstruído DO ZERO (trabalho paralelo)**
- Schema sendo criado em `/projeto-docs-new/tabelas/`
- Validação campo por campo em andamento
- APIs novas serão criadas depois

---

## 🚀 INÍCIO RÁPIDO

### **Para Novos Desenvolvedores:**
1. 📖 **[00-LEIA-PRIMEIRO.md](00-LEIA-PRIMEIRO.md)** - Comece aqui!
2. 📖 **[README.md](README.md)** - Conceitos do sistema
3. 📝 **[Definicoes_estrutura_codigo.txt](Definicoes_estrutura_codigo.txt)** - Estrutura IDEAL (templates e regras)

### **Para Implementar Chat V0 Agora:**
1. 📝 **[Definicoes_estrutura_codigo.txt](Definicoes_estrutura_codigo.txt)** ⭐ - Estrutura, templates e checklist
2. 📊 **[COMPARACAO-ATUAL-VS-IDEAL.md](COMPARACAO-ATUAL-VS-IDEAL.md)** - Plano de 6 fases
3. 🗄️ **[Definicoes_banco_de_dados.txt](Definicoes_banco_de_dados.txt)** - Schema do banco

### **Para Entender o Sistema Atual:**
1. 📝 **[Definicoes_estrutura_codigo_atual.txt](Definicoes_estrutura_codigo_atual.txt)** - Como está HOJE
2. 📊 **[COMPARACAO-ATUAL-VS-IDEAL.md](COMPARACAO-ATUAL-VS-IDEAL.md)** - Análise de problemas
3. 📖 **[README.md](README.md)** - Hierarquia e conceitos

---

## 📂 TODOS OS DOCUMENTOS

| # | Documento | Propósito | Tamanho |
|---|-----------|-----------|---------|
| 1 | **[00-LEIA-PRIMEIRO.md](00-LEIA-PRIMEIRO.md)** | Guia de navegação inicial - FAQ básico | 8 KB |
| 2 | **[INDICE-GERAL.md](INDICE-GERAL.md)** | Índice completo com fluxos de trabalho | 12 KB |
| 3 | **[COMPARACAO-ATUAL-VS-IDEAL.md](COMPARACAO-ATUAL-VS-IDEAL.md)** | Análise de problemas + Plano de 6 fases | 11 KB |
| 4 | **[Definicoes_banco_de_dados.txt](Definicoes_banco_de_dados.txt)** | Schema, RLS, ACL, pgvector | 7 KB |
| 5 | **[Definicoes_estrutura_codigo_atual.txt](Definicoes_estrutura_codigo_atual.txt)** | Estrutura REAL (hoje) | 12 KB |
| 6 | **[Definicoes_estrutura_codigo.txt](Definicoes_estrutura_codigo.txt)** ⭐ | Estrutura IDEAL + Templates + Regras | 23 KB |
| 7 | **[README.md](README.md)** | Conceitos e hierarquia do sistema | 6 KB |

---

## 🎯 QUANDO USAR CADA DOCUMENTO

| Se você precisa... | Use este documento |
|--------------------|-------------------|
| **Começar do zero** | 00-LEIA-PRIMEIRO.md |
| **Implementar Chat V0** | Definicoes_estrutura_codigo.txt (IDEAL) |
| **Entender problemas atuais** | COMPARACAO-ATUAL-VS-IDEAL.md |
| **Seguir plano de migração** | COMPARACAO-ATUAL-VS-IDEAL.md (6 fases) |
| **Trabalhar com banco** | Definicoes_banco_de_dados.txt |
| **Fazer manutenção código atual** | Definicoes_estrutura_codigo_atual.txt |
| **Entender conceitos** | README.md |
| **Template de componente** | Definicoes_estrutura_codigo.txt → "TEMPLATE DE COMPONENTE CHAT V0" |
| **Checklist pré-commit** | Definicoes_estrutura_codigo.txt → "CHECKLIST PRÉ-COMMIT GERAL" |
| **Regras críticas Chat V0** | Definicoes_estrutura_codigo.txt → "REGRAS CRÍTICAS CHAT V0" |
| **Boas práticas** | COMPARACAO-ATUAL-VS-IDEAL.md → "BOAS PRÁTICAS - CHAT V0" |

---

## 📋 ESTRUTURA DA DOCUMENTAÇÃO

```
projeto-docs-new/
├── definicoes/                    # Esta pasta
│   ├── 00-LEIA-PRIMEIRO.md        # ← Comece aqui
│   ├── INDICE-GERAL.md            # ← Você está aqui
│   ├── COMPARACAO-ATUAL-VS-IDEAL.md
│   ├── Definicoes_banco_de_dados.txt
│   ├── Definicoes_estrutura_codigo_atual.txt
│   ├── Definicoes_estrutura_codigo.txt  # ⭐ Principal
│   └── README.md
│
├── diagramas/                     # Diagramas visuais
├── tabelas/                       # Análises de tabelas
└── fluxos/                        # Fluxos de processo
```

---

## ❓ FAQ RÁPIDO

**Q: Qual arquivo é mais importante?**
A: **`Definicoes_estrutura_codigo.txt`** (IDEAL) - tem tudo que você precisa para implementar.

**Q: Por onde começar?**
A: 00-LEIA-PRIMEIRO.md → README.md → Definicoes_estrutura_codigo.txt (IDEAL)

**Q: Onde está o plano de migração?**
A: COMPARACAO-ATUAL-VS-IDEAL.md → Seção "PRÓXIMOS PASSOS" (6 fases)

**Q: Onde estão os templates de código?**
A: Definicoes_estrutura_codigo.txt → Seção "TEMPLATE DE COMPONENTE CHAT V0"

**Q: Como sei se meu código está correto?**
A: Use o checklist em Definicoes_estrutura_codigo.txt → "CHECKLIST PRÉ-COMMIT GERAL"

**Q: Qual a diferença entre ATUAL e IDEAL?**
A: ATUAL = como está hoje (problemático) | IDEAL = como deve ser (alvo da migração)

**Q: V0 existe?**
A: Não ainda. V0 é a versão limpa que será criada a partir de V5. Plano em COMPARACAO-ATUAL-VS-IDEAL.md.

**Q: O que manter do V5?**
A: **MultimodalInputV5** (input) e **ChatHeaderV5** (header). Todo o resto usa AI SDK 5.0 nativo.

**Q: ⚠️ Como validar backend com banco de dados?**
A: **CRÍTICO:** SEMPRE validar contra `Definicoes_banco_de_dados.txt` antes de criar/modificar backend. Verificar tabelas, colunas, FKs, RLS e tipos TypeScript.

---

## 🗺️ FLUXO DE LEITURA POR CENÁRIO

### **Cenário 1: Novo Desenvolvedor**
1. 00-LEIA-PRIMEIRO.md (5 min)
2. README.md (10 min)
3. COMPARACAO-ATUAL-VS-IDEAL.md (15 min)
4. Definicoes_estrutura_codigo.txt (30 min)

**Total:** ~60 minutos

---

### **Cenário 2: Implementar Chat V0**
1. Definicoes_estrutura_codigo.txt → Ler seções Chat V0
2. COMPARACAO-ATUAL-VS-IDEAL.md → Ver plano de 6 fases
3. Começar pela Fase 1 (Setup)

**Total:** ~30 minutos de leitura + implementação

---

### **Cenário 3: Entender Problemas Atuais**
1. COMPARACAO-ATUAL-VS-IDEAL.md (problemas críticos)
2. Definicoes_estrutura_codigo_atual.txt (estrutura real)
3. Definicoes_estrutura_codigo.txt (como corrigir)

**Total:** ~45 minutos

---

### **Cenário 4: Trabalhar com Banco de Dados**
1. Definicoes_banco_de_dados.txt (schema)
2. ../tabelas/ (detalhes de tabelas específicas)
3. README.md (conceitos de hierarquia)

**Total:** ~30 minutos

---

## 📝 HISTÓRICO DE ATUALIZAÇÕES

| Data | Arquivo | Mudança |
|------|---------|---------|
| 12/10/2025 | Todos | Adicionadas regras "O que manter" (MultimodalInputV5, ChatHeaderV5) |
| 12/10/2025 | COMPARACAO, INDICE | Removidos blocos de código (só texto descritivo) |
| 10/10/2025 | Todos | Criação da documentação consolidada |

---

**Última atualização:** 12/10/2025
**Versão:** 2.0
**Status:** ✅ Atualizado e Limpo

**Responda sempre em português.**
