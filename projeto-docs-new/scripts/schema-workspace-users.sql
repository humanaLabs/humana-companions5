-- ============================================================================
-- WORKSPACE_USERS v3.0 - Tabela Junction N:M (camelCase)
-- ============================================================================
-- Versão: 3.0
-- Data: 2025-01-15
-- Descrição: Relacionamento N:M entre usuários e workspaces
-- Mudanças v3.0: Nomenclatura camelCase com aspas duplas
-- ============================================================================

-- ============================================================================
-- TABELA: WorkspaceUsers (camelCase)
-- ============================================================================

CREATE TABLE "WorkspaceUsers" (
  -- ====================================
  -- HEADER (6 campos - Alta Frequência)
  -- ====================================
  
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  -- Identificador único da relação
  -- Usado em: 100% dos JOINs, auditoria
  -- Índice: PK (B-tree implícito)
  
  "workspaceId" UUID NOT NULL REFERENCES "HU_Workspace"(id) ON DELETE CASCADE,
  -- FK para workspace
  -- Usado em: 100% das queries de acesso
  -- Índice: idxWorkspaceUsersWorkspace (composto)
  
  "userId" UUID NOT NULL REFERENCES "User"(id) ON DELETE CASCADE,
  -- FK para usuário
  -- Usado em: 100% das queries de acesso
  -- Índice: idxWorkspaceUsersUser (composto)
  
  "role" VARCHAR(50) DEFAULT 'MEMBER',
  -- Role específico no workspace (OWNER, ADMIN, MEMBER, VIEWER)
  -- Usado em: 80% das queries (permissões)
  -- Índice: idxWorkspaceUsersRole (parcial)
  
  "joinedAt" TIMESTAMPTZ DEFAULT NOW(),
  -- Data de entrada no workspace
  -- Usado em: 70% das queries (auditoria, ordenação)
  -- Índice: idxWorkspaceUsersJoinedAt (DESC)
  
  "isActive" BOOLEAN DEFAULT TRUE,
  -- Status ativo/inativo da relação
  -- Usado em: 90% das queries (filtros)
  -- Índice: idxWorkspaceUsersActive (parcial)
  
  -- ====================================
  -- ATTRIBUTES (1 campo JSONB - Baixa Frequência)
  -- ====================================
  
  "permissions" JSONB DEFAULT '{}'::jsonb,
  -- Permissões específicas no workspace
  -- Estrutura: { "canInvite": true, "canManage": false, "canDelete": false }
  -- Usado em: 40% das queries (controle granular)
  -- Índice: idxWorkspaceUsersPermissions (GIN)
  
  -- ====================================
  -- CONSTRAINTS
  -- ====================================
  
  -- Prevenir duplicatas (mesmo usuário no mesmo workspace)
  CONSTRAINT unique_workspace_user UNIQUE("workspaceId", "userId"),
  
  -- Validar role
  CONSTRAINT valid_role CHECK ("role" IN ('OWNER', 'ADMIN', 'MEMBER', 'VIEWER')),
  
  -- Validar permissions JSONB
  CONSTRAINT valid_permissions CHECK (jsonb_typeof("permissions") = 'object')
);

-- ============================================================================
-- ÍNDICES (camelCase)
-- ============================================================================

-- Índices UNIQUE já criados automaticamente pelo PRIMARY KEY e UNIQUE constraint
-- - id (PRIMARY KEY - B-tree implícito)
-- - unique_workspace_user (UNIQUE - B-tree implícito)

-- Índice em workspaceId para consultas por workspace
CREATE INDEX "idxWorkspaceUsersWorkspace" ON "WorkspaceUsers"("workspaceId")
  WHERE "isActive" = TRUE;

-- Índice em userId para consultas por usuário
CREATE INDEX "idxWorkspaceUsersUser" ON "WorkspaceUsers"("userId")
  WHERE "isActive" = TRUE;

-- Índice composto para consultas frequentes (workspace + user)
CREATE INDEX "idxWorkspaceUsersWorkspaceUser" ON "WorkspaceUsers"("workspaceId", "userId")
  WHERE "isActive" = TRUE;

-- Índice em role para filtros por permissão
CREATE INDEX "idxWorkspaceUsersRole" ON "WorkspaceUsers"("role")
  WHERE "role" IN ('OWNER', 'ADMIN') AND "isActive" = TRUE;

-- Índice em joinedAt para ordenação cronológica
CREATE INDEX "idxWorkspaceUsersJoinedAt" ON "WorkspaceUsers"("joinedAt" DESC);

-- Índice parcial para relações ativas
CREATE INDEX "idxWorkspaceUsersActive" ON "WorkspaceUsers"("isActive")
  WHERE "isActive" = TRUE;

-- Índice GIN para permissions JSONB
CREATE INDEX "idxWorkspaceUsersPermissions" ON "WorkspaceUsers" USING GIN ("permissions");

-- ============================================================================
-- COMENTÁRIOS DA TABELA
-- ============================================================================

COMMENT ON TABLE "WorkspaceUsers" IS 'Tabela junction N:M - Relacionamento entre usuários e workspaces v3.0';

COMMENT ON COLUMN "WorkspaceUsers".id IS 'PK - Identificador único da relação workspace-user';
COMMENT ON COLUMN "WorkspaceUsers"."workspaceId" IS 'FK - ID do workspace';
COMMENT ON COLUMN "WorkspaceUsers"."userId" IS 'FK - ID do usuário';
COMMENT ON COLUMN "WorkspaceUsers"."role" IS 'Role específico no workspace (OWNER, ADMIN, MEMBER, VIEWER)';
COMMENT ON COLUMN "WorkspaceUsers"."joinedAt" IS 'Data de entrada do usuário no workspace';
COMMENT ON COLUMN "WorkspaceUsers"."isActive" IS 'Status ativo/inativo da relação (soft delete)';
COMMENT ON COLUMN "WorkspaceUsers"."permissions" IS 'JSONB - Permissões específicas no workspace (canInvite, canManage, canDelete)';

-- ============================================================================
-- FIM DO SCHEMA
-- ============================================================================

-- RESUMO FINAL:
-- ✅ Tabela: "WorkspaceUsers" (7 campos)
-- ✅ Colunas camelCase: id, "workspaceId", "userId", "role", "joinedAt", "isActive", "permissions"
-- ✅ Índices camelCase: "idxWorkspaceUsersWorkspace", "idxWorkspaceUsersUser", etc.
-- ✅ FKs: "workspaceId" → "HU_Workspace"(id), "userId" → "User"(id) ON DELETE CASCADE
-- ✅ Constraint: unique_workspace_user (previne duplicatas)
-- ✅ Aspas duplas obrigatórias para preservar camelCase no PostgreSQL

-- DOCUMENTAÇÃO:
-- Script de triggers: projeto-docs-new/scripts/schema-workspace-users-triggers.sql
-- Queries de exemplo: Ver documentação técnica
