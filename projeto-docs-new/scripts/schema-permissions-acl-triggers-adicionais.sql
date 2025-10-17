-- ============================================================
-- PERMISSIONS_ACL - TRIGGERS ADICIONAIS RECOMENDADOS v3.0
-- ============================================================
-- Versão: 3.0
-- Data: 2025-01-15
-- Descrição: Triggers complementares para segurança e integridade
-- Status: RECOMENDADO (não obrigatório)
-- Mudanças v3.0: Nomenclatura camelCase com aspas duplas
-- ============================================================

-- ⚠️ NOTA: O arquivo schema-permissions-acl-v2.sql já possui:
--    ✅ Triggers básicos de validação
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
-- TRIGGER 1: Prevenir Modificação de Permissão Revogada
-- ============================================================
-- Propósito: SEGURANÇA - Permissão revogada é IMUTÁVEL
-- Importância: CRÍTICA
-- Motivo: Uma vez revogada, a permissão não pode ser "reativada"
--         ou modificada, garantindo integridade da auditoria
-- ============================================================

CREATE OR REPLACE FUNCTION preventRevokedPermissionUpdate()
RETURNS TRIGGER AS $$
BEGIN
  -- Se permissão já foi revogada, NÃO permitir alterações
  IF OLD."revokedAt" IS NOT NULL THEN
    RAISE EXCEPTION 'Permissão revogada não pode ser modificada (id: %)', OLD.id
      USING HINT = 'Crie uma nova permissão ao invés de modificar uma revogada',
            ERRCODE = 'integrity_constraint_violation';
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER "trgPreventRevokedUpdate"
  BEFORE UPDATE ON "HU_Permission_ACL"
  FOR EACH ROW
  WHEN (OLD."revokedAt" IS NOT NULL)
  EXECUTE FUNCTION preventRevokedPermissionUpdate();

COMMENT ON FUNCTION preventRevokedPermissionUpdate() IS 
  'Impede modificação de permissões revogadas (segurança e auditoria)';

-- ============================================================
-- TRIGGER 2: Validação Temporal Consistente
-- ============================================================
-- Propósito: INTEGRIDADE - Garantir datas lógicas e válidas
-- Importância: ALTA
-- Motivo: Previne erros de lógica temporal que podem causar
--         bugs difíceis de debugar (ex: permissão "expirada" 
--         antes de ser criada)
-- ============================================================

CREATE OR REPLACE FUNCTION validatePermTemporalConsistency()
RETURNS TRIGGER AS $$
BEGIN
  -- Validar que validTo seja maior que createdAt
  IF NEW."validTo" IS NOT NULL AND NEW."validTo" <= NEW."createdAt" THEN
    RAISE EXCEPTION 'validTo (%) deve ser maior que createdAt (%)', 
      NEW."validTo", NEW."createdAt"
      USING HINT = 'A data de expiração deve ser posterior à data de criação',
            ERRCODE = 'check_violation';
  END IF;
  
  -- Validar que revokedAt seja maior ou igual a createdAt
  IF NEW."revokedAt" IS NOT NULL AND NEW."revokedAt" < NEW."createdAt" THEN
    RAISE EXCEPTION 'revokedAt (%) não pode ser anterior a createdAt (%)', 
      NEW."revokedAt", NEW."createdAt"
      USING HINT = 'Não é possível revogar uma permissão antes dela ser criada',
            ERRCODE = 'check_violation';
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER "trgPermTemporalConsistency"
  BEFORE INSERT OR UPDATE ON "HU_Permission_ACL"
  FOR EACH ROW
  EXECUTE FUNCTION validatePermTemporalConsistency();

COMMENT ON FUNCTION validatePermTemporalConsistency() IS 
  'Valida consistência temporal das datas de permissão (validTo e revokedAt)';

-- ============================================================
-- TRIGGER 3: Auditoria de Mudanças Críticas (OPCIONAL)
-- ============================================================
-- Propósito: COMPLIANCE - Log automático para auditoria
-- Importância: MÉDIA (pode ser substituído por aplicação)
-- Motivo: Gera logs no PostgreSQL para rastreabilidade
--         Útil para compliance (LGPD, GDPR, SOX)
-- ============================================================

CREATE OR REPLACE FUNCTION auditPermissionChanges()
RETURNS TRIGGER AS $$
BEGIN
  -- Log para INSERT (nova permissão concedida)
  IF TG_OP = 'INSERT' THEN
    RAISE NOTICE 'AUDIT: Permissão concedida - id: %, entity: %(%), action: %, user: %, org: %',
      NEW.id, NEW."entityCode", NEW."entityId", 
      NEW."action", NEW."createdForUserId", NEW."orgId";
  END IF;
  
  -- Log para UPDATE (revogação de permissão)
  IF TG_OP = 'UPDATE' AND OLD."revokedAt" IS NULL AND NEW."revokedAt" IS NOT NULL THEN
    RAISE NOTICE 'AUDIT: Permissão revogada - id: %, entity: %(%), action: %, user: %, org: %',
      NEW.id, NEW."entityCode", NEW."entityId", 
      NEW."action", NEW."createdForUserId", NEW."orgId";
  END IF;
  
  -- Log para DELETE (remoção física)
  IF TG_OP = 'DELETE' THEN
    RAISE NOTICE 'AUDIT: Permissão deletada (FÍSICO) - id: %, entity: %(%), action: %, user: %, org: %',
      OLD.id, OLD."entityCode", OLD."entityId", 
      OLD."action", OLD."createdForUserId", OLD."orgId";
    RETURN OLD;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER "trgAuditPermChanges"
  AFTER INSERT OR UPDATE OR DELETE ON "HU_Permission_ACL"
  FOR EACH ROW
  EXECUTE FUNCTION auditPermissionChanges();

COMMENT ON FUNCTION auditPermissionChanges() IS 
  'Gera logs de auditoria para mudanças críticas em permissões (INSERT, UPDATE de revogação, DELETE)';

-- ============================================================================
-- FIM DOS TRIGGERS ADICIONAIS
-- ============================================================================

-- RESUMO FINAL:
-- ✅ 3 Triggers Adicionais para "HU_Permission_ACL"
-- ✅ Funções camelCase: preventRevokedPermissionUpdate, validatePermTemporalConsistency, auditPermissionChanges
-- ✅ Triggers camelCase: "trgPreventRevokedUpdate", "trgPermTemporalConsistency", "trgAuditPermChanges"
-- ✅ Colunas camelCase: "revokedAt", "createdAt", "validTo", "entityCode", "entityId", "action", "createdForUserId", "orgId"
-- ✅ Tabela: "HU_Permission_ACL"
-- ✅ Aspas duplas obrigatórias para preservar camelCase no PostgreSQL

-- DOCUMENTAÇÃO:
-- Para mais informações, consulte: projeto-docs-new/tabelas/ANALISE-TABELA-PERMISSIONS-ACL.md
