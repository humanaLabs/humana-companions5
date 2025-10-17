-- ============================================================================
-- WORKSPACE_USERS v3.0 - Tabela Junction N:M (camelCase)
-- ============================================================================
-- Versão: 3.0
-- Data: 2025-01-15
-- Descrição: Relacionamento N:M entre usuários e workspaces
-- Mudanças v3.0: Nomenclatura camelCase com aspas duplas
-- ============================================================================

-- ============================================================================
-- TABELA: HU_Workspace_User (camelCase)
-- ============================================================================

CREATE TABLE "HU_Workspace_User" (
  -- ====================================
  -- HEADER (6 campos - Alta Frequência)
  -- ====================================
  
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  -- Identificador único da relação
  -- Usado em: 100% dos JOINs, auditoria
  -- Índice: PK (B-tree implícito)
  
  "wkspId" UUID NOT NULL REFERENCES "HU_Workspace"(id) ON DELETE CASCADE,
  -- FK para workspace
  -- Usado em: 100% das queries de acesso
  -- Índice: idxWkspUserByWkspId (composto)
  
  "userId" UUID NOT NULL REFERENCES "HU_User"(id) ON DELETE CASCADE,
  -- FK para usuário
  -- Usado em: 100% das queries de acesso
  -- Índice: idxWkspUserByUserId (composto)
  
  "joinedAt" TIMESTAMPTZ DEFAULT NOW(),
  -- Data de entrada no workspace
  -- Usado em: 70% das queries (auditoria, ordenação)
  -- Índice: idxWkspUserJoinedAt (DESC)
  
  "isActive" BOOLEAN DEFAULT TRUE,
  -- Status ativo/inativo da relação
  -- Usado em: 90% das queries (filtros)
  -- Índice: idxWkspUserActive (parcial)
  
  "updatedAt" TIMESTAMPTZ DEFAULT NOW(),
  -- Data da última atualização
  -- Usado em: 50% das queries (tracking de mudanças)
  -- Índice: idxWkspUserUpdatedAt (DESC)
  
  -- ====================================
  -- CONSTRAINTS
  -- ====================================
  
  -- Prevenir duplicatas (mesmo usuário no mesmo workspace)
  CONSTRAINT unique_workspace_user UNIQUE("wkspId", "userId")
);

-- ============================================================================
-- ÍNDICES (camelCase)
-- ============================================================================

-- Índices UNIQUE já criados automaticamente pelo PRIMARY KEY e UNIQUE constraint
-- - id (PRIMARY KEY - B-tree implícito)
-- - unique_workspace_user (UNIQUE - B-tree implícito)

-- Índice em wkspId para consultas por workspace
CREATE INDEX "idxWkspUserByWkspId" ON "HU_Workspace_User"("wkspId")
  WHERE "isActive" = TRUE;

-- Índice em userId para consultas por usuário
CREATE INDEX "idxWkspUserByUserId" ON "HU_Workspace_User"("userId")
  WHERE "isActive" = TRUE;

-- Índice composto para consultas frequentes (workspace + user)
CREATE INDEX "idxWkspUserComposite" ON "HU_Workspace_User"("wkspId", "userId")
  WHERE "isActive" = TRUE;

-- Índice em joinedAt para ordenação cronológica
CREATE INDEX "idxWkspUserJoinedAt" ON "HU_Workspace_User"("joinedAt" DESC);

-- Índice em updatedAt para tracking de mudanças
CREATE INDEX "idxWkspUserUpdatedAt" ON "HU_Workspace_User"("updatedAt" DESC);

-- Índice parcial para relações ativas
CREATE INDEX "idxWkspUserActive" ON "HU_Workspace_User"("isActive")
  WHERE "isActive" = TRUE;

-- ============================================================================
-- COMENTÁRIOS DA TABELA
-- ============================================================================

COMMENT ON TABLE "HU_Workspace_User" IS 'Tabela junction N:M - Relacionamento entre usuários e workspaces v3.0';

COMMENT ON COLUMN "HU_Workspace_User".id IS 'PK - Identificador único da relação workspace-user';
COMMENT ON COLUMN "HU_Workspace_User"."wkspId" IS 'FK - ID do workspace';
COMMENT ON COLUMN "HU_Workspace_User"."userId" IS 'FK - ID do usuário';
COMMENT ON COLUMN "HU_Workspace_User"."joinedAt" IS 'Data de entrada do usuário no workspace';
COMMENT ON COLUMN "HU_Workspace_User"."isActive" IS 'Status ativo/inativo da relação (soft delete)';
COMMENT ON COLUMN "HU_Workspace_User"."updatedAt" IS 'Data da última atualização do registro';

-- ============================================================================
-- TRIGGERS
-- ============================================================================

-- Função para atualizar automaticamente o updatedAt
CREATE OR REPLACE FUNCTION updateWorkspaceUserUpdatedAt()
RETURNS TRIGGER AS $$
BEGIN
  NEW."updatedAt" = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para atualizar updatedAt em qualquer UPDATE
CREATE TRIGGER "trgUpdateWorkspaceUserUpdatedAt"
  BEFORE UPDATE ON "HU_Workspace_User"
  FOR EACH ROW
  EXECUTE FUNCTION updateWorkspaceUserUpdatedAt();

COMMENT ON FUNCTION updateWorkspaceUserUpdatedAt() IS 'Função trigger para atualizar automaticamente o campo updatedAt';

-- ============================================================================
-- FIM DO SCHEMA
-- ============================================================================

-- RESUMO FINAL:
-- ✅ Tabela: "HU_Workspace_User" (6 campos)
-- ✅ Colunas camelCase: id, "wkspId", "userId", "joinedAt", "isActive", "updatedAt"
-- ✅ Índices camelCase: "idxWkspUserByWkspId", "idxWkspUserByUserId", "idxWkspUserComposite", etc.
-- ✅ FKs: "wkspId" → "HU_Workspace"(id), "userId" → "HU_User"(id) ON DELETE CASCADE
-- ✅ Constraint: unique_workspace_user (previne duplicatas)
-- ✅ Trigger: updateWorkspaceUserUpdatedAt() → Atualiza updatedAt automaticamente
-- ✅ Aspas duplas obrigatórias para preservar camelCase no PostgreSQL
-- ℹ️ Permissões granulares gerenciadas pela tabela Perm_ACL (não incluídas aqui)

-- DOCUMENTAÇÃO:
-- Trigger incluído neste arquivo
-- Permissões: Ver schema-permissions-acl-v2.sql
-- Queries de exemplo: Ver documentação técnica
