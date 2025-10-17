-- ============================================================
-- HU_WORKSPACE v3.0 - Schema SQL (camelCase)
-- ============================================================
-- Versão: 3.0
-- Data: 2025-01-15
-- Descrição: Espaços de trabalho com nomenclatura camelCase
-- Mudanças v3.0: Nomenclatura camelCase com aspas duplas
-- ============================================================

-- ============================================================
-- ENUMS
-- ============================================================

CREATE TYPE "workspaceTypeEnum" AS ENUM (
  'PERSONAL',        -- Workspace pessoal do usuário
  'ORGANIZATIONAL',  -- Workspace padrão da organização (acesso automático)
  'FUNCTIONAL'       -- Workspace funcional/departamental (acesso manual)
);

-- ============================================================
-- TABELA: HU_Workspace (camelCase)
-- ============================================================

CREATE TABLE "HU_Workspace" (
  -- Identificador único
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Multi-tenancy (isolamento por organização) - FK corrigida
  "orgId" UUID NOT NULL REFERENCES "HU_Organization"(id) ON DELETE CASCADE,
  
  -- Identificação
  "name" VARCHAR(255) NOT NULL,
  "type" "workspaceTypeEnum" NOT NULL,
  
  -- Configurações
  "isDefault" BOOLEAN NOT NULL DEFAULT FALSE,
  "isActive" BOOLEAN NOT NULL DEFAULT TRUE,
  
  -- Timestamps
  "createdAt" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  "updatedAt" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  
  -- Atributos JSONB (informações adicionais)
  "attributes" JSONB DEFAULT '{}'::jsonb,
  
  -- Constraints
  CONSTRAINT valid_attributes CHECK (jsonb_typeof("attributes") = 'object')
);

-- ============================================================
-- ÍNDICES (camelCase)
-- ============================================================

-- Índice por organização (multi-tenancy)
CREATE INDEX "idxWorkspaceOrgId" ON "HU_Workspace"("orgId");

-- Índice parcial: apenas workspaces padrão
CREATE INDEX "idxWorkspaceIsDefault" ON "HU_Workspace"("isDefault") WHERE "isDefault" = TRUE;

-- Índice parcial: apenas workspaces ativos
CREATE INDEX "idxWorkspaceIsActive" ON "HU_Workspace"("isActive") WHERE "isActive" = TRUE;

-- Índices compostos para consultas frequentes
CREATE INDEX "idxWorkspaceOrgIdIsActive" ON "HU_Workspace"("orgId", "isActive");
CREATE INDEX "idxWorkspaceTypeIsActive" ON "HU_Workspace"("type", "isActive");

-- Índice em createdAt para ordenação
CREATE INDEX "idxWorkspaceCreatedAt" ON "HU_Workspace"("createdAt" DESC);

-- Índice GIN para atributos JSONB
CREATE INDEX "idxWorkspaceAttributes" ON "HU_Workspace" USING GIN ("attributes");


-- ============================================================
-- COMENTÁRIOS DAS COLUNAS
-- ============================================================

COMMENT ON TABLE "HU_Workspace" IS 'Tabela de workspaces v3.0 - Espaços de trabalho com nomenclatura camelCase';

COMMENT ON COLUMN "HU_Workspace".id IS 'PK - Identificador único do workspace';
COMMENT ON COLUMN "HU_Workspace"."orgId" IS 'FK - ID da organização dona do workspace → HU_Organization.id';
COMMENT ON COLUMN "HU_Workspace"."name" IS 'Nome do workspace exibido na UI';
COMMENT ON COLUMN "HU_Workspace"."type" IS 'Tipo do workspace (PERSONAL, ORGANIZATIONAL, FUNCTIONAL)';
COMMENT ON COLUMN "HU_Workspace"."isDefault" IS 'Se é o workspace padrão da organização';
COMMENT ON COLUMN "HU_Workspace"."isActive" IS 'Se o workspace está ativo (soft delete)';
COMMENT ON COLUMN "HU_Workspace"."createdAt" IS 'Data de criação do workspace';
COMMENT ON COLUMN "HU_Workspace"."updatedAt" IS 'Data de última atualização';
COMMENT ON COLUMN "HU_Workspace"."attributes" IS 'JSONB - Atributos adicionais (basic_info, visibility_settings, ownership_info, settings, features_enabled, etc.)';

-- ============================================================================
-- FIM DO SCHEMA
-- ============================================================================

-- RESUMO FINAL:
-- ✅ Tabela: "HU_Workspace" (9 campos)
-- ✅ Colunas camelCase: id, "orgId", "name", "type", "isDefault", "isActive", "createdAt", "updatedAt", "attributes"
-- ✅ Índices camelCase: "idxWorkspaceOrgId", "idxWorkspaceIsDefault", "idxWorkspaceIsActive", "idxWorkspaceOrgIdIsActive", "idxWorkspaceTypeIsActive", "idxWorkspaceCreatedAt", "idxWorkspaceAttributes"
-- ✅ ENUM: "workspaceTypeEnum" (PERSONAL, ORGANIZATIONAL, FUNCTIONAL)
-- ✅ FK corrigida: "orgId" → "HU_Organization"(id)
-- ✅ Aspas duplas obrigatórias para preservar camelCase no PostgreSQL

-- DOCUMENTAÇÃO:
-- Script de migração: projeto-docs-new/scripts/alter-workspace-table.sql
-- Triggers: projeto-docs-new/scripts/schema-organizations-workspaces-triggers.sql
-- Junction Table: projeto-docs-new/scripts/schema-workspace-users.sql

