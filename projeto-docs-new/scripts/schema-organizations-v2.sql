-- ============================================================
-- HU_ORGANIZATION v3.0 - Schema SQL (camelCase)
-- ============================================================
-- Versão: 3.0
-- Data: 2025-01-15
-- Descrição: Organizações com nomenclatura camelCase
-- Mudanças v3.0: Nomenclatura camelCase com aspas duplas
-- Redução: 10 campos → 7 campos (30%)
-- ============================================================

-- ============================================================
-- TABELA: HU_Organization (camelCase)
-- ============================================================

CREATE TABLE "HU_Organization" (
  -- HEADER (6 colunas - Alta Frequência)
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "name" VARCHAR(255) NOT NULL UNIQUE,
  "createdAt" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  "updatedAt" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  "isActive" BOOLEAN NOT NULL DEFAULT TRUE,
  "inviteCode" VARCHAR(32) UNIQUE,
  
  -- ATTRIBUTES (1 JSONB - Baixa Frequência)
  "attributes" JSONB DEFAULT '{}'::jsonb,
  
  -- Constraints
  CONSTRAINT valid_attributes CHECK (jsonb_typeof("attributes") = 'object')
);

-- ============================================================
-- ÍNDICES (camelCase)
-- ============================================================

-- PK e UNIQUE em name e inviteCode são criados automaticamente pelas constraints

-- Índice parcial para organizações ativas
CREATE INDEX "idxOrganizationIsActive" ON "HU_Organization"("isActive") 
WHERE "isActive" = TRUE;

-- Índice GIN para queries JSONB
CREATE INDEX "idxOrganizationAttributes" ON "HU_Organization" USING GIN ("attributes");

-- Índice em createdAt para ordenação
CREATE INDEX "idxOrganizationCreatedAt" ON "HU_Organization"("createdAt" DESC);

-- Índice parcial em inviteCode (apenas não-nulos)
CREATE INDEX "idxOrganizationInviteCode" ON "HU_Organization"("inviteCode")
WHERE "inviteCode" IS NOT NULL;


-- ============================================================
-- COMENTÁRIOS DAS COLUNAS
-- ============================================================

COMMENT ON TABLE "HU_Organization" IS 'Tabela de organizações v3.0 - Multi-tenancy e gestão organizacional - Prefixo Humana + camelCase';

COMMENT ON COLUMN "HU_Organization".id IS 'PK - Identificador único da organização';
COMMENT ON COLUMN "HU_Organization"."name" IS 'Nome da organização (único e obrigatório)';
COMMENT ON COLUMN "HU_Organization"."createdAt" IS 'Data de criação da organização';
COMMENT ON COLUMN "HU_Organization"."updatedAt" IS 'Data de última atualização (atualizado automaticamente via trigger)';
COMMENT ON COLUMN "HU_Organization"."isActive" IS 'Indica se a organização está ativa (soft delete)';
COMMENT ON COLUMN "HU_Organization"."inviteCode" IS 'Código único de convite para onboarding de usuários';
COMMENT ON COLUMN "HU_Organization"."attributes" IS 'JSONB - Dados estendidos (description, tenantConfig, structure, culture, metadata)';

-- ============================================================================
-- FIM DO SCHEMA
-- ============================================================================

-- RESUMO FINAL:
-- ✅ Tabela: "HU_Organization" (7 campos)
-- ✅ Colunas camelCase: id, "name", "createdAt", "updatedAt", "isActive", "inviteCode", "attributes"
-- ✅ Índices camelCase: "idxOrganizationIsActive", "idxOrganizationAttributes", "idxOrganizationCreatedAt", "idxOrganizationInviteCode"
-- ✅ Prefixo: HU_ (Humana) para identificação clara
-- ✅ Aspas duplas obrigatórias para preservar camelCase no PostgreSQL

-- DOCUMENTAÇÃO:
-- Script de migração: projeto-docs-new/scripts/alter-organization-table.sql
-- Triggers: projeto-docs-new/scripts/schema-organizations-workspaces-triggers.sql

