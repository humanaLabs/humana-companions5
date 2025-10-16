-- ============================================================
-- PERMISSIONS_ACL - TRIGGERS ADICIONAIS RECOMENDADOS
-- ============================================================
-- Versão: 2.0
-- Data: 2025-01-10
-- Descrição: Triggers complementares para segurança e integridade
-- Status: RECOMENDADO (não obrigatório)
-- ============================================================

-- ⚠️ NOTA: O arquivo schema-permissions-acl-v2.sql já possui:
--    ✅ trg_permissions_revocation (validação de revogação)
--
-- Este arquivo adiciona 3 triggers complementares para:
--    1. Prevenir modificação de permissões revogadas
--    2. Validar consistência temporal
--    3. Auditoria automática de mudanças
--
-- Para aplicar estes triggers adicionais:
--    psql -U usuario -d banco -f schema-permissions-acl-triggers-adicionais.sql
-- ============================================================

-- ============================================================
-- TRIGGER 2: Prevenir Modificação de Permissão Revogada
-- ============================================================
-- Propósito: SEGURANÇA - Permissão revogada é IMUTÁVEL
-- Importância: CRÍTICA
-- Motivo: Uma vez revogada, a permissão não pode ser "reativada"
--         ou modificada, garantindo integridade da auditoria
-- ============================================================

CREATE OR REPLACE FUNCTION prevent_revoked_permission_update()
RETURNS TRIGGER AS $$
BEGIN
  -- Se permissão já foi revogada, NÃO permitir alterações
  IF OLD.perm_revoked_at IS NOT NULL THEN
    RAISE EXCEPTION 'Permissão revogada não pode ser modificada (perm_id: %)', OLD.perm_id
      USING HINT = 'Crie uma nova permissão ao invés de modificar uma revogada',
            ERRCODE = 'integrity_constraint_violation';
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_prevent_revoked_update
  BEFORE UPDATE ON permissions_acl
  FOR EACH ROW
  WHEN (OLD.perm_revoked_at IS NOT NULL)
  EXECUTE FUNCTION prevent_revoked_permission_update();

COMMENT ON FUNCTION prevent_revoked_permission_update() IS 
  'Impede modificação de permissões revogadas (segurança e auditoria)';

-- ============================================================
-- TRIGGER 3: Validação Temporal Consistente
-- ============================================================
-- Propósito: INTEGRIDADE - Garantir datas lógicas e válidas
-- Importância: ALTA
-- Motivo: Previne erros de lógica temporal que podem causar
--         bugs difíceis de debugar (ex: permissão "expirada" 
--         antes de ser criada)
-- ============================================================

CREATE OR REPLACE FUNCTION validate_perm_temporal_consistency()
RETURNS TRIGGER AS $$
BEGIN
  -- Validar que perm_valid_to seja maior que perm_created_at
  IF NEW.perm_valid_to IS NOT NULL AND NEW.perm_valid_to <= NEW.perm_created_at THEN
    RAISE EXCEPTION 'perm_valid_to (%) deve ser maior que perm_created_at (%)', 
      NEW.perm_valid_to, NEW.perm_created_at
      USING HINT = 'A data de expiração deve ser posterior à data de criação',
            ERRCODE = 'check_violation';
  END IF;
  
  -- Validar que perm_revoked_at seja maior ou igual a perm_created_at
  IF NEW.perm_revoked_at IS NOT NULL AND NEW.perm_revoked_at < NEW.perm_created_at THEN
    RAISE EXCEPTION 'perm_revoked_at (%) não pode ser anterior a perm_created_at (%)', 
      NEW.perm_revoked_at, NEW.perm_created_at
      USING HINT = 'Não é possível revogar uma permissão antes dela ser criada',
            ERRCODE = 'check_violation';
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_perm_temporal_consistency
  BEFORE INSERT OR UPDATE ON permissions_acl
  FOR EACH ROW
  EXECUTE FUNCTION validate_perm_temporal_consistency();

COMMENT ON FUNCTION validate_perm_temporal_consistency() IS 
  'Valida consistência temporal das datas de permissão (perm_valid_to e perm_revoked_at)';

-- ============================================================
-- TRIGGER 4: Auditoria de Mudanças Críticas (OPCIONAL)
-- ============================================================
-- Propósito: COMPLIANCE - Log automático para auditoria
-- Importância: MÉDIA (pode ser substituído por aplicação)
-- Motivo: Gera logs no PostgreSQL para rastreabilidade
--         Útil para compliance (LGPD, GDPR, SOX)
-- ============================================================

CREATE OR REPLACE FUNCTION audit_permission_changes()
RETURNS TRIGGER AS $$
BEGIN
  -- Log para INSERT (nova permissão concedida)
  IF TG_OP = 'INSERT' THEN
    RAISE NOTICE 'AUDIT: Permissão concedida - perm_id: %, entity: %(%), action: %, user: %, org: %',
      NEW.perm_id, NEW.perm_entity_code, NEW.perm_entity_pk_id, 
      NEW.perm_action, NEW.perm_created_for_user_id, NEW.orgs_id;
  END IF;
  
  -- Log para UPDATE (mudança em permissão)
  IF TG_OP = 'UPDATE' THEN
    -- Se foi revogada
    IF OLD.perm_revoked_at IS NULL AND NEW.perm_revoked_at IS NOT NULL THEN
      RAISE WARNING 'AUDIT: Permissão REVOGADA - perm_id: %, user: %, org: %',
        NEW.perm_id, NEW.perm_created_for_user_id, NEW.orgs_id;
    END IF;
    
    -- Se ação foi alterada
    IF OLD.perm_action != NEW.perm_action THEN
      RAISE WARNING 'AUDIT: Ação alterada - perm_id: %, de % para %, user: %',
        NEW.perm_id, OLD.perm_action, NEW.perm_action, NEW.perm_created_for_user_id;
    END IF;
    
    -- Se validade foi alterada
    IF OLD.perm_valid_to IS DISTINCT FROM NEW.perm_valid_to THEN
      RAISE NOTICE 'AUDIT: Validade alterada - perm_id: %, de % para %',
        NEW.perm_id, OLD.perm_valid_to, NEW.perm_valid_to;
    END IF;
  END IF;
  
  -- Log para DELETE (permissão removida - ATENÇÃO!)
  IF TG_OP = 'DELETE' THEN
    RAISE WARNING 'AUDIT: Permissão DELETADA (hard delete) - perm_id: %, user: %, org: %',
      OLD.perm_id, OLD.perm_created_for_user_id, OLD.orgs_id;
    RETURN OLD;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_audit_permission_changes
  AFTER INSERT OR UPDATE OR DELETE ON permissions_acl
  FOR EACH ROW
  EXECUTE FUNCTION audit_permission_changes();

COMMENT ON FUNCTION audit_permission_changes() IS 
  'Log automático de mudanças em permissões para auditoria e compliance';

-- ============================================================
-- VALIDAÇÃO PÓS-INSTALAÇÃO
-- ============================================================

-- Verificar triggers criados
SELECT 
  trigger_name,
  event_manipulation,
  action_timing,
  action_statement
FROM information_schema.triggers
WHERE event_object_table = 'permissions_acl'
ORDER BY trigger_name;

-- ============================================================
-- TESTES RECOMENDADOS
-- ============================================================

-- Teste 1: Prevenir modificação de permissão revogada
-- Deve falhar com erro
/*
INSERT INTO permissions_acl (orgs_id, perm_entity_code, perm_entity_pk_id, perm_action, 
  perm_created_by_user_id, perm_created_for_user_id, perm_revoked_at)
VALUES ('...', 'ORG', '...', 'REA', '...', '...', NOW());

UPDATE permissions_acl SET perm_action = 'WRI' WHERE perm_id = '...';
-- ❌ Deve retornar: ERROR - Permissão revogada não pode ser modificada
*/

-- Teste 2: Validação temporal
-- Deve falhar com erro
/*
INSERT INTO permissions_acl (orgs_id, perm_entity_code, perm_entity_pk_id, perm_action, 
  perm_created_by_user_id, perm_created_for_user_id, perm_created_at, perm_valid_to)
VALUES ('...', 'ORG', '...', 'REA', '...', '...', NOW(), NOW() - INTERVAL '1 day');
-- ❌ Deve retornar: ERROR - perm_valid_to deve ser maior que perm_created_at
*/

-- Teste 3: Auditoria automática
-- Deve gerar NOTICE/WARNING no log
/*
INSERT INTO permissions_acl (orgs_id, perm_entity_code, perm_entity_pk_id, perm_action, 
  perm_created_by_user_id, perm_created_for_user_id)
VALUES ('...', 'ORG', '...', 'REA', '...', '...');
-- ✅ Deve gerar: NOTICE - AUDIT: Permissão concedida...
*/

-- ============================================================
-- DESINSTALAÇÃO (se necessário)
-- ============================================================

/*
-- Para remover os triggers adicionais:
DROP TRIGGER IF EXISTS trg_prevent_revoked_update ON permissions_acl;
DROP TRIGGER IF EXISTS trg_perm_temporal_consistency ON permissions_acl;
DROP TRIGGER IF EXISTS trg_audit_permission_changes ON permissions_acl;

DROP FUNCTION IF EXISTS prevent_revoked_permission_update();
DROP FUNCTION IF EXISTS validate_perm_temporal_consistency();
DROP FUNCTION IF EXISTS audit_permission_changes();
*/

-- ============================================================
-- FIM DO SCRIPT
-- ============================================================

