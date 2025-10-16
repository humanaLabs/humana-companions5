# 🗄️ Documentação de Tabelas

Esta pasta contém a documentação detalhada de todas as tabelas do banco de dados PostgreSQL do sistema Humana AI Companions.

## 📋 Índice de Tabelas

### 📄 Artefatos e Conteúdo
- **ANALISE-TABELA-ARTIFACTS.md** - Tabela de artefatos gerados (documentos, código, planilhas)
- **ANALISE-TABELA-CHATS-V5.md** - Tabela de conversas (versão 5 com AI SDK)

### 🤖 Companions e Skills
- **ANALISE-TABELA-SKILLS.md** - Skills dos companions (sub-agentes especializados)
- **ANALISE-TABELA-STEPS.md** - Steps das skills (fases de execução)
- **ANALISE-TABELA-EXECUTIONS.md** - Execuções de workflows agenticos

### 🧠 Conhecimento e RAG
- **ANALISE-TABELA-KNOWLEDGE-RAG.md** - Sistema de conhecimento com pgvector
  - VectorEmbedding (1536 dimensões)
  - CompanionKnowledge
  - UserMemory
  - ConversationMemory

### 🔐 Permissões e Ferramentas
- **ANALISE-TABELA-PERMISSIONS-ACL.md** - Sistema de permissões e ACL
- **ANALISE-TABELA-TOOLS-MCP.md** - Ferramentas MCP (Model Context Protocol)

### 🏢 Estrutura Organizacional
- **ANALISE-TABELA-WORKSPACES.md** - Workspaces (ambientes de trabalho)

### 📊 Especificações de Campos
- **ATRIBUTOS-JSONB-TABELAS.md** - Documentação completa dos campos JSONB

## 🔑 Tabelas Principais com pgvector

### VectorEmbedding
- **Uso**: Embeddings para RAG principal
- **Dimensões**: 1536 (OpenAI text-embedding-3-small)
- **Índice**: IVFFLAT com cosine similarity

### CompanionKnowledge
- **Uso**: Conhecimento específico dos companions
- **Dimensões**: 1536
- **Índice**: HNSW com L2 distance

### UserMemory
- **Uso**: Memórias e preferências dos usuários
- **Dimensões**: 1536
- **Índice**: HNSW com L2 distance

### ConversationMemory
- **Uso**: Resumos de conversas importantes
- **Dimensões**: 1536
- **Índice**: HNSW com L2 distance

## 📐 Convenções de Nomenclatura

- **Tabelas**: PascalCase (ex: `VectorEmbedding`)
- **Campos**: camelCase (ex: `contextSourceId`)
- **Foreign Keys**: `{tabela}_{campo}_fk`
- **Índices**: `{tabela}_{campo(s)}_{tipo}idx`

## 🔗 Relacionamentos Principais

```
Organization
  └── Workspace
      ├── User → Chat → Artifact
      └── Companion → Skill → Step
                        └── Execution
```

## 💾 Tecnologias

- **PostgreSQL**: Banco de dados principal
- **pgvector**: Extensão para busca semântica
- **Drizzle ORM**: ORM para TypeScript
- **RLS**: Row Level Security para controle de acesso

## 📖 Como Usar

1. Consulte o arquivo específico da tabela que deseja entender
2. Veja `ATRIBUTOS-JSONB-TABELAS.md` para detalhes dos campos JSONB
3. Use os diagramas em `/diagramas` para visualizar relacionamentos
