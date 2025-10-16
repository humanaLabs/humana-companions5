-- ============================================================
-- CHATS v2.0 - Schema SQL
-- ============================================================
-- Versão: 2.0
-- Data: 2025-01-10
-- Descrição: Chats integrados com AI SDK 5.0
-- ============================================================

-- ============================================================
-- ENUMS
-- ============================================================

CREATE TYPE status_chat_enum AS ENUM (
  'active',
  'archived',
  'deleted'
);

-- ============================================================
-- TABELA: chats
-- ============================================================

CREATE TABLE chats (
  -- Identificador único
  chat_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Relacionamentos
  user_id UUID NOT NULL REFERENCES users(user_id),
  workspace_id UUID NOT NULL REFERENCES workspaces(wksp_id),
  companion_id UUID NOT NULL REFERENCES companions(companion_id),
  
  -- Identificação
  chat_title VARCHAR(255) NOT NULL,
  
  -- Mensagens (array de JSONB - AI SDK 5.0 format)
  chat_messages JSONB[] NOT NULL DEFAULT '{}',
  
  -- Estado
  chat_status status_chat_enum NOT NULL DEFAULT 'active',
  
  -- Métricas de performance
  chat_last_message_at TIMESTAMP,
  chat_message_count INTEGER NOT NULL DEFAULT 0,
  
  -- Atributos JSONB (ai_sdk_config, metadata)
  chat_attributes JSONB NOT NULL DEFAULT '{}'::jsonb,
  
  -- Timestamps
  chat_created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  chat_updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
  
  -- Constraints
  CONSTRAINT check_message_count_positive CHECK (chat_message_count >= 0),
  CONSTRAINT valid_attributes CHECK (jsonb_typeof(chat_attributes) = 'object')
);

-- ============================================================
-- ÍNDICES
-- ============================================================

-- Índices para relacionamentos
CREATE INDEX idx_chats_user ON chats(user_id);
CREATE INDEX idx_chats_workspace ON chats(workspace_id);
CREATE INDEX idx_chats_companion ON chats(companion_id);

-- Índice parcial: apenas chats ativos
CREATE INDEX idx_chats_active ON chats(chat_status) WHERE chat_status = 'active';

-- Índice para última mensagem (ordenação por atividade)
CREATE INDEX idx_chats_last_message ON chats(chat_last_message_at DESC NULLS LAST);

-- Índice composto para consultas frequentes
CREATE INDEX idx_chats_user_status ON chats(user_id, chat_status);
CREATE INDEX idx_chats_user_updated ON chats(user_id, chat_updated_at DESC);

-- Índice GIN geral para attributes
CREATE INDEX idx_chats_attributes_gin ON chats USING GIN (chat_attributes);

-- Índices GIN para consultas específicas em chat_attributes
CREATE INDEX idx_chats_ai_sdk_config ON chats 
  USING GIN ((chat_attributes->'ai_sdk_config'));
CREATE INDEX idx_chats_metadata ON chats 
  USING GIN ((chat_attributes->'metadata'));

-- Índice para busca full-text no título
CREATE INDEX idx_chats_title_fts ON chats 
  USING GIN (to_tsvector('portuguese', chat_title));

-- ============================================================
-- TRIGGER (auto-update updated_at)
-- ============================================================

CREATE OR REPLACE FUNCTION update_chat_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.chat_updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_chat_updated_at
  BEFORE UPDATE ON chats
  FOR EACH ROW
  EXECUTE FUNCTION update_chat_updated_at();

-- ============================================================
-- COMENTÁRIOS DAS COLUNAS
-- ============================================================

COMMENT ON COLUMN chats.chat_id IS 'Identificador único do chat (PK)';
COMMENT ON COLUMN chats.user_id IS 'ID do usuário dono do chat (FK → users)';
COMMENT ON COLUMN chats.workspace_id IS 'ID do workspace do chat (FK → workspaces)';
COMMENT ON COLUMN chats.companion_id IS 'ID do companion usado no chat (FK → new_companions)';
COMMENT ON COLUMN chats.chat_title IS 'Título do chat exibido na UI';
COMMENT ON COLUMN chats.chat_messages IS 'Array de mensagens do chat (formato AI SDK 5.0 em JSONB[])';
COMMENT ON COLUMN chats.chat_status IS 'Status do chat (active, archived, deleted)';
COMMENT ON COLUMN chats.chat_last_message_at IS 'Timestamp da última mensagem (para ordenação)';
COMMENT ON COLUMN chats.chat_message_count IS 'Contador de mensagens (para paginação)';
COMMENT ON COLUMN chats.chat_attributes IS 'Atributos JSONB (ai_sdk_config, metadata)';
COMMENT ON COLUMN chats.chat_created_at IS 'Data e hora de criação do chat';
COMMENT ON COLUMN chats.chat_updated_at IS 'Data e hora da última atualização (atualizado automaticamente via trigger)';


