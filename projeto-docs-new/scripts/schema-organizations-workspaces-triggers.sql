-- ============================================================
-- TRIGGERS: HU_Organization → HU_Workspace | User → HU_Workspace (camelCase)
-- ============================================================
-- Versão: 3.0
-- Data: 2025-01-15
-- Descrição: Triggers para criação automática de workspaces com nomenclatura camelCase
--            1. Workspace organizacional padrão para nova organização
--            2. Workspace pessoal para novo usuário
-- ============================================================

-- ============================================================
-- FUNÇÃO: Criar Workspace Organizacional para Nova Organização
-- ============================================================

CREATE OR REPLACE FUNCTION createDefaultWorkspaceForOrg()
RETURNS TRIGGER AS $$
BEGIN
  -- Insere workspace organizacional automaticamente
  INSERT INTO "HU_Workspace" (
    "orgId",
    "name",
    "type",
    "isDefault",
    "isActive"
  ) VALUES (
    NEW.id,
    'Workspace ' || NEW."name",
    'ORGANIZATIONAL'::"workspaceTypeEnum",
    TRUE,
    TRUE
  );
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================================
-- TRIGGER: Criar Workspace Após Insert em HU_Organization
-- ============================================================

CREATE TRIGGER "trgCreateDefaultWorkspace"
  AFTER INSERT ON "HU_Organization"
  FOR EACH ROW
  EXECUTE FUNCTION createDefaultWorkspaceForOrg();

-- ============================================================
-- COMENTÁRIOS
-- ============================================================

COMMENT ON FUNCTION createDefaultWorkspaceForOrg() IS 
  'Função trigger que cria automaticamente um workspace organizacional quando uma nova organização é inserida';

COMMENT ON TRIGGER "trgCreateDefaultWorkspace" ON "HU_Organization" IS 
  'Trigger que executa após INSERT em HU_Organization para criar workspace padrão do tipo ORGANIZATIONAL';


-- ============================================================
-- FUNÇÃO: Criar Workspace Pessoal para Novo Usuário
-- ============================================================

CREATE OR REPLACE FUNCTION createPersonalWorkspaceForUser()
RETURNS TRIGGER AS $$
DECLARE
  v_personal_workspace_id UUID;
BEGIN
  -- Insere workspace pessoal automaticamente
  INSERT INTO "HU_Workspace" (
    "orgId",
    "name",
    "type",
    "isDefault",
    "isActive"
  ) VALUES (
    NEW."orgId",
    'My Workspace - ' || COALESCE(NEW."name", NEW.email),
    'PERSONAL'::"workspaceTypeEnum",
    FALSE,
    TRUE
  )
  RETURNING id INTO v_personal_workspace_id;
  
  -- Log de sucesso
  RAISE NOTICE 'Workspace pessoal criado com ID % para o usuário %', v_personal_workspace_id, NEW.id;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================================
-- TRIGGER: Criar Workspace Após Insert em User
-- ============================================================

CREATE TRIGGER "trgCreatePersonalWorkspace"
  AFTER INSERT ON "HU_User"
  FOR EACH ROW
  EXECUTE FUNCTION createPersonalWorkspaceForUser();

-- ============================================================
-- COMENTÁRIOS
-- ============================================================

COMMENT ON FUNCTION createPersonalWorkspaceForUser() IS 
  'Função trigger que cria automaticamente um workspace pessoal quando um novo usuário é inserido';

COMMENT ON TRIGGER "trgCreatePersonalWorkspace" ON "HU_User" IS 
  'Trigger que executa após INSERT em HU_User para criar workspace pessoal do tipo PERSONAL';

-- ============================================================================
-- FIM DOS TRIGGERS
-- ============================================================================

-- RESUMO FINAL:
-- ✅ Funções camelCase: createDefaultWorkspaceForOrg(), createPersonalWorkspaceForUser()
-- ✅ Triggers camelCase: "trgCreateDefaultWorkspace", "trgCreatePersonalWorkspace"
-- ✅ Tabelas atualizadas: "HU_Organization", "HU_User", "HU_Workspace"
-- ✅ Colunas camelCase: NEW.id, NEW."name", NEW."orgId", NEW.email
-- ✅ ENUM: "workspaceTypeEnum" (ORGANIZATIONAL, PERSONAL)
-- ✅ Aspas duplas obrigatórias para preservar camelCase no PostgreSQL

-- DOCUMENTAÇÃO:
-- Schema principal: projeto-docs-new/scripts/schema-organizations-v2.sql
-- Schema principal: projeto-docs-new/scripts/schema-users-v2.sql
-- Schema principal: projeto-docs-new/scripts/schema-workspaces-v2.sql

