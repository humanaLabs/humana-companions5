-- ============================================================
-- TOOLS_MCP v3.0 - Schema SQL (camelCase)
-- ============================================================
-- Versão: 3.0
-- Data: 2025-01-15
-- Descrição: Ferramentas MCP (Model Context Protocol)
-- Mudanças v3.0: Nomenclatura camelCase com aspas duplas
-- ============================================================

-- ============================================================
-- ENUMS
-- ============================================================

CREATE TYPE "toolTypeEnum" AS ENUM (
  'DATABASE',     -- Ferramenta de banco de dados
  'API',          -- Ferramenta de API
  'FILESYSTEM',   -- Ferramenta de sistema de arquivos
  'CUSTOM'        -- Ferramenta customizada
);

CREATE TYPE "authTypeEnum" AS ENUM (
  'BEARER',       -- Bearer token
  'OAUTH',        -- OAuth 2.0
  'API_KEY',      -- API Key
  'NONE'          -- Sem autenticação
);

-- ============================================================
-- TABELA: ToolsMcp
-- ============================================================

CREATE TABLE "HU_Tools_MCP" (
  -- Identificador único
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Multi-tenancy (isolamento por organização)
  "orgId" UUID NOT NULL REFERENCES "HU_Organization"(id) ON DELETE CASCADE,
  
  -- Propriedade (quem configurou)
  "configuredByUserId" UUID NOT NULL REFERENCES "HU_User"(id),
  
  -- Identificação
  "name" VARCHAR(255) NOT NULL,
  "type" "toolTypeEnum" NOT NULL,
  
  -- Autenticação
  "authType" "authTypeEnum" NOT NULL,
  
  -- Atributos JSONB (configurações e metadados)
  "attributes" JSONB NOT NULL DEFAULT '{}'::jsonb,
  
  -- Estado
  "isActive" BOOLEAN NOT NULL DEFAULT TRUE,
  
  -- Timestamps
  "createdAt" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  "updatedAt" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  
  -- Constraints
  CONSTRAINT valid_attributes CHECK (jsonb_typeof("attributes") = 'object')
);

-- ============================================================
-- ÍNDICES
-- ============================================================

-- Índices para relacionamentos
CREATE INDEX "idxToolsMcpOrgId" ON "HU_Tools_MCP"("orgId");
CREATE INDEX "idxToolsMcpConfiguredBy" ON "HU_Tools_MCP"("configuredByUserId");

-- Índices para tipo e autenticação
CREATE INDEX "idxToolsMcpType" ON "HU_Tools_MCP"("type");
CREATE INDEX "idxToolsMcpAuthType" ON "HU_Tools_MCP"("authType");

-- Índice parcial para ferramentas ativas
CREATE INDEX "idxToolsMcpActive" ON "HU_Tools_MCP"("isActive") WHERE "isActive" = TRUE;

-- Índice composto para consultas frequentes
CREATE INDEX "idxToolsMcpOrgActive" ON "HU_Tools_MCP"("orgId", "isActive");

-- Índice GIN para attributes
CREATE INDEX "idxToolsMcpAttributes" ON "HU_Tools_MCP" USING GIN ("attributes");

-- ============================================================
-- TRIGGER (auto-update updatedAt)
-- ============================================================

CREATE OR REPLACE FUNCTION updateToolMcpUpdatedAt()
RETURNS TRIGGER AS $$
BEGIN
  NEW."updatedAt" = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER "trgUpdateToolMcpUpdatedAt"
  BEFORE UPDATE ON "HU_Tools_MCP"
  FOR EACH ROW
  EXECUTE FUNCTION updateToolMcpUpdatedAt();

-- ============================================================
-- COMENTÁRIOS DAS COLUNAS
-- ============================================================

COMMENT ON TABLE "HU_Tools_MCP" IS 'Tabela de ferramentas MCP v3.0 - Model Context Protocol';

COMMENT ON COLUMN "HU_Tools_MCP".id IS 'PK - Identificador único da ferramenta MCP';
COMMENT ON COLUMN "HU_Tools_MCP"."orgId" IS 'FK - ID da organização → HU_Organization.id';
COMMENT ON COLUMN "HU_Tools_MCP"."configuredByUserId" IS 'FK - ID do usuário que configurou → User.id';
COMMENT ON COLUMN "HU_Tools_MCP"."name" IS 'Nome da ferramenta MCP';
COMMENT ON COLUMN "HU_Tools_MCP"."type" IS 'Tipo da ferramenta (DATABASE, API, FILESYSTEM, CUSTOM)';
COMMENT ON COLUMN "HU_Tools_MCP"."authType" IS 'Tipo de autenticação (BEARER, OAUTH, API_KEY, NONE)';
COMMENT ON COLUMN "HU_Tools_MCP"."attributes" IS 'Atributos JSONB (configurações e metadados)';
COMMENT ON COLUMN "HU_Tools_MCP"."isActive" IS 'Indica se a ferramenta está ativa';
COMMENT ON COLUMN "HU_Tools_MCP"."createdAt" IS 'Data de criação';
COMMENT ON COLUMN "HU_Tools_MCP"."updatedAt" IS 'Data de última atualização (atualizado automaticamente via trigger)';

-- ============================================================================
-- FIM DO SCHEMA
-- ============================================================================

-- RESUMO FINAL:
-- ✅ Tabela: "HU_Tools_MCP" (9 campos)
-- ✅ Colunas camelCase: id, "orgId", "configuredByUserId", "name", "type", "authType", "attributes", "isActive", "createdAt", "updatedAt"
-- ✅ Índices camelCase: "idxToolsMcpOrgId", "idxToolsMcpConfiguredBy", "idxToolsMcpType", etc.
-- ✅ ENUMs: "toolTypeEnum", "authTypeEnum"
-- ✅ FKs: "orgId" → "HU_Organization"(id), "configuredByUserId" → "User"(id)
-- ✅ Aspas duplas obrigatórias para preservar camelCase no PostgreSQL
