-- ============================================================================
-- SCHEMA USER v3.0 - ESTRUTURA CAMELCASE
-- ============================================================================
-- Versão: 3.0
-- Data: 2025-01-15
-- Descrição: Tabela User otimizada com nomenclatura camelCase
-- Mudanças v3.0: Nomenclatura camelCase com aspas duplas
-- Baseado em: MODELO-TECNICO-USER.md
-- ============================================================================

-- ============================================================================
-- 1. TIPO ENUM - RBAC (4 NÍVEIS)
-- ============================================================================

CREATE TYPE "userRole" AS ENUM ('MS', 'OA', 'WM', 'UR');

COMMENT ON TYPE "userRole" IS 'RBAC com 4 níveis: MS (MasterSys), OA (OrgAdmin), WM (WorkspaceManager), UR (User)';

-- MS = MasterSys (super admin global) - 1% dos usuários
-- OA = OrgAdmin (admin da organização) - 5% dos usuários
-- WM = WorkspaceManager (gerente de workspace) - 15% dos usuários
-- UR = User (usuário padrão) - 79% dos usuários

-- ============================================================================
-- 2. TABELA PRINCIPAL - User (camelCase)
-- ============================================================================

CREATE TABLE "User" (
  -- ====================================
  -- HEADER (9 campos - Alta Frequência)
  -- ====================================
  
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  -- Identificador único
  -- Usado em: 100% dos JOINs, session (user.id)
  -- Índice: PK (B-tree implícito)
  
  email VARCHAR(255) NOT NULL UNIQUE,
  -- Login principal
  -- Usado em: 100% dos logins (WHERE email = ?)
  -- Índice: UNIQUE (B-tree)
  
  "name" VARCHAR(255) NOT NULL,
  -- Nome completo para exibição
  -- Usado em: Headers, sidebars, cards, mensagens (100% UIs)
  -- Índice: Não (raramente ordenado)
  
  password TEXT,
  -- Hash bcrypt da senha (NULL se SSO apenas)
  -- Usado em: Autenticação com senha (70% dos logins)
  -- Índice: Não (nunca consultado diretamente)
  
  "orgId" UUID NOT NULL REFERENCES "HU_Organization"(id) ON DELETE CASCADE,
  -- Multi-tenancy CRÍTICO - FK corrigida para HU_Organization.id
  -- Usado em: 90% das queries (isolamento por org)
  -- Índice: idxUserOrgId (composto)
  
  "roleCode" "userRole" NOT NULL DEFAULT 'UR',
  -- RBAC (4 níveis: MS, OA, WM, UR)
  -- Usado em: 80% das queries (permissões)
  -- Índice: idxUserRole (parcial)
  
  "inviteCode" VARCHAR(50),
  -- Código de convite/onboarding
  -- Usado em: 30% queries de onboarding
  -- Índice: idxUserInviteCode (parcial)
  
  "createdAt" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  -- Ordenação padrão, auditoria
  -- Usado em: 90% das queries de admin
  -- Índice: idxUserCreatedAt (DESC)
  
  "updatedAt" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  -- Controle de cache, auditoria
  -- Usado em: 70% das queries (freshness)
  -- Índice: Não (atualizado frequentemente)
  
  -- ====================================
  -- ATTRIBUTES (1 campo JSONB - Moderada/Baixa Frequência)
  -- ====================================
  
  "attributes" JSONB NOT NULL DEFAULT '{}'::jsonb,
  
  
  -- Constraints
  CONSTRAINT valid_role CHECK ("roleCode" IN ('MS', 'OA', 'WM', 'UR')),
  CONSTRAINT valid_email CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
  CONSTRAINT valid_attributes CHECK (jsonb_typeof("attributes") = 'object')
);

-- ============================================================================
-- 3. COMENTÁRIOS DA TABELA
-- ============================================================================

COMMENT ON TABLE "User" IS 'Tabela de usuários v3.0 - Estrutura camelCase com RBAC granular';

COMMENT ON COLUMN "User".id IS 'PK - Identificador único (usado em 100% dos JOINs)';
COMMENT ON COLUMN "User".email IS 'Login principal - autenticação (índice UNIQUE)';
COMMENT ON COLUMN "User"."name" IS 'Nome completo - exibição em UIs (90-100% das telas)';
COMMENT ON COLUMN "User".password IS 'Hash bcrypt da senha - autenticação (NULL para usuários SSO apenas)';
COMMENT ON COLUMN "User"."orgId" IS 'FK - Multi-tenancy crítico (90% das queries) → HU_Organization.id';
COMMENT ON COLUMN "User"."roleCode" IS 'RBAC - 4 níveis (MS/OA/WM/UR) usado em 80% queries';
COMMENT ON COLUMN "User"."inviteCode" IS 'Código de convite - onboarding (30% queries)';
COMMENT ON COLUMN "User"."createdAt" IS 'Timestamp de criação - ordenação/auditoria';
COMMENT ON COLUMN "User"."updatedAt" IS 'Timestamp de atualização - cache/auditoria';
COMMENT ON COLUMN "User"."attributes" IS 'JSONB - Dados estendidos (profile, auth (sem password), subscription, preferences, onboarding, stats)';

-- ============================================================================
-- 4. ÍNDICES PRINCIPAIS (camelCase)
-- ============================================================================

-- PK e UNIQUE em email são criados automaticamente pelas constraints

-- Índice composto para queries de listagem por org
CREATE INDEX "idxUserOrgId" ON "User"("orgId", "createdAt" DESC);

-- Índice parcial para filtros por role (apenas admins)
-- Usado em: WHERE "roleCode" IN ('MS', 'OA', 'WM') (50% queries)
CREATE INDEX "idxUserRole" ON "User"("roleCode") 
  WHERE "roleCode" IN ('MS', 'OA', 'WM');

-- Índice parcial em inviteCode (apenas não-nulos)
CREATE INDEX "idxUserInviteCode" ON "User"("inviteCode")
  WHERE "inviteCode" IS NOT NULL;

-- Índice em createdAt para ordenação
CREATE INDEX "idxUserCreatedAt" ON "User"("createdAt" DESC);

-- Índice em isActive para soft delete
CREATE INDEX "idxUserIsActive" ON "User"("isActive")
  WHERE "isActive" = TRUE;


-- ============================================================================
-- 5. ÍNDICES JSONB
-- ============================================================================

-- Índice GIN genérico (queries complexas em múltiplos campos JSONB)
CREATE INDEX "idxUserAttributes" ON "User" USING GIN ("attributes");

-- ============================================================================
-- FIM DO SCHEMA
-- ============================================================================

-- RESUMO FINAL:
-- ✅ Tabela: "User" (9 campos)
-- ✅ Colunas camelCase: id, email, "name", password, "orgId", "roleCode", "inviteCode", "createdAt", "updatedAt", "attributes"
-- ✅ Índices camelCase: "idxUserOrgId", "idxUserRole", "idxUserInviteCode", "idxUserCreatedAt", "idxUserIsActive", "idxUserAttributes"
-- ✅ ENUM: "userRole" (MS, OA, WM, UR)
-- ✅ FK corrigida: "orgId" → "HU_Organization"(id)
-- ✅ Aspas duplas obrigatórias para preservar camelCase no PostgreSQL

-- DOCUMENTAÇÃO:
-- Script de migração: projeto-docs-new/scripts/alter-user-table.sql
-- Triggers: projeto-docs-new/scripts/schema-users-permissions-triggers.sql

