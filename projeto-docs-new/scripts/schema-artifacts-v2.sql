-- ============================================================
-- ARTIFACTS v3.0 - Schema SQL (camelCase)
-- ============================================================
-- Versão: 3.0
-- Data: 2025-01-15
-- Descrição: Artefatos gerados (documentos, imagens, arquivos)
-- Mudanças v3.0: Nomenclatura camelCase com aspas duplas
-- ============================================================

-- ============================================================
-- ENUMS
-- ============================================================

CREATE TYPE "statusEnum" AS ENUM (
  'ACT',      -- Active
  'ARC',      -- Archived
  'DEL'       -- Deleted
);

-- ============================================================
-- TABELA: Artifacts
-- ============================================================

CREATE TABLE "HU_Artifacts" (
  -- Identificador único
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Relacionamentos
  "chatId" UUID REFERENCES "HU_Chats"(id) ON DELETE SET NULL,
  "wkspId" UUID NOT NULL REFERENCES "HU_Workspace"(id),
  
  -- Identificação
  "name" VARCHAR(255) NOT NULL,
  
  -- Conteúdo
  "content" BYTEA NOT NULL,
  "format" VARCHAR(10) NOT NULL,
  
  -- Estado
  "status" "statusEnum" NOT NULL DEFAULT 'ACT',
  
  -- Timestamps
  "createdAt" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  "updatedAt" TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================
-- ÍNDICES
-- ============================================================

-- Índices para relacionamentos
CREATE INDEX "idxArtifactsChatId" ON "HU_Artifacts"("chatId");
CREATE INDEX "idxArtifactsWkspId" ON "HU_Artifacts"("wkspId");

-- Índice para status
CREATE INDEX "idxArtifactsStatus" ON "HU_Artifacts"("status");

-- Índice para formato
CREATE INDEX "idxArtifactsFormat" ON "HU_Artifacts"("format");

-- Índices para ordenação temporal
CREATE INDEX "idxArtifactsCreatedAt" ON "HU_Artifacts"("createdAt" DESC);
CREATE INDEX "idxArtifactsUpdatedAt" ON "HU_Artifacts"("updatedAt" DESC);

-- Índices compostos para consultas frequentes
CREATE INDEX "idxArtifactsWkspStatus" ON "HU_Artifacts"("wkspId", "status");
CREATE INDEX "idxArtifactsChatStatus" ON "HU_Artifacts"("chatId", "status") WHERE "chatId" IS NOT NULL;
CREATE INDEX "idxArtifactsFormatStatus" ON "HU_Artifacts"("format", "status");

-- Índice para busca full-text no nome
CREATE INDEX "idxArtifactsNameFts" ON "HU_Artifacts" 
  USING GIN (to_tsvector('portuguese', "name"));

-- ============================================================
-- TRIGGER (auto-update updatedAt)
-- ============================================================

CREATE OR REPLACE FUNCTION updateArtifactUpdatedAt()
RETURNS TRIGGER AS $$
BEGIN
  NEW."updatedAt" = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER "trgUpdateArtifactUpdatedAt"
  BEFORE UPDATE ON "HU_Artifacts"
  FOR EACH ROW
  EXECUTE FUNCTION updateArtifactUpdatedAt();

-- ============================================================
-- COMENTÁRIOS DAS COLUNAS
-- ============================================================

COMMENT ON TABLE "HU_Artifacts" IS 'Tabela de artefatos v3.0 - Documentos, imagens e arquivos gerados';

COMMENT ON COLUMN "HU_Artifacts".id IS 'PK - Identificador único do artefato';
COMMENT ON COLUMN "HU_Artifacts"."chatId" IS 'FK - ID do chat que gerou o artefato → Chats.id (NULLABLE)';
COMMENT ON COLUMN "HU_Artifacts"."wkspId" IS 'FK - ID do workspace do artefato → HU_Workspace.id';
COMMENT ON COLUMN "HU_Artifacts"."name" IS 'Nome do artefato exibido na UI';
COMMENT ON COLUMN "HU_Artifacts"."content" IS 'Conteúdo binário do artefato (BYTEA)';
COMMENT ON COLUMN "HU_Artifacts"."format" IS 'Formato do arquivo (MD, SVG, PDF, HTML, JSON, PNG, DOCX, etc.)';
COMMENT ON COLUMN "HU_Artifacts"."status" IS 'Status do artefato (ACT, ARC, DEL)';
COMMENT ON COLUMN "HU_Artifacts"."createdAt" IS 'Data e hora de criação do artefato';
COMMENT ON COLUMN "HU_Artifacts"."updatedAt" IS 'Data e hora da última atualização (atualizado automaticamente via trigger)';

-- ============================================================================
-- FIM DO SCHEMA
-- ============================================================================

-- RESUMO FINAL:
-- ✅ Tabela: "HU_Artifacts" (9 campos)
-- ✅ Colunas camelCase: id, "chatId", "wkspId", "name", "content", "format", "status", "createdAt", "updatedAt"
-- ✅ Índices camelCase: "idxArtifactsChatId", "idxArtifactsWkspId", "idxArtifactsStatus", etc.
-- ✅ ENUM: "statusEnum" (ACT, ARC, DEL)
-- ✅ FKs: "chatId" → "Chats"(id), "wkspId" → "HU_Workspace"(id)
-- ✅ Aspas duplas obrigatórias para preservar camelCase no PostgreSQL
