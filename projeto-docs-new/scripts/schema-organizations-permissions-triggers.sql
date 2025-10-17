-- ============================================================
-- PERMISSIONS_ACL - TRIGGER DE VALIDAÇÃO POLIMÓRFICA v3.0
-- ============================================================
-- Versão: 3.0
-- Data: 2025-01-15
-- Descrição: Validação de integridade referencial polimórfica
-- Mudanças v3.0: Nomenclatura camelCase com aspas duplas
-- ============================================================
--
-- CONTEÚDO:
--   - Trigger de validação de entityId
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

CREATE OR REPLACE FUNCTION validatePermEntityReference()
RETURNS TRIGGER AS $$
DECLARE
  entity_exists BOOLEAN;
BEGIN
  CASE NEW."entityCode"
    WHEN 'ORG' THEN
      SELECT EXISTS(SELECT 1 FROM "HU_Organization" WHERE id = NEW."entityId") INTO entity_exists;
    WHEN 'WSP' THEN
      SELECT EXISTS(SELECT 1 FROM "HU_Workspace" WHERE id = NEW."entityId") INTO entity_exists;
    WHEN 'CMP' THEN
      SELECT EXISTS(SELECT 1 FROM "HU_Companions" WHERE id = NEW."entityId") INTO entity_exists;
    WHEN 'PRL' THEN
      -- Tabela profiles ainda não implementada
      RAISE WARNING 'Validação profiles pendente (entityId: %)', NEW."entityId";
      entity_exists := TRUE;
    WHEN 'CHT' THEN
      SELECT EXISTS(SELECT 1 FROM "HU_Chats" WHERE id = NEW."entityId") INTO entity_exists;
    WHEN 'KNW' THEN
      SELECT EXISTS(SELECT 1 FROM "HU_Knowledge_RAG" WHERE id = NEW."entityId") INTO entity_exists;
    WHEN 'TOL' THEN
      SELECT EXISTS(SELECT 1 FROM "HU_Tools_MCP" WHERE id = NEW."entityId") INTO entity_exists;
    ELSE
      RAISE EXCEPTION 'Tipo de entidade inválido: %', NEW."entityCode"
        USING ERRCODE = 'invalid_parameter_value';
  END CASE;
  
  IF NOT entity_exists AND NEW."entityCode" != 'PRL' THEN
    RAISE EXCEPTION 'Entidade % com ID % não existe', 
      NEW."entityCode", NEW."entityId"
      USING HINT = 'Verifique se o recurso existe antes de criar permissão',
            ERRCODE = 'foreign_key_violation';
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER "trgValidatePermEntityReference"
  BEFORE INSERT OR UPDATE OF "entityId", "entityCode" ON "HU_Permission_ACL"
  FOR EACH ROW
  EXECUTE FUNCTION validatePermEntityReference();

COMMENT ON FUNCTION validatePermEntityReference() IS 
  'Valida integridade referencial polimórfica para HU_Permission_ACL';

-- ============================================================================
-- FIM DO SCRIPT
-- ============================================================================

-- RESUMO FINAL:
-- ✅ Trigger polimórfico: "trgValidatePermEntityReference"
-- ✅ Função camelCase: validatePermEntityReference()
-- ✅ Valida existência em: HU_Organization, HU_Workspace, HU_Companions, HU_Chats, HU_Knowledge_RAG, HU_Tools_MCP
-- ✅ Tabela: "HU_Permission_ACL"
-- ✅ Colunas: "entityCode", "entityId"
-- ✅ Aspas duplas obrigatórias para preservar camelCase no PostgreSQL
