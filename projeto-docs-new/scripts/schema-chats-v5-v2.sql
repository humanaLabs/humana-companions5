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

CREATE TYPE "statusEnum" AS ENUM (
  'active',
  'archived',
  'deleted'
);

-- ============================================================
-- TABELA: Chats
-- ============================================================

CREATE TABLE "HU_Chats" (
  -- Identificador único
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Relacionamentos
  "userId" UUID NOT NULL REFERENCES "HU_User"(id),
  "wkspId" UUID NOT NULL REFERENCES "HU_Workspace"(id),
  "companionId" UUID NOT NULL REFERENCES "HU_Companions"(id),
  
  -- Identificação
  "title" VARCHAR(255) NOT NULL,
  
  -- Mensagens (array de JSONB - AI SDK 5.0 format)
  "messages" JSONB[] NOT NULL DEFAULT '{}',
  
  -- Estado
  "status" "statusEnum" NOT NULL DEFAULT 'active',
  
  -- Métricas de performance
  "lastMessageAt" TIMESTAMPTZ,
  "messageCount" INTEGER NOT NULL DEFAULT 0,
  
  -- Atributos JSONB (ai_sdk_config, metadata)
  "attributes" JSONB NOT NULL DEFAULT '{}'::jsonb,
  
  -- Timestamps
  "createdAt" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  "updatedAt" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  
  -- Constraints
  CONSTRAINT check_message_count_positive CHECK ("messageCount" >= 0),
  CONSTRAINT valid_attributes CHECK (jsonb_typeof("attributes") = 'object')
);

-- ============================================================
-- ÍNDICES
-- ============================================================

-- Índices para relacionamentos
CREATE INDEX "idxChatsUserId" ON "HU_Chats"("userId");
CREATE INDEX "idxChatsWkspId" ON "HU_Chats"("wkspId");
CREATE INDEX "idxChatsCompanionId" ON "HU_Chats"("companionId");

-- Índice parcial: apenas chats ativos
CREATE INDEX "idxChatsActive" ON "HU_Chats"("status") WHERE "status" = 'active';

-- Índice para última mensagem (ordenação por atividade)
CREATE INDEX "idxChatsLastMessage" ON "HU_Chats"("lastMessageAt" DESC NULLS LAST);

-- Índice composto para consultas frequentes
CREATE INDEX "idxChatsUserStatus" ON "HU_Chats"("userId", "status");
CREATE INDEX "idxChatsUserUpdated" ON "HU_Chats"("userId", "updatedAt" DESC);

-- Índice GIN geral para attributes
CREATE INDEX "idxChatsAttributes" ON "HU_Chats" USING GIN ("attributes");

-- Índices GIN para consultas específicas em attributes
CREATE INDEX "idxChatsAiSdkConfig" ON "HU_Chats" 
  USING GIN (("attributes"->'ai_sdk_config'));
CREATE INDEX "idxChatsMetadata" ON "HU_Chats" 
  USING GIN (("attributes"->'metadata'));

-- Índice para busca full-text no título
CREATE INDEX "idxChatsTitleFts" ON "HU_Chats" 
  USING GIN (to_tsvector('portuguese', "title"));

-- ============================================================
-- TRIGGER (auto-update updatedAt)
-- ============================================================

CREATE OR REPLACE FUNCTION updateChatUpdatedAt()
RETURNS TRIGGER AS $$
BEGIN
  NEW."updatedAt" = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER "trgUpdateChatUpdatedAt"
  BEFORE UPDATE ON "HU_Chats"
  FOR EACH ROW
  EXECUTE FUNCTION updateChatUpdatedAt();

-- ============================================================
-- COMENTÁRIOS DAS COLUNAS
-- ============================================================

COMMENT ON TABLE "HU_Chats" IS 'Tabela de chats v3.0 - Conversas com AI integradas com AI SDK 5.0';

COMMENT ON COLUMN "HU_Chats".id IS 'PK - Identificador único do chat';
COMMENT ON COLUMN "HU_Chats"."userId" IS 'FK - ID do usuário dono do chat → User.id';
COMMENT ON COLUMN "HU_Chats"."wkspId" IS 'FK - ID do workspace do chat → HU_Workspace.id';
COMMENT ON COLUMN "HU_Chats"."companionId" IS 'FK - ID do companion usado no chat → Companions.id';
COMMENT ON COLUMN "HU_Chats"."title" IS 'Título do chat exibido na UI';
COMMENT ON COLUMN "HU_Chats"."messages" IS 'Array de mensagens do chat (formato AI SDK 5.0 em JSONB[])';
COMMENT ON COLUMN "HU_Chats"."status" IS 'Status do chat (active, archived, deleted)';
COMMENT ON COLUMN "HU_Chats"."lastMessageAt" IS 'Timestamp da última mensagem (para ordenação)';
COMMENT ON COLUMN "HU_Chats"."messageCount" IS 'Contador de mensagens (para paginação)';
COMMENT ON COLUMN "HU_Chats"."attributes" IS 'Atributos JSONB (ai_sdk_config, metadata)';
COMMENT ON COLUMN "HU_Chats"."createdAt" IS 'Data e hora de criação do chat';
COMMENT ON COLUMN "HU_Chats"."updatedAt" IS 'Data e hora da última atualização (atualizado automaticamente via trigger)';


