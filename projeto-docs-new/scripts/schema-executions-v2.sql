-- ============================================================
-- EXECUTIONS v3.0 - Schema SQL Unificado (camelCase)
-- ============================================================
-- Versão: 3.0
-- Data: 2025-01-15
-- Descrição: Tabela unificada de execuções (Skills + Workflows)
-- Mudanças v3.0: Nomenclatura camelCase com aspas duplas
-- ============================================================

-- ============================================================
-- ENUM: executionType
-- ============================================================

CREATE TYPE "executionType" AS ENUM (
  'SKILL',      -- Execução de uma skill individual
  'WORKFLOW',   -- Execução de um workflow completo
  'STEP'        -- Execução de um step dentro de um workflow
);

COMMENT ON TYPE "executionType" IS 'Tipo de execução: SKILL (skill individual), WORKFLOW (workflow completo), STEP (step de workflow)';

-- ============================================================
-- ENUM: executionStatus
-- ============================================================

CREATE TYPE "executionStatus" AS ENUM (
  'pending',    -- Aguardando início
  'running',    -- Em execução
  'completed',  -- Concluída com sucesso
  'failed',     -- Falhou
  'cancelled',  -- Cancelada pelo usuário
  'paused',     -- Pausada temporariamente
  'timeout'     -- Timeout/expirada
);

COMMENT ON TYPE "executionStatus" IS 'Status da execução';

-- ============================================================
-- TABELA UNIFICADA: Executions
-- ============================================================

CREATE TABLE "HU_Executions" (
  -- Identificadores únicos
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "externalId" VARCHAR(100) UNIQUE,  -- ID legível/rastreável (opcional)
  
  -- Tipo de execução
  "type" "executionType" NOT NULL,
  
  -- Relacionamentos (FKs flexíveis baseados no tipo)
  "skillId" UUID REFERENCES "HU_Skills"(id),           -- NOT NULL se type = 'SKILL'
  "wkflId" UUID REFERENCES "HU_Workflows"(id),         -- NOT NULL se type = 'WORKFLOW'
  "companionId" UUID NOT NULL REFERENCES "HU_Companions"(id),
  "userId" UUID NOT NULL REFERENCES "HU_User"(id),
  "orgId" UUID NOT NULL REFERENCES "HU_Organization"(id),
  
  -- Relacionamento hierárquico (para STEP)
  "parentId" UUID REFERENCES "HU_Executions"(id) ON DELETE CASCADE,  -- Parent workflow
  
  -- Status e controle
  "status" "executionStatus" NOT NULL DEFAULT 'pending',
  "sessionId" VARCHAR(100) NOT NULL,
  "conversationId" VARCHAR(100),
  
  -- Progresso (aplicável a WORKFLOW e STEP)
  "stepOrder" INTEGER,                -- Ordem do step (se STEP)
  "currentStepId" VARCHAR(100),       -- Step atual (se WORKFLOW)
  "currentStepOrder" INTEGER,         -- Ordem do step atual (se WORKFLOW)
  "totalSteps" INTEGER,               -- Total de steps (se WORKFLOW)
  "completedSteps" INTEGER DEFAULT 0, -- Steps concluídos (se WORKFLOW)
  
  -- Temporalidade
  "startedAt" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  "completedAt" TIMESTAMPTZ,
  "durationMs" INTEGER,
  "avgStepDurationMs" REAL,           -- Média por step (se WORKFLOW)
  
  -- Erro
  "errorMessage" TEXT,
  "errorStep" VARCHAR(100),           -- Step que causou erro (se WORKFLOW)
  "errorCode" VARCHAR(50),            -- Código de erro padronizado
  
  -- Debug
  "debugMode" BOOLEAN NOT NULL DEFAULT FALSE,
  "logLevel" VARCHAR(20) NOT NULL DEFAULT 'info',
  
  -- Atributos JSONB (estrutura varia por tipo)
  "attributes" JSONB NOT NULL DEFAULT '{}'::jsonb,
  -- SKILL: { input_data, output_data, metadata }
  -- WORKFLOW: { initial_input, final_output, step_results, execution_config, metadata }
  -- STEP: { input_data, output_data, step_config, metadata }
  
  -- Timestamps
  "createdAt" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  "updatedAt" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  
  -- Constraints de integridade referencial baseadas no tipo
  CONSTRAINT check_skill_fk CHECK (
    ("type" = 'SKILL' AND "skillId" IS NOT NULL) OR 
    ("type" != 'SKILL')
  ),
  CONSTRAINT check_workflow_fk CHECK (
    ("type" IN ('WORKFLOW', 'STEP') AND "wkflId" IS NOT NULL) OR 
    ("type" = 'SKILL')
  ),
  CONSTRAINT check_step_parent CHECK (
    ("type" = 'STEP' AND "parentId" IS NOT NULL) OR 
    ("type" != 'STEP')
  ),
  
  -- Constraints de validação
  CONSTRAINT check_duration_positive CHECK ("durationMs" IS NULL OR "durationMs" >= 0),
  CONSTRAINT check_total_steps_positive CHECK ("totalSteps" IS NULL OR "totalSteps" > 0),
  CONSTRAINT check_completed_steps_range CHECK (
    ("completedSteps" IS NULL) OR 
    ("completedSteps" >= 0 AND "completedSteps" <= COALESCE("totalSteps", "completedSteps"))
  ),
  CONSTRAINT check_step_order_positive CHECK ("stepOrder" IS NULL OR "stepOrder" > 0),
  CONSTRAINT valid_attributes CHECK (jsonb_typeof("attributes") = 'object')
);

-- ============================================================
-- ÍNDICES PRINCIPAIS
-- ============================================================

-- PKs e Unique
CREATE INDEX "idxExecutionsExternalId" ON "HU_Executions"("externalId") WHERE "externalId" IS NOT NULL;

-- Tipo de execução
CREATE INDEX "idxExecutionsType" ON "HU_Executions"("type");
CREATE INDEX "idxExecutionsTypeStatus" ON "HU_Executions"("type", "status");

-- FKs principais
CREATE INDEX "idxExecutionsSkillId" ON "HU_Executions"("skillId") WHERE "skillId" IS NOT NULL;
CREATE INDEX "idxExecutionsWkflId" ON "HU_Executions"("wkflId") WHERE "wkflId" IS NOT NULL;
CREATE INDEX "idxExecutionsCompanionId" ON "HU_Executions"("companionId");
CREATE INDEX "idxExecutionsUserId" ON "HU_Executions"("userId");
CREATE INDEX "idxExecutionsOrgId" ON "HU_Executions"("orgId");
CREATE INDEX "idxExecutionsParentId" ON "HU_Executions"("parentId") WHERE "parentId" IS NOT NULL;
  
-- Status e controle
CREATE INDEX "idxExecutionsStatus" ON "HU_Executions"("status");
CREATE INDEX "idxExecutionsSessionId" ON "HU_Executions"("sessionId");
CREATE INDEX "idxExecutionsConversationId" ON "HU_Executions"("conversationId") WHERE "conversationId" IS NOT NULL;

-- Temporalidade (queries de listagem e analytics)
CREATE INDEX "idxExecutionsStartedAt" ON "HU_Executions"("startedAt" DESC);
CREATE INDEX "idxExecutionsDurationMs" ON "HU_Executions"("durationMs" DESC) WHERE "durationMs" IS NOT NULL;
CREATE INDEX "idxExecutionsCompletedAt" ON "HU_Executions"("completedAt" DESC) WHERE "completedAt" IS NOT NULL;

-- Índices compostos para queries comuns
CREATE INDEX "idxExecutionsOrgTypeStarted" ON "HU_Executions"("orgId", "type", "startedAt" DESC);
CREATE INDEX "idxExecutionsUserStatusStarted" ON "HU_Executions"("userId", "status", "startedAt" DESC);
CREATE INDEX "idxExecutionsCompanionTypeStarted" ON "HU_Executions"("companionId", "type", "startedAt" DESC);

-- Índice parcial para workflows em execução
CREATE INDEX "idxExecutionsRunningWorkflows" ON "HU_Executions"("currentStepOrder", "completedSteps") 
  WHERE "type" = 'WORKFLOW' AND "status" IN ('running', 'paused');

-- Índice parcial para execuções com erro
CREATE INDEX "idxExecutionsErrors" ON "HU_Executions"("errorCode", "startedAt" DESC) 
  WHERE "status" = 'failed' AND "errorCode" IS NOT NULL;

-- ============================================================
-- ÍNDICES JSONB
-- ============================================================

-- Índice GIN geral para attributes
CREATE INDEX "idxExecutionsAttributes" ON "HU_Executions" USING GIN ("attributes");

-- Índices JSONB para consultas específicas por tipo
CREATE INDEX "idxExecutionsSkillOutput" ON "HU_Executions" 
  USING GIN (("attributes"->'output_data')) 
  WHERE "type" = 'SKILL';

CREATE INDEX "idxExecutionsWorkflowResults" ON "HU_Executions" 
  USING GIN (("attributes"->'step_results')) 
  WHERE "type" = 'WORKFLOW';

CREATE INDEX "idxExecutionsMetadata" ON "HU_Executions" 
  USING GIN (("attributes"->'metadata'));

-- ============================================================
-- TRIGGER (auto-update updatedAt)
-- ============================================================

CREATE OR REPLACE FUNCTION updateExecutionUpdatedAt()
RETURNS TRIGGER AS $$
BEGIN
  NEW."updatedAt" = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER "trgUpdateExecutionUpdatedAt"
  BEFORE UPDATE ON "HU_Executions"
  FOR EACH ROW
  EXECUTE FUNCTION updateExecutionUpdatedAt();

-- ============================================================
-- TRIGGER (auto-calculate duration)
-- ============================================================

CREATE OR REPLACE FUNCTION calculateExecutionDuration()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW."completedAt" IS NOT NULL AND NEW."startedAt" IS NOT NULL THEN
    NEW."durationMs" = EXTRACT(EPOCH FROM (NEW."completedAt" - NEW."startedAt")) * 1000;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER "trgCalculateExecutionDuration"
  BEFORE INSERT OR UPDATE OF "completedAt" ON "HU_Executions"
  FOR EACH ROW
  EXECUTE FUNCTION calculateExecutionDuration();

-- ============================================================
-- COMENTÁRIOS DA TABELA
-- ============================================================

COMMENT ON TABLE "HU_Executions" IS 'Tabela unificada de execuções v3.0 (Skills, Workflows, Steps)';

-- PKs e identificadores
COMMENT ON COLUMN "HU_Executions".id IS 'PK - Identificador único da execução';
COMMENT ON COLUMN "HU_Executions"."externalId" IS 'Identificador legível/rastreável (opcional, UNIQUE)';

-- Tipo e status
COMMENT ON COLUMN "HU_Executions"."type" IS 'Tipo de execução: SKILL, WORKFLOW ou STEP';
COMMENT ON COLUMN "HU_Executions"."status" IS 'Status: pending, running, completed, failed, cancelled, paused, timeout';

-- FKs
COMMENT ON COLUMN "HU_Executions"."skillId" IS 'FK - ID da skill → HU_Skills.id (NOT NULL se type = SKILL)';
COMMENT ON COLUMN "HU_Executions"."wkflId" IS 'FK - ID do workflow → HU_Workflows.id (NOT NULL se type = WORKFLOW/STEP)';
COMMENT ON COLUMN "HU_Executions"."companionId" IS 'FK - ID do companion → HU_Companions.id (sempre NOT NULL)';
COMMENT ON COLUMN "HU_Executions"."userId" IS 'FK - ID do usuário → HU_User.id (sempre NOT NULL)';
COMMENT ON COLUMN "HU_Executions"."orgId" IS 'FK - ID da organização → HU_Organization.id (sempre NOT NULL, RLS)';
COMMENT ON COLUMN "HU_Executions"."parentId" IS 'FK - ID da execução pai → HU_Executions.id (NOT NULL se type = STEP)';

-- Controle
COMMENT ON COLUMN "HU_Executions"."sessionId" IS 'ID da sessão de chat';
COMMENT ON COLUMN "HU_Executions"."conversationId" IS 'ID da conversa';

-- Progresso
COMMENT ON COLUMN "HU_Executions"."stepOrder" IS 'Ordem do step (se type = STEP)';
COMMENT ON COLUMN "HU_Executions"."currentStepId" IS 'ID do step atual (se type = WORKFLOW)';
COMMENT ON COLUMN "HU_Executions"."currentStepOrder" IS 'Ordem do step atual (se type = WORKFLOW)';
COMMENT ON COLUMN "HU_Executions"."totalSteps" IS 'Total de steps (se type = WORKFLOW)';
COMMENT ON COLUMN "HU_Executions"."completedSteps" IS 'Steps concluídos (se type = WORKFLOW)';

-- Temporalidade
COMMENT ON COLUMN "HU_Executions"."startedAt" IS 'Data e hora de início da execução';
COMMENT ON COLUMN "HU_Executions"."completedAt" IS 'Data e hora de conclusão';
COMMENT ON COLUMN "HU_Executions"."durationMs" IS 'Duração total em milissegundos (auto-calculado)';
COMMENT ON COLUMN "HU_Executions"."avgStepDurationMs" IS 'Duração média por step (se type = WORKFLOW)';

-- Erro
COMMENT ON COLUMN "HU_Executions"."errorMessage" IS 'Mensagem de erro (se status = failed)';
COMMENT ON COLUMN "HU_Executions"."errorStep" IS 'Step que causou erro (se type = WORKFLOW)';
COMMENT ON COLUMN "HU_Executions"."errorCode" IS 'Código de erro padronizado';

-- Debug
COMMENT ON COLUMN "HU_Executions"."debugMode" IS 'Modo debug ativo';
COMMENT ON COLUMN "HU_Executions"."logLevel" IS 'Nível de log (debug, info, warn, error)';

-- Atributos
COMMENT ON COLUMN "HU_Executions"."attributes" IS 'Atributos JSONB (input_data, output_data, step_results, metadata, config)';

-- Timestamps
COMMENT ON COLUMN "HU_Executions"."createdAt" IS 'Data de criação do registro';
COMMENT ON COLUMN "HU_Executions"."updatedAt" IS 'Data de última atualização (atualizado automaticamente via trigger)';

-- ============================================================================
-- FIM DO SCHEMA
-- ============================================================================

-- RESUMO FINAL:
-- ✅ Tabela: "HU_Executions" (32 campos)
-- ✅ Colunas camelCase: id, "externalId", "type", "status", "skillId", "wkflId", etc.
-- ✅ Índices camelCase: "idxExecutionsType", "idxExecutionsStatus", "idxExecutionsUserId", etc.
-- ✅ ENUMs: "executionType", "executionStatus"
-- ✅ FKs: "skillId" → "HU_Skills"(id), "wkflId" → "HU_Workflows"(id), "companionId" → "HU_Companions"(id), "userId" → "HU_User"(id), etc.
-- ✅ Funções: updateExecutionUpdatedAt(), calculateExecutionDuration()
-- ✅ Triggers: "trgUpdateExecutionUpdatedAt", "trgCalculateExecutionDuration"
-- ✅ Aspas duplas obrigatórias para preservar camelCase no PostgreSQL
