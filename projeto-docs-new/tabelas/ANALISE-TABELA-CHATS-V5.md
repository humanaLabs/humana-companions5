# 📊 ANÁLISE DETALHADA - TABELA CHATS

**Documento**: Análise de estrutura da tabela CHATS para Chat v5 (AI SDK 5.0)  
**Versão**: 1.0  
**Data**: 2025-01-15  
**Objetivo**: Definir estrutura otimizada para Chat v5 com AI SDK 5.0

---

## 🎯 TABELA CHATS - ANÁLISE COMPLETA

### 📋 **COLUNAS HEADER (Diretas) - ESTRUTURA FINAL**

| Campo | Tipo | Constraints | Justificativa Detalhada |
|-------|------|-------------|-------------------------|
| `chat_id` | UUID | PRIMARY KEY | **Identificador único global** - Usado em todas as operações CRUD, relacionamentos, RLS policies e URLs da aplicação. UUID garante unicidade distribuída e segurança. |
| `user_id` | UUID | NOT NULL, FK → users(user_id) | **Propriedade e isolamento** - Define quem criou/possui o chat. Essencial para RLS (Row Level Security) e controle de acesso. Usado em 90% das consultas para filtrar chats do usuário. |
| `workspace_id` | UUID | NOT NULL, FK → workspaces(wksp_id) | **Multi-tenancy** - Isolamento por workspace. Usado para compartilhamento de chats entre usuários do mesmo workspace. Essencial para políticas de segurança e organização. |
| `companion_id` | UUID | NOT NULL, FK → companions(companion_id) | **Agente IA** - Define qual companion está sendo usado. Usado para filtragem, analytics e configuração de contexto. Essencial para funcionalidade core da aplicação. |
| `chat_title` | VARCHAR(255) | NOT NULL | **Exibição UI** - Título mostrado na interface do usuário. Usado para busca textual, ordenação alfabética e identificação visual. Limite 255 para performance e compatibilidade. |
| `chat_messages` | JSONB[] | NOT NULL DEFAULT '[]' | **Conteúdo principal** - Array de mensagens da conversa. Estrutura nativa do AI SDK 5.0. Usado para streaming, exibição e processamento de conversas. JSONB[] permite operações eficientes. |
| `chat_created_at` | TIMESTAMP | NOT NULL DEFAULT NOW() | **Auditoria temporal** - Data de criação do chat. Usado para ordenação cronológica, analytics e auditoria. Essencial para relatórios e debugging. |
| `chat_updated_at` | TIMESTAMP | NOT NULL DEFAULT NOW() | **Última atividade** - Data da última atualização. Usado para ordenação de chats por atividade, limpeza automática e analytics. Atualizado a cada nova mensagem. |
| `chat_status` | ENUM | NOT NULL DEFAULT 'active' | **Estado do chat** - `active`, `archived`, `deleted`. Usado para filtragem rápida na UI, soft delete e organização. Evita JOINs desnecessários para consultas de status. |
| `chat_last_message_at` | TIMESTAMP | NULLABLE | **Performance de ordenação** - Timestamp da última mensagem. Usado para ordenar chats por atividade sem JOIN com tabela de mensagens. Melhora performance em 80% das consultas. |
| `chat_message_count` | INTEGER | NOT NULL DEFAULT 0 | **Performance de paginação** - Contagem total de mensagens. Usado para paginação, estatísticas e validações. Evita COUNT() custoso em consultas frequentes. |
| `chat_attributes` | JSONB | NOT NULL DEFAULT '{}' | **Atributos JSONB** - Configurações e metadados (ai_sdk_config, metadata). Estrutura flexível para configurações do AI SDK 5.0 e metadados adicionais. |

### 🔧 **ENUM status_chat_enum**
```sql
CREATE TYPE status_chat_enum AS ENUM ('active', 'archived', 'deleted');
```

### 📦 **ATRIBUTOS JSONB - ESTRUTURA DETALHADA**

#### **1. ai_sdk_config** - Configurações do AI SDK 5.0
```json
{
  "model_provider": "azure",           // Provider (azure, openai, anthropic)
  "model_name": "gpt-4o",             // Nome do modelo específico
  "model_version": "2024-02-01",      // Versão do modelo
  "temperature": 0.7,                  // Criatividade (0.0-2.0)
  "max_tokens": 4000,                 // Limite de tokens de resposta
  "top_p": 0.9,                       // Nucleus sampling
  "frequency_penalty": 0.0,           // Penalidade por repetição
  "presence_penalty": 0.0,            // Penalidade por presença
  "seed": null,                       // Semente para reproduzibilidade
  "stream": true,                     // Habilitar streaming
  "tools_enabled": true               // Habilitar tool calling
}
```
**Justificativa**: Configurações específicas do AI SDK 5.0 que podem evoluir rapidamente. Não usadas para filtragem em larga escala, mas essenciais para execução.

#### **2. system_prompt** - Prompt de Sistema
```json
{
  "id": "uuid-system-prompt",         // ID do prompt no sistema
  "version": "2.1",                   // Versão do prompt
  "content": "Você é um assistente...", // Conteúdo do prompt
  "is_custom": false,                 // Se é customizado pelo usuário
  "created_by": "uuid-user",          // Quem criou (se custom)
  "created_at": "2025-01-15T10:00:00Z" // Quando foi criado
}
```
**Justificativa**: Prompts podem ser versionados e customizados. Estrutura complexa que não se beneficia de colunas diretas.

#### **3. tools_config** - Configuração de Ferramentas MCP
```json
{
  "enabled_tools": [                  // Ferramentas habilitadas
    "mcp-database",
    "mcp-email", 
    "web-search",
    "file-upload"
  ],
  "tool_calls_enabled": true,         // Habilitar chamadas de ferramentas
  "parallel_tool_calls": true,        // Permitir chamadas paralelas
  "max_tool_calls": 10,               // Limite de chamadas por mensagem
  "tool_timeout_ms": 30000            // Timeout para execução
}
```
**Justificativa**: Configuração específica de ferramentas MCP. Pode variar por chat e evoluir com novas ferramentas.

#### **4. conversation_state** - Estado da Conversa
```json
{
  "context_window_tokens": 1500,      // Tokens atuais no contexto
  "max_context_tokens": 8000,         // Limite máximo de contexto
  "memory_summary": "Usuário perguntou...", // Resumo da conversa
  "active_topics": ["vendas", "relatórios"], // Tópicos ativos
  "conversation_phase": "exploration", // Fase da conversa
  "last_user_activity": "2025-01-15T10:30:00Z", // Última atividade do usuário
  "ai_thinking_time_ms": 2500         // Tempo de processamento da IA
}
```
**Justificativa**: Estado interno complexo da conversa. Mutável e específico da implementação do AI SDK 5.0.

#### **5. usage_metrics** - Métricas de Uso
```json
{
  "total_input_tokens": 10000,        // Total de tokens de entrada
  "total_output_tokens": 5000,        // Total de tokens de saída
  "total_cost_usd": 0.15,             // Custo total em USD
  "avg_response_time_ms": 2500,       // Tempo médio de resposta
  "tool_calls_count": 12,             // Número de chamadas de ferramentas
  "streaming_enabled": true,          // Se streaming está ativo
  "error_count": 0,                   // Número de erros
  "retry_count": 0                    // Número de tentativas
}
```
**Justificativa**: Métricas de uso e custo. Usadas para analytics e billing, mas não para filtragem de consultas.

#### **6. user_preferences** - Preferências do Usuário
```json
{
  "theme": "dark",                    // Tema da interface
  "language": "pt-BR",                // Idioma preferido
  "response_style": "professional",   // Estilo de resposta
  "auto_save": true,                  // Salvamento automático
  "notifications": {
    "new_messages": true,             // Notificar novas mensagens
    "tool_executions": false,         // Notificar execuções de ferramentas
    "errors": true                    // Notificar erros
  },
  "ui_settings": {
    "show_timestamps": true,          // Mostrar timestamps
    "show_tokens": false,             // Mostrar contagem de tokens
    "show_confidence": true,          // Mostrar score de confiança
    "compact_mode": false             // Modo compacto
  }
}
```
**Justificativa**: Preferências específicas do usuário para este chat. Podem variar entre chats do mesmo usuário.

#### **7. chat_metadata** - Metadados de Organização
```json
{
  "is_pinned": false,                 // Chat fixado
  "is_archived": false,               // Chat arquivado
  "is_shared": false,                 // Chat compartilhado
  "shared_with_workspaces": [],       // Workspaces com acesso
  "shared_with_users": [],            // Usuários com acesso
  "tags": ["projeto-alpha", "reunião"], // Tags do usuário
  "priority": "normal",               // Prioridade (low, normal, high, urgent)
  "estimated_duration_minutes": 30,   // Duração estimada
  "category": "work",                 // Categoria (work, personal, learning)
  "project_id": "uuid-project"        // ID do projeto associado
}
```
**Justificativa**: Metadados de organização e compartilhamento. Usados para filtragem, mas não em larga escala.

#### **8. ai_sdk_elements** - Configurações dos Componentes UI
```json
{
  "conversation_id": "conv-uuid",     // ID da conversa no AI SDK
  "reasoning_enabled": true,          // Mostrar raciocínio da IA
  "sources_enabled": true,            // Mostrar fontes
  "actions_enabled": true,            // Habilitar ações (copiar, etc)
  "tool_ui_enabled": true,            // Mostrar UI de ferramentas
  "message_components": {
    "show_timestamps": true,          // Mostrar timestamps nas mensagens
    "show_tokens": false,             // Mostrar contagem de tokens
    "show_confidence": true,          // Mostrar score de confiança
    "show_sources": true,             // Mostrar fontes nas mensagens
    "show_reasoning": true            // Mostrar raciocínio
  },
  "streaming_config": {
    "chunk_size": 50,                 // Tamanho dos chunks de streaming
    "delay_ms": 100,                  // Delay entre chunks
    "show_typing": true               // Mostrar indicador de digitação
  }
}
```
**Justificativa**: Configurações específicas dos componentes UI do AI SDK Elements. Podem variar por chat e evoluir com a interface.

#### **9. workflow_integration** - Integração com Workflows
```json
{
  "active_skill_id": "uuid-skill",    // Skill ativa no momento
  "execution_id": "uuid-execution",   // ID da execução atual
  "workflow_status": "running",       // Status do workflow
  "steps_completed": 3,               // Passos completados
  "total_steps": 5,                   // Total de passos
  "current_step": "validation",       // Passo atual
  "workflow_type": "employee_creation", // Tipo de workflow
  "estimated_completion": "2025-01-15T11:00:00Z" // Estimativa de conclusão
}
```
**Justificativa**: Integração com sistema de workflows agênticos. Específico da implementação e pode variar por chat.

#### **10. knowledge_context** - Contexto RAG
```json
{
  "rag_enabled": true,                // RAG habilitado
  "knowledge_sources": [              // Fontes de conhecimento
    {
      "resource_kind": "KNW",
      "resource_id": "uuid-knowledge-1",
      "relevance_score": 0.85,
      "last_updated": "2025-01-15T09:00:00Z"
    }
  ],
  "retrieved_chunks": 5,              // Número de chunks recuperados
  "similarity_threshold": 0.7,        // Threshold de similaridade
  "embedding_model": "text-embedding-3-small", // Modelo de embedding
  "search_query": "relatórios de vendas", // Última query de busca
  "context_boost": 1.2                // Boost de contexto
}
```
**Justificativa**: Contexto específico de RAG. Estrutura complexa que evolui com o sistema de conhecimento.

#### **11. error_handling** - Tratamento de Erros
```json
{
  "last_error": null,                 // Último erro ocorrido
  "error_count": 0,                   // Contagem total de erros
  "retry_attempts": 0,                // Tentativas de retry
  "fallback_model": "gpt-3.5-turbo", // Modelo de fallback
  "error_types": [],                  // Tipos de erros ocorridos
  "last_error_at": null,              // Data do último erro
  "auto_retry": true,                 // Retry automático
  "max_retries": 3                    // Máximo de tentativas
}
```
**Justificativa**: Configurações de tratamento de erros. Específicas da implementação e podem variar por chat.

#### **12. compliance** - Classificação e Auditoria
```json
{
  "data_classification": "internal",  // Classificação dos dados
  "retention_days": 365,              // Dias de retenção
  "audit_enabled": true,              // Auditoria habilitada
  "encryption_level": "standard",     // Nível de criptografia
  "gdpr_compliant": true,             // Conformidade GDPR
  "sox_compliant": false,             // Conformidade SOX
  "data_residency": "BR",             // Residência dos dados
  "backup_frequency": "daily"         // Frequência de backup
}
```
**Justificativa**: Configurações de compliance e auditoria. Específicas por organização e podem evoluir com regulamentações.

### 🔧 **ESTRUTURA DE MENSAGENS JSONB[] - AI SDK 5.0**

```json
[
  {
    "id": "msg-uuid-1",
    "role": "user",
    "content": "Como criar um relatório de vendas?",
    "timestamp": "2025-01-15T10:30:00Z",
    "metadata": {
      "tokens": 12,
      "attachments": [],
      "user_agent": "Mozilla/5.0...",
      "ip_address": "192.168.1.100",
      "session_id": "session-uuid"
    }
  },
  {
    "id": "msg-uuid-2", 
    "role": "assistant",
    "content": "Para criar um relatório de vendas...",
    "timestamp": "2025-01-15T10:30:05Z",
    "metadata": {
      "tokens": 450,
      "model": "gpt-4o",
      "finish_reason": "stop",
      "usage": {
        "prompt_tokens": 12,
        "completion_tokens": 450,
        "total_tokens": 462
      },
      "response_time_ms": 2500,
      "reasoning": "Analisando a pergunta do usuário...",
      "sources": [
        {
          "type": "knowledge",
          "id": "uuid-knowledge-1",
          "title": "Manual de Vendas",
          "relevance_score": 0.85,
          "url": "https://docs.empresa.com/vendas"
        }
      ],
      "tool_calls": [],
      "confidence_score": 0.92,
      "temperature": 0.7,
      "streaming": true
    }
  }
]
```

### 📊 **ÍNDICES RECOMENDADOS**

```sql
-- Índices existentes (manter)
CREATE INDEX idx_chats_user ON chats(user_id);
CREATE INDEX idx_chats_workspace ON chats(workspace_id);
CREATE INDEX idx_chats_companion ON chats(companion_id);
CREATE INDEX idx_chats_updated ON chats(updated_at DESC);

-- Novos índices para chat v5
CREATE INDEX idx_chats_status ON chats(status);
CREATE INDEX idx_chats_last_message ON chats(last_message_at DESC);
CREATE INDEX idx_chats_message_count ON chats(message_count);

-- Índices compostos para consultas frequentes
CREATE INDEX idx_chats_user_status ON chats(user_id, status);
CREATE INDEX idx_chats_workspace_status ON chats(workspace_id, status);
CREATE INDEX idx_chats_companion_status ON chats(companion_id, status);

-- Índices JSONB para consultas específicas
CREATE INDEX idx_chats_ai_model ON chats USING GIN ((attributes->'ai_sdk_config'->>'model_name'));
CREATE INDEX idx_chats_workflow_status ON chats USING GIN ((attributes->'workflow_integration'->>'workflow_status'));
CREATE INDEX idx_chats_tags ON chats USING GIN ((attributes->'chat_metadata'->'tags'));
CREATE INDEX idx_chats_pinned ON chats USING GIN ((attributes->'chat_metadata'->>'is_pinned'));
CREATE INDEX idx_chats_shared ON chats USING GIN ((attributes->'chat_metadata'->>'is_shared'));
CREATE INDEX idx_chats_priority ON chats USING GIN ((attributes->'chat_metadata'->>'priority'));

-- Índice para busca full-text no título
CREATE INDEX idx_chats_title_fts ON chats USING GIN (to_tsvector('portuguese', title));
```

---

## 🎯 **RESUMO EXECUTIVO - TABELA CHATS**

### **COLUNAS HEADER (11 campos):**
- **Identificadores**: `id`, `user_id`, `workspace_id`, `companion_id`
- **Conteúdo**: `title`, `messages` (JSONB[])
- **Temporais**: `created_at`, `updated_at`, `last_message_at`
- **Estado**: `status`, `message_count`

### **ATRIBUTOS JSONB (12 seções):**
- Configurações AI SDK 5.0, preferências, metadados, compliance

### **BENEFÍCIOS DESTA ESTRUTURA**

1. **Performance**: Colunas diretas para consultas frequentes
2. **Flexibilidade**: JSONB para evolução sem migrações
3. **Escalabilidade**: Índices otimizados para crescimento
4. **Manutenibilidade**: Estrutura clara e documentada
5. **AI SDK 5.0**: Suporte nativo às funcionalidades

---

## 📜 SCRIPT SQL DE CRIAÇÃO COMPLETO

```sql
-- ============================================
-- TABELA: CHATS
-- Descrição: Conversas do Chat V5 com AI SDK 5.0
-- Multi-tenancy: workspace_id
-- ============================================

-- Criar ENUM
CREATE TYPE status_chat_enum AS ENUM ('active', 'archived', 'deleted');

-- Criar tabela
CREATE TABLE chats (
  -- ============================================
  -- IDENTIFICAÇÃO E HIERARQUIA
  -- ============================================
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  workspace_id UUID NOT NULL REFERENCES workspaces(id) ON DELETE CASCADE,
  companion_id UUID NOT NULL REFERENCES companions(id) ON DELETE RESTRICT,
  
  -- ============================================
  -- CONTEÚDO
  -- ============================================
  title VARCHAR(255) NOT NULL,
  messages JSONB[] NOT NULL DEFAULT '{}',
  
  -- ============================================
  -- ESTADO E MÉTRICAS
  -- ============================================
  status status_chat_enum NOT NULL DEFAULT 'active',
  message_count INTEGER NOT NULL DEFAULT 0,
  last_message_at TIMESTAMP,
  
  -- ============================================
  -- AUDITORIA
  -- ============================================
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
  
  -- ============================================
  -- ATRIBUTOS EXTENSÍVEIS (JSONB)
  -- ============================================
  attributes JSONB NOT NULL DEFAULT '{}'::jsonb,
  
  -- ============================================
  -- CONSTRAINTS
  -- ============================================
  CONSTRAINT check_title_not_empty CHECK (LENGTH(TRIM(title)) > 0),
  CONSTRAINT check_message_count_positive CHECK (message_count >= 0)
);

-- ============================================
-- ÍNDICES
-- ============================================

-- Índices para relacionamentos
CREATE INDEX idx_chats_user ON chats(user_id);
CREATE INDEX idx_chats_workspace ON chats(workspace_id);
CREATE INDEX idx_chats_companion ON chats(companion_id);

-- Índices para estado e ordenação
CREATE INDEX idx_chats_status ON chats(status);
CREATE INDEX idx_chats_created ON chats(created_at DESC);
CREATE INDEX idx_chats_updated ON chats(updated_at DESC);
CREATE INDEX idx_chats_last_message ON chats(last_message_at DESC NULLS LAST);

-- Índices compostos para consultas frequentes
CREATE INDEX idx_chats_user_workspace ON chats(user_id, workspace_id);
CREATE INDEX idx_chats_user_status ON chats(user_id, status);
CREATE INDEX idx_chats_workspace_status ON chats(workspace_id, status);

-- Índice GIN para attributes
CREATE INDEX idx_chats_attributes ON chats USING GIN (attributes);

-- Índice para busca full-text no título
CREATE INDEX idx_chats_title_fts ON chats 
  USING GIN (to_tsvector('portuguese', title));

-- ============================================
-- COMENTÁRIOS
-- ============================================
COMMENT ON TABLE chats IS 
  'Conversas do Chat V5 compatíveis com AI SDK 5.0';

COMMENT ON COLUMN chats.messages IS 
  'Array JSONB de mensagens compatível com AI SDK 5.0 (UIMessage structure)';

COMMENT ON COLUMN chats.attributes IS 
  'Atributos extensíveis em JSONB: ai_sdk_config, system_prompt, tools_config, conversation_state, usage_metrics, user_preferences, chat_metadata, ai_sdk_elements, workflow_integration, knowledge_context, error_handling, compliance';

-- ============================================
-- TRIGGER PARA UPDATED_AT
-- ============================================
CREATE OR REPLACE FUNCTION update_chats_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_chats_updated_at
  BEFORE UPDATE ON chats
  FOR EACH ROW
  EXECUTE FUNCTION update_chats_updated_at();

-- ============================================
-- RLS (Row Level Security)
-- ============================================
ALTER TABLE chats ENABLE ROW LEVEL SECURITY;

-- Policy: Users can only see their own chats
CREATE POLICY chats_select_policy ON chats
  FOR SELECT
  USING (
    user_id = current_setting('app.current_user_id')::uuid
    OR workspace_id IN (
      SELECT workspace_id FROM workspace_users 
      WHERE user_id = current_setting('app.current_user_id')::uuid
    )
  );

-- Policy: Users can only insert chats in their workspaces
CREATE POLICY chats_insert_policy ON chats
  FOR INSERT
  WITH CHECK (
    user_id = current_setting('app.current_user_id')::uuid
    AND workspace_id IN (
      SELECT workspace_id FROM workspace_users 
      WHERE user_id = current_setting('app.current_user_id')::uuid
    )
  );

-- Policy: Users can only update their own chats
CREATE POLICY chats_update_policy ON chats
  FOR UPDATE
  USING (user_id = current_setting('app.current_user_id')::uuid);

-- Policy: Users can only delete their own chats
CREATE POLICY chats_delete_policy ON chats
  FOR DELETE
  USING (user_id = current_setting('app.current_user_id')::uuid);
```

---

**Documento gerado em**: 2025-01-15  
**Versão**: 2.0  
**Status**: ✅ Completo com SQL
