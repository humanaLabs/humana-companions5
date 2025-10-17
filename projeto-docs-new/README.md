# 📚 Documentação Completa - Humana AI Companions

## 📋 Estrutura da Documentação

Esta pasta contém toda a documentação técnica do projeto Humana AI Companions, organizada de forma lógica e acessível.

---

## 📁 Estrutura de Pastas

### 📖 `/definicoes`
**Regras de negócio, especificações gerais e conceitos do sistema**

**Arquivos:**
- `Definicoes_Edu.txt` - ⭐ **PRINCIPAL** - Definições gerais, modelagem, roles, sistema de conhecimento
- `Definicoes_banco_de_dados.txt` - Especificações técnicas do PostgreSQL
- `Definicoes_estrutura_codigo.txt` - Estrutura e organização do código

**Use quando precisar entender:**
- Como o sistema funciona (regras de negócio)
- Hierarquia de organizações, workspaces e usuários
- Sistema de roles e permissões (GUC → RLS → ACL → RAG)
- Como funciona o conhecimento RAG
- Exemplos de schemas JSONB

---

### 🗄️ `/tabelas`
**Documentação completa do banco de dados PostgreSQL**

**Categorias de documentos:**

#### 📊 Análises de Tabelas (foco em USO)
- `ANALISE-TABELA-*.md` - Como os dados são usados na UI e funcionalidades
- `ATRIBUTOS-JSONB-TABELAS.md` - Especificação dos campos JSONB

#### 🔧 Modelos Técnicos (foco em ESTRUTURA)
- `MODELO-TECNICO-*.md` - Estrutura do banco, relacionamentos, índices

**Tabelas documentadas:**
- Artifacts, Chats V5, Executions
- Knowledge RAG (pgvector)
- Permissions ACL
- Skills, Steps
- Tools MCP
- Workspaces
- Companions, Organizations, Users

---

### 🎨 `/diagramas`
**Representações visuais da arquitetura e estrutura**

**Arquivos principais:**
- `diagrama-arquitetura-hd.svg` - ⭐ **Diagrama principal** em alta definição
- `DIAGRAMA-ARQUITETURA-HUMANA.svg` + `.md` - Documentação completa
- `complete-model.svg` - Modelo completo do sistema
- `NOVO-MODELO-DADOS-HUMANA.svg` - Novo modelo de dados
- `*-optimized.svg` - Diagramas otimizados por entidade

**Rascunhos originais:**
- `Rabisco_edu.jpeg` - Rascunho original
- `Rabisco_atualizado.png` - Versão atualizada

---

### 🗺️ `/mapeamentos`
**Mapeamento de relacionamentos entre entidades**

**Arquivos:**
- `MAPEAMENTO-DADOS-COMPANIONS.md` - Estrutura e relacionamentos dos companions
- `MAPEAMENTO-DADOS-ORGANIZATION.md` - Estrutura organizacional
- `MAPEAMENTO-DADOS-USER.md` - Estrutura de usuários

**Use quando precisar entender:**
- Como as entidades se relacionam
- Fluxo de dados entre tabelas
- Dependências e hierarquias

---

### 📏 `/convencoes`
**Padrões de nomenclatura e código**

**Arquivos:**
- `CONVENCAO-NOMENCLATURA.md` - Padrões para tabelas, campos, código

**Convenções principais:**
- Tabelas: PascalCase
- Campos: camelCase
- Enums: UPPER_SNAKE_CASE
- TypeScript patterns

---

### 📄 Arquivos na Raiz

#### MUDANCAS-MODELAGEM-V2.md
Documentação das mudanças da versão 2 da modelagem

#### NOVO-MODELO-DADOS-HUMANA-DOCUMENTACAO.md
Documentação completa do novo modelo de dados

---

## 🎯 Guia de Uso Rápido

### 🆕 Para Novos Desenvolvedores
1. Comece com `definicoes/Definicoes_Edu.txt` (visão geral)
2. Veja `diagramas/diagrama-arquitetura-hd.svg` (arquitetura visual)
3. Consulte `tabelas/` para entender o banco de dados
4. Use `mapeamentos/` para ver relacionamentos

### 👨‍💻 Para Desenvolvimento
1. **Criar nova feature?** → `definicoes/` (regras de negócio)
2. **Trabalhar com banco?** → `tabelas/` (estrutura e uso)
3. **Entender fluxo?** → `diagramas/` (visualização)
4. **Nomenclatura?** → `convencoes/` (padrões)

### 🗄️ Para DBAs
1. **Estrutura?** → `tabelas/MODELO-TECNICO-*.md`
2. **Uso dos dados?** → `tabelas/ANALISE-TABELA-*.md`
3. **Campos JSONB?** → `tabelas/ATRIBUTOS-JSONB-TABELAS.md`
4. **Relacionamentos?** → `mapeamentos/`

### 🏗️ Para Arquitetos
1. **Visão geral?** → `diagramas/diagrama-arquitetura-hd.svg`
2. **Evolução?** → `MUDANCAS-MODELAGEM-V2.md`
3. **Novo modelo?** → `NOVO-MODELO-DADOS-HUMANA-DOCUMENTACAO.md`
4. **Regras?** → `definicoes/Definicoes_Edu.txt`

---

## 🔑 Conceitos Principais

### Hierarquia do Sistema
```
Organizações
  └── Workspaces (MyWorkspace + OrgWorkspace)
      ├── Usuários → Chats → Artefatos
      └── Companions → Skills → Steps → Executions
```

### Sistema de Roles
- **MasterSys** (MS): Cria organizações
- **OrgAdmin** (OA): Cria workspaces
- **WspManager** (WM): Cria companions
- **User** (UR): Usa companions

### Fluxo de Permissões
```
GUC → RLS → ACL → RAG
(Global User Context → Row Level Security → Access Control List → RAG)
```

### Tabelas com pgvector (1536 dimensões)
- `VectorEmbedding` - RAG principal (IVFFLAT)
- `CompanionKnowledge` - Conhecimento companions (HNSW)
- `UserMemory` - Memórias usuários (HNSW)
- `ConversationMemory` - Memórias conversas (HNSW)

### Enums Principais
- **ROLES**: MS, OA, WM, UR
- **RESOURCES**: ORG, WSP, CMP, PRL, CHT, KNW, TOL
- **ACTIONS**: REA, WRI, UPD, MNG
- **CLASS**: PUB, ORG, WSP, PVT
- **RESTRICTS**: PII, FIN, COF

---

## 📊 Tecnologias

- **PostgreSQL** com extensão **pgvector**
- **Drizzle ORM** (TypeScript)
- **Next.js 15** + **AI SDK 5.0**
- **Row Level Security** (RLS)
- **JSONB** para flexibilidade

---

## 🔄 Mantendo Atualizado

Esta documentação é mantida atualizada conforme o sistema evolui.

**Última atualização:** Outubro 2025
**Versão da modelagem:** 2.0

---

## ❓ FAQ

**Q: Qual a diferença entre ANALISE-TABELA e MODELO-TECNICO?**
A: ANALISE foca em COMO os dados são usados (UI, funcionalidades). MODELO foca na ESTRUTURA (schema, índices, relacionamentos).

**Q: Por que JSONB ao invés de colunas?**
A: Flexibilidade para evoluir sem migrations, melhor para dados variáveis/opcionais.

**Q: Como funciona o RAG?**
A: AutoRAG indexa automaticamente no `VectorEmbedding` com pgvector (1536 dim), busca semântica com cosine similarity.

**Q: O que é GUC → RLS → ACL → RAG?**
A: Fluxo de segurança - contexto global → row security → access control → busca RAG filtrada.

---

**📧 Para dúvidas, consulte a equipe de desenvolvimento.**