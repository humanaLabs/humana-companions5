-- ============================================================
-- SKILLS v3.0 - Schema SQL (camelCase)
-- ============================================================
-- Versão: 3.0
-- Data: 2025-01-15
-- Descrição: Skills/Capacidades dos Companions (AI SDK 5.0 Tools)
-- Mudanças v3.0: Nomenclatura camelCase com aspas duplas
-- ============================================================

-- ============================================================
-- TABELA: Skills
-- ============================================================

CREATE TABLE "HU_Skills" (
  -- Identificador único
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Relacionamentos (multi-tenancy)
  "orgId" UUID NOT NULL REFERENCES "HU_Organization"(id) ON DELETE CASCADE,
  "companionId" UUID NOT NULL REFERENCES "HU_Companions"(id) ON DELETE CASCADE,
  
  -- Identificação
  "name" VARCHAR(100) NOT NULL,
  "displayName" VARCHAR(150) NOT NULL,
  "description" TEXT,
  
  -- AI SDK 5.0 Tool Interface
  "toolName" VARCHAR(100) NOT NULL,
  "toolDescription" TEXT NOT NULL,
  
  -- Classificação
  "category" VARCHAR(50) NOT NULL,
  "executionType" VARCHAR(20) NOT NULL DEFAULT 'sync',
  "version" VARCHAR(20) NOT NULL DEFAULT '1.0.0',
  
  -- Estado
  "isActive" BOOLEAN NOT NULL DEFAULT TRUE,
  "isDeprecated" BOOLEAN NOT NULL DEFAULT FALSE,
  
  -- Integração MCP
  "mcpIntegration" BOOLEAN NOT NULL DEFAULT FALSE,
  "hasMcpMapping" BOOLEAN NOT NULL DEFAULT FALSE,
  "mcpServerId" UUID REFERENCES "HU_Tools_MCP"(id) ON DELETE SET NULL,
  
  -- Configurações de Execução
  "maxRetries" INTEGER NOT NULL DEFAULT 3,
  "timeoutMs" INTEGER NOT NULL DEFAULT 30000,
  "cacheable" BOOLEAN NOT NULL DEFAULT FALSE,
  "cacheExpiryMs" INTEGER,
  
  -- Métricas de Performance
  "avgExecutionTimeMs" NUMERIC(10,2) DEFAULT 0,
  "successRate" NUMERIC(5,2) DEFAULT 100.0,
  "errorRate" NUMERIC(5,2) DEFAULT 0,
  "usageCount" INTEGER NOT NULL DEFAULT 0,
  "lastUsed" TIMESTAMPTZ,
  
  -- Atributos JSONB (tool_schema, metadata)
  "attributes" JSONB NOT NULL DEFAULT '{}'::jsonb,
  
  -- Timestamps
  "createdAt" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  "updatedAt" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  
  -- Constraints
  CONSTRAINT unique_skill_name_per_org UNIQUE ("orgId", "name"),
  CONSTRAINT check_timeout_positive CHECK ("timeoutMs" > 0),
  CONSTRAINT check_max_retries_positive CHECK ("maxRetries" >= 0),
  CONSTRAINT check_success_rate_range CHECK ("successRate" >= 0 AND "successRate" <= 100),
  CONSTRAINT check_error_rate_range CHECK ("errorRate" >= 0 AND "errorRate" <= 100),
  CONSTRAINT valid_attributes CHECK (jsonb_typeof("attributes") = 'object')
);

-- ============================================================
-- ÍNDICES
-- ============================================================

-- Índices para relacionamentos
CREATE INDEX "idxSkillsOrgId" ON "HU_Skills"("orgId");
CREATE INDEX "idxSkillsCompanionId" ON "HU_Skills"("companionId");
CREATE INDEX "idxSkillsMcpServerId" ON "HU_Skills"("mcpServerId");

-- Índice parcial: apenas skills ativas
CREATE INDEX "idxSkillsActive" ON "HU_Skills"("isActive") WHERE "isActive" = TRUE;

-- Índices para classificação
CREATE INDEX "idxSkillsCategory" ON "HU_Skills"("category");
CREATE INDEX "idxSkillsExecutionType" ON "HU_Skills"("executionType");

-- Índices para métricas
CREATE INDEX "idxSkillsUsage" ON "HU_Skills"("usageCount" DESC);
CREATE INDEX "idxSkillsPerformance" ON "HU_Skills"("successRate" DESC, "avgExecutionTimeMs");
CREATE INDEX "idxSkillsLastUsed" ON "HU_Skills"("lastUsed" DESC);

-- Índice GIN geral para attributes
CREATE INDEX "idxSkillsAttributes" ON "HU_Skills" USING GIN ("attributes");

-- Índices GIN para consultas específicas em attributes
CREATE INDEX "idxSkillsToolSchema" ON "HU_Skills" 
  USING GIN (("attributes"->'tool_schema'));
CREATE INDEX "idxSkillsMetadata" ON "HU_Skills" 
  USING GIN (("attributes"->'metadata'));

-- Índice para busca full-text
CREATE INDEX "idxSkillsNameFts" ON "HU_Skills" 
  USING GIN (to_tsvector('portuguese', "name" || ' ' || "displayName"));

-- ============================================================
-- TRIGGER (auto-update updatedAt)
-- ============================================================

CREATE OR REPLACE FUNCTION updateSkillUpdatedAt()
RETURNS TRIGGER AS $$
BEGIN
  NEW."updatedAt" = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER "trgUpdateSkillUpdatedAt"
  BEFORE UPDATE ON "HU_Skills"
  FOR EACH ROW
  EXECUTE FUNCTION updateSkillUpdatedAt();

-- ============================================================
-- COMENTÁRIOS DAS COLUNAS
-- ============================================================

COMMENT ON TABLE "HU_Skills" IS 'Tabela de skills v3.0 - Capacidades dos Companions (AI SDK 5.0 Tools)';

COMMENT ON COLUMN "HU_Skills".id IS 'PK - Identificador único da skill';
COMMENT ON COLUMN "HU_Skills"."orgId" IS 'FK - ID da organização → HU_Organization.id';
COMMENT ON COLUMN "HU_Skills"."companionId" IS 'FK - ID do companion dono da skill → Companions.id';
COMMENT ON COLUMN "HU_Skills"."name" IS 'Nome interno da skill (único por organização)';
COMMENT ON COLUMN "HU_Skills"."displayName" IS 'Nome exibido na UI';
COMMENT ON COLUMN "HU_Skills"."description" IS 'Descrição detalhada da skill';
COMMENT ON COLUMN "HU_Skills"."toolName" IS 'Nome da tool no AI SDK 5.0';
COMMENT ON COLUMN "HU_Skills"."toolDescription" IS 'Descrição da tool para o LLM entender quando usar';
COMMENT ON COLUMN "HU_Skills"."category" IS 'Categoria da skill (THINK, ACT, etc.)';
COMMENT ON COLUMN "HU_Skills"."executionType" IS 'Tipo de execução (sync, async)';
COMMENT ON COLUMN "HU_Skills"."version" IS 'Versão da skill';
COMMENT ON COLUMN "HU_Skills"."isActive" IS 'Indica se a skill está ativa';
COMMENT ON COLUMN "HU_Skills"."isDeprecated" IS 'Indica se a skill está deprecada';
COMMENT ON COLUMN "HU_Skills"."mcpIntegration" IS 'Indica se usa integração MCP';
COMMENT ON COLUMN "HU_Skills"."hasMcpMapping" IS 'Indica se possui mapeamento MCP configurado';
COMMENT ON COLUMN "HU_Skills"."mcpServerId" IS 'FK - ID do servidor MCP → ToolsMcp.id (opcional)';
COMMENT ON COLUMN "HU_Skills"."maxRetries" IS 'Número máximo de tentativas em caso de falha';
COMMENT ON COLUMN "HU_Skills"."timeoutMs" IS 'Timeout de execução em milissegundos';
COMMENT ON COLUMN "HU_Skills"."cacheable" IS 'Indica se o resultado pode ser cacheado';
COMMENT ON COLUMN "HU_Skills"."cacheExpiryMs" IS 'Tempo de expiração do cache em milissegundos';
COMMENT ON COLUMN "HU_Skills"."avgExecutionTimeMs" IS 'Tempo médio de execução em milissegundos';
COMMENT ON COLUMN "HU_Skills"."successRate" IS 'Taxa de sucesso em porcentagem (0-100)';
COMMENT ON COLUMN "HU_Skills"."errorRate" IS 'Taxa de erro em porcentagem (0-100)';
COMMENT ON COLUMN "HU_Skills"."usageCount" IS 'Contador de uso da skill';
COMMENT ON COLUMN "HU_Skills"."lastUsed" IS 'Data e hora do último uso';
COMMENT ON COLUMN "HU_Skills"."attributes" IS 'Atributos JSONB (tool_schema, metadata)';
COMMENT ON COLUMN "HU_Skills"."createdAt" IS 'Data e hora de criação da skill';
COMMENT ON COLUMN "HU_Skills"."updatedAt" IS 'Data e hora da última atualização (atualizado automaticamente via trigger)';

-- ============================================================================
-- FIM DO SCHEMA
-- ============================================================================

-- RESUMO FINAL:
-- ✅ Tabela: "HU_Skills" (26 campos)
-- ✅ Colunas camelCase: id, "orgId", "companionId", "name", "displayName", "description", etc.
-- ✅ Índices camelCase: "idxSkillsOrgId", "idxSkillsCompanionId", "idxSkillsActive", etc.
-- ✅ FKs: "orgId" → "HU_Organization"(id), "companionId" → "Companions"(id), "mcpServerId" → "ToolsMcp"(id)
-- ✅ Aspas duplas obrigatórias para preservar camelCase no PostgreSQL
