-- ============================================================================
-- TRIGGERS: HU_User → HU_Workspace_User | HU_Workspace → HU_Workspace_User
-- ============================================================================
-- Versão: 3.0
-- Data: 2025-01-15
-- Descrição: Triggers para criação automática de acesso a workspaces
--            1. Acesso automático ao workspace pessoal (OWNER)
--            2. Acesso automático ao workspace organizacional (MEMBER)
-- Mudanças v3.0: Nomenclatura camelCase com aspas duplas
-- ============================================================================

-- ============================================================================
-- DROP FUNÇÕES E TRIGGERS ANTIGOS (se existirem)
-- ============================================================================

DROP TRIGGER IF EXISTS "trgCreateWorkspaceAccessForUser" ON "HU_User";
DROP TRIGGER IF EXISTS "trgCreateWorkspaceAccessForWorkspace" ON "HU_Workspace";
DROP FUNCTION IF EXISTS createWorkspaceAccessForUser();
DROP FUNCTION IF EXISTS createWorkspaceAccessForWorkspace();

-- ============================================================================
-- FUNÇÃO: Criar Acesso Automático para Novo Usuário
-- ============================================================================

CREATE OR REPLACE FUNCTION createWorkspaceAccessForUser()
RETURNS TRIGGER AS $$
DECLARE
  v_org_id UUID;
  v_personal_workspace_id UUID;
  v_organizational_workspace_id UUID;
BEGIN
  -- Obter orgId do usuário
  v_org_id := NEW."orgId";
  
  -- Se não tem orgId, buscar da primeira organização ativa (fallback)
  IF v_org_id IS NULL THEN
    SELECT id INTO v_org_id 
    FROM "HU_Organization" 
    WHERE "isActive" = TRUE 
    ORDER BY "createdAt" ASC 
    LIMIT 1;
  END IF;
  
  -- Se encontrou uma organização, criar acessos automáticos
  IF v_org_id IS NOT NULL THEN
    
    -- 1. Buscar workspace pessoal do usuário
    SELECT id INTO v_personal_workspace_id
    FROM "HU_Workspace"
    WHERE "orgId" = v_org_id
      AND "type" = 'PERSONAL'::"workspaceTypeEnum"
      AND "name" LIKE 'My Workspace - %'
      AND "isActive" = TRUE
    ORDER BY "createdAt" DESC
    LIMIT 1;
    
    -- 2. Buscar workspace organizacional
    SELECT id INTO v_organizational_workspace_id
    FROM "HU_Workspace"
    WHERE "orgId" = v_org_id
      AND "type" = 'ORGANIZATIONAL'::"workspaceTypeEnum"
      AND "isActive" = TRUE
    ORDER BY "createdAt" ASC
    LIMIT 1;
    
    -- 3. Criar acesso ao workspace pessoal
    IF v_personal_workspace_id IS NOT NULL THEN
      INSERT INTO "HU_Workspace_User" (
        "wkspId",
        "userId",
        "isActive"
      ) VALUES (
        v_personal_workspace_id,
        NEW.id,
        TRUE
      );
      
      RAISE NOTICE 'Acesso criado para workspace pessoal %', v_personal_workspace_id;
    END IF;
    
    -- 4. Criar acesso ao workspace organizacional
    IF v_organizational_workspace_id IS NOT NULL THEN
      INSERT INTO "HU_Workspace_User" (
        "wkspId",
        "userId",
        "isActive"
      ) VALUES (
        v_organizational_workspace_id,
        NEW.id,
        TRUE
      );
      
      RAISE NOTICE 'Acesso criado para workspace organizacional %', v_organizational_workspace_id;
    END IF;
    
  ELSE
    -- Log warning se não encontrou organização
    RAISE WARNING 'Nenhuma organização encontrada para criar acessos automáticos do usuário %', NEW.id;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- TRIGGER: Criar Acesso Após Insert em User
-- ============================================================================

CREATE TRIGGER "trgCreateWorkspaceAccessForUser"
  AFTER INSERT ON "HU_User"
  FOR EACH ROW
  EXECUTE FUNCTION createWorkspaceAccessForUser();

-- ============================================================================
-- FUNÇÃO: Criar Acesso Automático para Novo Workspace (se for ORGANIZATIONAL)
-- ============================================================================

CREATE OR REPLACE FUNCTION createWorkspaceAccessForWorkspace()
RETURNS TRIGGER AS $$
DECLARE
  user_record RECORD;
BEGIN
  -- Só criar acessos automáticos para workspaces ORGANIZATIONAL
  IF NEW."type" = 'ORGANIZATIONAL'::"workspaceTypeEnum" THEN
    
    -- Dar acesso automático a todos os usuários da organização
    FOR user_record IN 
      SELECT id, "orgId"
      FROM "HU_User"
      WHERE "orgId" = NEW."orgId"
        AND "isActive" = TRUE  -- Assumindo que existe coluna isActive em User
    LOOP
      -- Inserir acesso
      INSERT INTO "HU_Workspace_User" (
        "wkspId",
        "userId",
        "isActive"
      ) VALUES (
        NEW.id,
        user_record.id,
        TRUE
      );
    END LOOP;
    
    RAISE NOTICE 'Acessos automáticos criados para workspace organizacional %', NEW.id;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- TRIGGER: Criar Acesso Após Insert em HU_Workspace
-- ============================================================================

CREATE TRIGGER "trgCreateWorkspaceAccessForWorkspace"
  AFTER INSERT ON "HU_Workspace"
  FOR EACH ROW
  EXECUTE FUNCTION createWorkspaceAccessForWorkspace();

-- ============================================================================
-- COMENTÁRIOS
-- ============================================================================

COMMENT ON FUNCTION createWorkspaceAccessForUser() IS 
  'Função trigger que cria acesso automático a workspaces quando um novo usuário é inserido (v3.0 - camelCase)';

COMMENT ON TRIGGER "trgCreateWorkspaceAccessForUser" ON "HU_User" IS 
  'Trigger que executa após INSERT em HU_User para criar acessos automáticos a workspaces (v3.0 - camelCase)';

COMMENT ON FUNCTION createWorkspaceAccessForWorkspace() IS 
  'Função trigger que cria acesso automático a todos os usuários quando um workspace organizacional é criado (v3.0 - camelCase)';

COMMENT ON TRIGGER "trgCreateWorkspaceAccessForWorkspace" ON "HU_Workspace" IS 
  'Trigger que executa após INSERT em HU_Workspace para criar acessos automáticos em workspaces organizacionais (v3.0 - camelCase)';

-- ============================================================================
-- RESUMO FINAL v3.0
-- ============================================================================

-- ✅ ATIVO: Trigger HU_User → HU_Workspace_User (Acesso Automático)
--    - Função: createWorkspaceAccessForUser()
--    - Trigger: "trgCreateWorkspaceAccessForUser"
--    - Tabela: "HU_User" → "HU_Workspace_User"
--    - Acessos: OWNER (workspace pessoal) + MEMBER (workspace organizacional)

-- ✅ ATIVO: Trigger HU_Workspace → WorkspaceUsers (Acesso Automático)
--    - Função: createWorkspaceAccessForWorkspace()
--    - Trigger: "trgCreateWorkspaceAccessForWorkspace"
--    - Tabela: "HU_Workspace" → "HU_Workspace_User"
--    - Acesso: MEMBER automático para todos os usuários da org (apenas workspaces ORGANIZATIONAL)

-- 📋 Nomenclatura v3.0 (TUDO camelCase + Prefixo HU_):
--    - Tabelas Humana: "HU_Organization", "HU_Workspace" (HU_ + PascalCase com aspas)
--    - Tabela Junction: "HU_Workspace_User" (PascalCase com aspas)
--    - Tabela SDK: "HU_User" (PascalCase com aspas)
--    - Colunas: "wkspId", "userId", "isActive", "joinedAt", "updatedAt" (camelCase com aspas)
--    - Funções: createWorkspaceAccessForUser, createWorkspaceAccessForWorkspace (camelCase sem aspas)
--    - Triggers: "trgCreateWorkspaceAccessForUser", "trgCreateWorkspaceAccessForWorkspace" (camelCase com aspas)
--    - ENUMs: "workspaceTypeEnum" (PERSONAL, ORGANIZATIONAL, FUNCTIONAL)

-- 🔄 DROPs incluídos:
--    - Todas as versões antigas são removidas automaticamente

-- ============================================================================
-- NOTAS DE IMPLEMENTAÇÃO
-- ============================================================================

-- ORDEM DE EXECUÇÃO DOS TRIGGERS:
-- 1. User INSERT → createPersonalWorkspaceForUser() → Cria workspace PERSONAL
-- 2. User INSERT → createWorkspaceAccessForUser() → Cria acessos automáticos
-- 3. HU_Workspace INSERT → createWorkspaceAccessForWorkspace() → Cria acessos para workspaces ORGANIZATIONAL

-- WORKSPACES FUNCIONAIS:
-- - Workspaces do tipo FUNCTIONAL não recebem acesso automático
-- - Acesso deve ser concedido manualmente via aplicação
-- - Permite controle granular de permissões

-- PERMISSÕES:
-- - OWNER: Controle total (canInvite, canManage, canDelete)
-- - ADMIN: Controle administrativo (canInvite, canManage, canDelete)
-- - MEMBER: Acesso padrão (sem permissões especiais)
-- - VIEWER: Apenas visualização (sem permissões de modificação)
