# 🎨 ANÁLISE DETALHADA - TABELA ARTIFACTS

**Documento**: Análise de estrutura da tabela ARTIFACTS para refatoração do backend  
**Versão**: 2.0  
**Data**: 2025-01-15  
**Objetivo**: Definir estrutura otimizada para artefatos com AI SDK 5.0 e formato padronizado

---

## 🎯 TABELA ARTIFACTS - ANÁLISE COMPLETA

### 📋 **COLUNAS HEADER (Diretas) - ESTRUTURA FINAL**

| Campo | Tipo | Constraints | Justificativa Detalhada |
|-------|------|-------------|-------------------------|
| `artf_id` | UUID | PRIMARY KEY | **Identificador único global** - Usado em todas as operações CRUD, relacionamentos, RLS policies e URLs da aplicação. UUID garante unicidade distribuída e segurança. |
| `chat_id` | UUID | NULLABLE, FK → chats(chat_id) | **Origem do artefato** - NULL se for workspace, UUID se for de chat. Usado para rastreabilidade e contexto. Essencial para funcionalidade core. |
| `workspace_id` | UUID | NOT NULL, FK → workspaces(wksp_id) | **Multi-tenancy** - Define o workspace do artefato. Usado para isolamento de dados e RLS. Essencial para funcionalidade core. |
| `artf_name` | VARCHAR(255) | NOT NULL | **Identificação** - Nome do artefato exibido na UI. Usado para busca textual, ordenação alfabética e identificação visual. |
| `artf_content` | BYTEA | NOT NULL | **Conteúdo BLOB** - Conteúdo binário do artefato (documentos, imagens, arquivos). BYTEA permite armazenamento de dados binários. |
| `artf_format` | VARCHAR(10) | NOT NULL | **Formato do arquivo** - Extensão/tipo do arquivo (MD, SVG, PDF, HTML, JSON, PNG, DOCX, etc). Usado para renderização e validação. |
| `artf_status` | ENUM | NOT NULL DEFAULT 'ACT' | **Estado do artefato** - `ACT` (active), `ARC` (archived), `DEL` (deleted). Usado para filtragem rápida na UI e lógica de negócio. Padrão de 3 letras. |
| `artf_created_at` | TIMESTAMP | NOT NULL DEFAULT NOW() | **Auditoria temporal** - Data de criação do artefato. Usado para ordenação cronológica, analytics e auditoria. |
| `artf_updated_at` | TIMESTAMP | NOT NULL DEFAULT NOW() | **Última modificação** - Data da última atualização. Usado para ordenação por atividade, versionamento e analytics. |

### 🔧 **ENUMs**
```sql
CREATE TYPE status_artifact_enum AS ENUM ('ACT', 'ARC', 'DEL');
```

### 📝 **OBSERVAÇÕES IMPORTANTES**

1. **Conteúdo BLOB**: O conteúdo do artefato é armazenado diretamente na coluna `content` como BYTEA (PostgreSQL) para performance e simplicidade.

2. **Formato**: A coluna `format` identifica o tipo de arquivo, permitindo renderização adequada na UI.

3. **Metadados**: Metadados adicionais (como thumbnails, previews, versões) podem ser armazenados em tabelas auxiliares se necessário.

4. **Status Enum**: Padronizado com 3 letras: `ACT`, `ARC`, `DEL`.

### 📊 **ÍNDICES RECOMENDADOS**

```sql
-- Índices básicos
CREATE INDEX idx_artifacts_chat ON artifacts(chat_id);
CREATE INDEX idx_artifacts_workspace ON artifacts(workspace_id);
CREATE INDEX idx_artifacts_status ON artifacts(artf_status);
CREATE INDEX idx_artifacts_format ON artifacts(artf_format);
CREATE INDEX idx_artifacts_created ON artifacts(artf_created_at DESC);
CREATE INDEX idx_artifacts_updated ON artifacts(artf_updated_at DESC);

-- Índices compostos para consultas frequentes
CREATE INDEX idx_artifacts_workspace_status ON artifacts(workspace_id, artf_status);
CREATE INDEX idx_artifacts_chat_status ON artifacts(chat_id, artf_status) WHERE chat_id IS NOT NULL;
CREATE INDEX idx_artifacts_format_status ON artifacts(artf_format, artf_status);

-- Índice para busca full-text no nome
CREATE INDEX idx_artifacts_name_fts ON artifacts USING GIN (to_tsvector('portuguese', artf_name));
```

---

## 🎯 **ESTRUTURA SQL COMPLETA**

```sql
CREATE TABLE artifacts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  chat_id UUID REFERENCES chats(id),
  workspace_id UUID NOT NULL REFERENCES workspaces(id),
  name VARCHAR(255) NOT NULL,
  content BYTEA NOT NULL,
  format VARCHAR(10) NOT NULL,
  status status_artifact_enum NOT NULL DEFAULT 'ACT',
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- ENUMs
CREATE TYPE status_artifact_enum AS ENUM ('ACT', 'ARC', 'DEL');
```

---

## 🎯 **RESUMO EXECUTIVO - TABELA ARTIFACTS**

### **COLUNAS (9 campos):**
- **Identificadores**: `id`, `chat_id`, `workspace_id`
- **Identificação**: `name`, `format`, `status`
- **Conteúdo**: `content` (BYTEA/BLOB)
- **Temporais**: `created_at`, `updated_at`

### **BENEFÍCIOS DESTA ESTRUTURA**

1. **Simplicidade**: Estrutura direta sem JSONB complexo
2. **Performance**: BLOB nativo do PostgreSQL para conteúdo binário
3. **Escalabilidade**: Índices otimizados para crescimento
4. **Compatibilidade**: Suporta todos os tipos de arquivos
5. **Manutenibilidade**: Estrutura clara e fácil de entender

### **CASOS DE USO PRINCIPAIS**

1. **Armazenamento de Arquivos**: Documentos, imagens, PDFs, etc
2. **Artefatos de Chat**: Conteúdo gerado por IA
3. **Documentos de Workspace**: Arquivos compartilhados
4. **Multi-formato**: Suporte a MD, SVG, PDF, HTML, JSON, DOCX, PNG, etc
5. **Rastreabilidade**: Origem por chat ou workspace

---

**Documento gerado em**: 2025-01-15  
**Versão**: 2.0  
**Status**: ✅ Pronto para implementação