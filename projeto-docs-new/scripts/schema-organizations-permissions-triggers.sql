-- ============================================================
-- PERMISSIONS_ACL - TRIGGER DE VALIDAÇÃO POLIMÓRFICA
-- ============================================================
-- Versão: 2.1
-- Data: 2025-01-13
-- Descrição: Validação de integridade referencial polimórfica
-- ============================================================
--
-- CONTEÚDO:
--   - Trigger de validação de perm_entity_pk_id
--
-- NOTA: Outros triggers (auditoria, validações) devem ser
--       implementados na camada de aplicação (backend)
--
-- Para aplicar:
--   psql -U usuario -d banco -f schema-organizations-permissions-triggers.sql
-- ============================================================

-- ============================================================
-- TRIGGER: Validação de Integridade Referencial Polimórfica
-- ============================================================
-- PostgreSQL não suporta FK condicionais nativamente.
-- Este trigger garante integridade mesmo se API for bypassada.
-- ============================================================

CREATE OR REPLACE FUNCTION validate_perm_entity_reference()
RETURNS TRIGGER AS $$
DECLARE
  entity_exists BOOLEAN;
BEGIN
  CASE NEW.perm_entity_code
    WHEN 'ORG' THEN
      SELECT EXISTS(SELECT 1 FROM organizations WHERE orgs_id = NEW.perm_entity_pk_id) INTO entity_exists;
    WHEN 'WSP' THEN
      SELECT EXISTS(SELECT 1 FROM workspaces WHERE wksp_id = NEW.perm_entity_pk_id) INTO entity_exists;
    WHEN 'CMP' THEN
      SELECT EXISTS(SELECT 1 FROM "NewCompanions" WHERE id = NEW.perm_entity_pk_id) INTO entity_exists;
    WHEN 'PRL' THEN
      -- Tabela profiles ainda não implementada
      RAISE WARNING 'Validação profiles pendente (perm_entity_pk_id: %)', NEW.perm_entity_pk_id;
      entity_exists := TRUE;
    WHEN 'CHT' THEN
      SELECT EXISTS(SELECT 1 FROM chats WHERE chat_id = NEW.perm_entity_pk_id) INTO entity_exists;
    WHEN 'KNW' THEN
      SELECT EXISTS(SELECT 1 FROM knowledge_rag WHERE know_id = NEW.perm_entity_pk_id) INTO entity_exists;
    WHEN 'TOL' THEN
      SELECT EXISTS(SELECT 1 FROM tools_mcp WHERE tool_id = NEW.perm_entity_pk_id) INTO entity_exists;
    ELSE
      RAISE EXCEPTION 'Tipo de entidade inválido: %', NEW.perm_entity_code
        USING ERRCODE = 'invalid_parameter_value';
  END CASE;
  
  IF NOT entity_exists AND NEW.perm_entity_code != 'PRL' THEN
    RAISE EXCEPTION 'Entidade % com ID % não existe', 
      NEW.perm_entity_code, NEW.perm_entity_pk_id
      USING HINT = 'Verifique se o recurso existe antes de criar permissão',
            ERRCODE = 'foreign_key_violation';
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validate_perm_entity_reference
  BEFORE INSERT OR UPDATE OF perm_entity_pk_id, perm_entity_code ON permissions_acl
  FOR EACH ROW
  EXECUTE FUNCTION validate_perm_entity_reference();

COMMENT ON FUNCTION validate_perm_entity_reference() IS 
  'Valida integridade referencial polimórfica para permissions_acl';

-- ============================================================
-- FIM DO SCRIPT
-- ============================================================

