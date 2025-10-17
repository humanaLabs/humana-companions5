-- ============================================================
-- PERMISSIONS_ACL v3.0 - Schema SQL (camelCase)
-- ============================================================
-- Versão: 3.0
-- Data: 2025-01-15
-- Descrição: Controle de acesso granular (ACL) com RLS e nomenclatura camelCase
-- Mudanças v3.0: Nomenclatura camelCase com aspas duplas
-- ============================================================

-- ============================================================
-- ENUMS
-- ============================================================

-- Enum para tipos de entidades no sistema ACL
CREATE TYPE "permEntityCodeEnum" AS ENUM (
  'ORG',  -- Organization
  'WSP',  -- Workspace
  'CMP',  -- Companion
  'PRL',  -- Profile
  'CHT',  -- Chat
  'KNW',  -- Knowledge
  'TOL'   -- Tool
);

-- Enum para ações permitidas no sistema ACL
CREATE TYPE "permActionEnum" AS ENUM (
  'REA',  -- Read
  'WRI',  -- Write
  'UPD',  -- Update
  'CRU',  -- CRUD (Create, Read, Update, Delete)
  'MNG'   -- Manage
);

-- ============================================================
-- TABELA: HU_Permission_ACL (camelCase)
-- ============================================================

CREATE TABLE "HU_Permission_ACL" (
  -- Identificador único
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Multi-tenancy (isolamento por organização) - FK corrigida
  "orgId" UUID NOT NULL REFERENCES "HU_Organization"(id) ON DELETE CASCADE,
  
  -- Entidade à qual a permissão se refere
  "entityCode" "permEntityCodeEnum" NOT NULL,
  "entityId" UUID NOT NULL,
  
  -- Ação permitida
  "action" "permActionEnum" NOT NULL,
  
  -- Auditoria: quem concedeu e para quem - FKs corrigidas
  "createdByUserId" UUID NOT NULL REFERENCES "HU_User"(id) ON DELETE CASCADE,
  "createdForUserId" UUID NOT NULL REFERENCES "HU_User"(id) ON DELETE CASCADE,
  
  -- Timestamps e validade temporal
  "createdAt" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  "validFrom" TIMESTAMPTZ NOT NULL,
  "validTo" TIMESTAMPTZ,
  "revokedAt" TIMESTAMPTZ,
  
  -- Constraints
  CONSTRAINT valid_dates CHECK ("validTo" IS NULL OR "validTo" > "createdAt")
);

-- ============================================================
-- ÍNDICES (camelCase)
-- ============================================================

-- Índice por organização (multi-tenancy)
CREATE INDEX "idxPermissionsAclOrgId" ON "HU_Permission_ACL"("orgId");

-- Índice por entidade (busca por recurso específico)
CREATE INDEX "idxPermissionsAclEntity" ON "HU_Permission_ACL"("entityCode", "entityId");

-- Índice por usuário que recebeu permissão (queries principais)
CREATE INDEX "idxPermissionsAclCreatedForUserId" ON "HU_Permission_ACL"("createdForUserId");

-- Índice por usuário que concedeu permissão (auditoria)
CREATE INDEX "idxPermissionsAclCreatedByUserId" ON "HU_Permission_ACL"("createdByUserId");

-- Índice parcial: apenas permissões ativas (otimização RLS)
CREATE INDEX "idxPermissionsAclActiveValid" ON "HU_Permission_ACL"("createdForUserId") 
  WHERE "revokedAt" IS NULL 
    AND ("validTo" IS NULL OR "validTo" > NOW());

-- Índice em createdAt para ordenação
CREATE INDEX "idxPermissionsAclCreatedAt" ON "HU_Permission_ACL"("createdAt" DESC);


-- ============================================================
-- COMENTÁRIOS DAS COLUNAS
-- ============================================================

COMMENT ON TABLE "HU_Permission_ACL" IS 'Tabela de permissões ACL v3.0 - Controle de acesso granular com nomenclatura camelCase';

COMMENT ON COLUMN "HU_Permission_ACL".id IS 'PK - Identificador único da permissão';
COMMENT ON COLUMN "HU_Permission_ACL"."orgId" IS 'FK - ID da organização (multi-tenancy) → HU_Organization.id';
COMMENT ON COLUMN "HU_Permission_ACL"."entityCode" IS 'Código do tipo de entidade (ORG, WSP, CMP, PRL, CHT, KNW, TOL)';
COMMENT ON COLUMN "HU_Permission_ACL"."entityId" IS 'ID da entidade específica à qual a permissão se refere';
COMMENT ON COLUMN "HU_Permission_ACL"."action" IS 'Ação permitida (REA, WRI, UPD, CRU, MNG)';
COMMENT ON COLUMN "HU_Permission_ACL"."createdByUserId" IS 'FK - ID do usuário que concedeu a permissão (auditoria) → HU_User.id';
COMMENT ON COLUMN "HU_Permission_ACL"."createdForUserId" IS 'FK - ID do usuário que recebeu a permissão → HU_User.id';
COMMENT ON COLUMN "HU_Permission_ACL"."createdAt" IS 'Data de criação da permissão';
COMMENT ON COLUMN "HU_Permission_ACL"."validFrom" IS 'Data de início da validade da permissão';
COMMENT ON COLUMN "HU_Permission_ACL"."validTo" IS 'Data de fim da validade da permissão (NULL = sem expiração)';
COMMENT ON COLUMN "HU_Permission_ACL"."revokedAt" IS 'Data de revogação da permissão (NULL = ativa)';

-- ============================================================================
-- FIM DO SCHEMA
-- ============================================================================

-- RESUMO FINAL:
-- ✅ Tabela: "HU_Permission_ACL" (11 campos)
-- ✅ Colunas camelCase: id, "orgId", "entityCode", "entityId", "action", "createdByUserId", "createdForUserId", "createdAt", "validFrom", "validTo", "revokedAt"
-- ✅ Índices camelCase: "idxPermissionsAclOrgId", "idxPermissionsAclEntity", "idxPermissionsAclCreatedForUserId", "idxPermissionsAclCreatedByUserId", "idxPermissionsAclActiveValid", "idxPermissionsAclCreatedAt"
-- ✅ ENUMs: "permEntityCodeEnum", "permActionEnum"
-- ✅ FKs corrigidas: "orgId" → "HU_Organization"(id), "createdByUserId"/"createdForUserId" → "HU_User"(id)
-- ✅ Aspas duplas obrigatórias para preservar camelCase no PostgreSQL

-- DOCUMENTAÇÃO:
-- Script de migração: projeto-docs-new/scripts/alter-permissions-acl-table.sql
-- Triggers: projeto-docs-new/scripts/schema-permissions-acl-triggers.sql

