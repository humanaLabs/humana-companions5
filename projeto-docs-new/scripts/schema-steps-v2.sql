-- ============================================================
-- WORKFLOW_STEPS v3.0 - Schema SQL (camelCase)
-- ============================================================
-- Versão: 3.0
-- Data: 2025-01-15
-- Descrição: Passos de workflows agênticos (AI SDK 5.0 compatível)
-- Mudanças v3.0: Nomenclatura camelCase com aspas duplas
-- ============================================================

-- ============================================================
-- ENUMS
-- ============================================================

CREATE TYPE "stepTypeEnum" AS ENUM (
  'ai_generation',
  'tool_execution',
  'conditional',
  'loop',
  'parallel_group',
  'merge',
  'transform'
);

CREATE TYPE "expectedOutputTypeEnum" AS ENUM (
  'text',
  'json',
  'markdown',
  'html',
  'image',
  'audio',
  'video',
  'binary'
);

-- ============================================================
-- TABELA: WorkflowSteps
-- ============================================================

CREATE TABLE "HU_Workflow_Steps" (
  -- Identificador único
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Relacionamento com workflow
  "wkflId" UUID NOT NULL REFERENCES "HU_Companion_Workflow"(id) ON DELETE CASCADE,
  
  -- Identificação lógica
  "stepId" VARCHAR(100) NOT NULL,
  "title" VARCHAR(255) NOT NULL,
  "description" TEXT,
  "order" INTEGER NOT NULL,
  
  -- Tipo e classificação
  "type" "stepTypeEnum" NOT NULL DEFAULT 'ai_generation',
  
  -- Referências
  "skillId" UUID REFERENCES "HU_Skills"(id) ON DELETE SET NULL,
  "mcpMappingId" UUID REFERENCES "HU_Skill_MCP_Mapping"(id) ON DELETE SET NULL,
  "skillName" VARCHAR(100),
  "toolName" VARCHAR(100),
  "customPrompt" TEXT,
  
  -- Atributos JSONB (ai_config, dependencies, conditions, loop_config, output_schema, metadata)
  "attributes" JSONB NOT NULL DEFAULT '{}'::jsonb,
  
  -- Controle de fluxo
  "isParallel" BOOLEAN NOT NULL DEFAULT FALSE,
  "timeoutMs" INTEGER NOT NULL DEFAULT 30000,
  "retryCount" INTEGER NOT NULL DEFAULT 0,
  "retryBackoffMs" INTEGER NOT NULL DEFAULT 1000,
  
  -- Transformações
  "inputTransform" TEXT,
  "outputTransform" TEXT,
  "expectedOutputType" "expectedOutputTypeEnum" NOT NULL DEFAULT 'text',
  
  -- Timestamps
  "createdAt" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  "updatedAt" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  
  -- Constraints
  CONSTRAINT unique_step_id_per_workflow UNIQUE ("wkflId", "stepId"),
  CONSTRAINT unique_step_order_per_workflow UNIQUE ("wkflId", "order"),
  CONSTRAINT check_timeout_positive CHECK ("timeoutMs" > 0),
  CONSTRAINT check_retry_count_positive CHECK ("retryCount" >= 0),
  CONSTRAINT check_retry_backoff_positive CHECK ("retryBackoffMs" >= 0)
);

-- ============================================================
-- ÍNDICES
-- ============================================================

-- Índices para relacionamentos
CREATE INDEX "idxWorkflowStepsWkflId" ON "HU_Workflow_Steps"("wkflId");
CREATE INDEX "idxWorkflowStepsSkillId" ON "HU_Workflow_Steps"("skillId");
CREATE INDEX "idxWorkflowStepsMcpMappingId" ON "HU_Workflow_Steps"("mcpMappingId");

-- Índices para tipo e ordem
CREATE INDEX "idxWorkflowStepsType" ON "HU_Workflow_Steps"("type");
CREATE INDEX "idxWorkflowStepsOrder" ON "HU_Workflow_Steps"("wkflId", "order");

-- Índice parcial: apenas steps paralelos
CREATE INDEX "idxWorkflowStepsParallel" ON "HU_Workflow_Steps"("isParallel") 
  WHERE "isParallel" = TRUE;

-- Índice GIN geral para attributes
CREATE INDEX "idxWorkflowStepsAttributes" ON "HU_Workflow_Steps" 
  USING GIN ("attributes");

-- Índices GIN para consultas específicas em attributes
CREATE INDEX "idxWorkflowStepsDependencies" ON "HU_Workflow_Steps" 
  USING GIN (("attributes"->'dependencies') jsonb_path_ops);
CREATE INDEX "idxWorkflowStepsMetadata" ON "HU_Workflow_Steps" 
  USING GIN (("attributes"->'metadata'));
CREATE INDEX "idxWorkflowStepsAiConfig" ON "HU_Workflow_Steps" 
  USING GIN (("attributes"->'ai_config'));

-- Índice para busca full-text no título
CREATE INDEX "idxWorkflowStepsTitleFts" ON "HU_Workflow_Steps" 
  USING GIN (to_tsvector('portuguese', "title"));

-- ============================================================
-- TRIGGER (auto-update updatedAt)
-- ============================================================

CREATE OR REPLACE FUNCTION updateWorkflowStepUpdatedAt()
RETURNS TRIGGER AS $$
BEGIN
  NEW."updatedAt" = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER "trgUpdateWorkflowStepUpdatedAt"
  BEFORE UPDATE ON "HU_Workflow_Steps"
  FOR EACH ROW
  EXECUTE FUNCTION updateWorkflowStepUpdatedAt();

-- ============================================================
-- COMENTÁRIOS DAS COLUNAS
-- ============================================================

COMMENT ON TABLE "HU_Workflow_Steps" IS 'Tabela de workflow steps v3.0 - Passos de workflows agênticos (AI SDK 5.0)';

COMMENT ON COLUMN "HU_Workflow_Steps".id IS 'PK - Identificador único do step';
COMMENT ON COLUMN "HU_Workflow_Steps"."wkflId" IS 'FK - ID do workflow pai → CompanionWorkflow.id';
COMMENT ON COLUMN "HU_Workflow_Steps"."stepId" IS 'Identificador lógico do step (único por workflow)';
COMMENT ON COLUMN "HU_Workflow_Steps"."title" IS 'Título do step exibido na UI';
COMMENT ON COLUMN "HU_Workflow_Steps"."description" IS 'Descrição detalhada do step';
COMMENT ON COLUMN "HU_Workflow_Steps"."order" IS 'Ordem de execução do step no workflow';
COMMENT ON COLUMN "HU_Workflow_Steps"."type" IS 'Tipo do step (ai_generation, tool_execution, conditional, loop, etc.)';
COMMENT ON COLUMN "HU_Workflow_Steps"."skillId" IS 'FK - ID da skill vinculada → Skills.id (opcional)';
COMMENT ON COLUMN "HU_Workflow_Steps"."mcpMappingId" IS 'FK - ID do mapeamento MCP → SkillMcpMapping.id (opcional)';
COMMENT ON COLUMN "HU_Workflow_Steps"."skillName" IS 'Nome da skill (redundante para busca sem JOIN)';
COMMENT ON COLUMN "HU_Workflow_Steps"."toolName" IS 'Nome da ferramenta (redundante para execução sem JOIN)';
COMMENT ON COLUMN "HU_Workflow_Steps"."customPrompt" IS 'Prompt customizado (alternativa à skill)';
COMMENT ON COLUMN "HU_Workflow_Steps"."attributes" IS 'Atributos JSONB (ai_config, dependencies, conditions, loop_config, output_schema, metadata)';
COMMENT ON COLUMN "HU_Workflow_Steps"."isParallel" IS 'Indica se o step pode ser executado em paralelo';
COMMENT ON COLUMN "HU_Workflow_Steps"."timeoutMs" IS 'Timeout de execução em milissegundos';
COMMENT ON COLUMN "HU_Workflow_Steps"."retryCount" IS 'Número de tentativas em caso de falha';
COMMENT ON COLUMN "HU_Workflow_Steps"."retryBackoffMs" IS 'Delay entre tentativas em milissegundos';
COMMENT ON COLUMN "HU_Workflow_Steps"."inputTransform" IS 'Código JavaScript para transformar input';
COMMENT ON COLUMN "HU_Workflow_Steps"."outputTransform" IS 'Código JavaScript para transformar output';
COMMENT ON COLUMN "HU_Workflow_Steps"."expectedOutputType" IS 'Tipo de output esperado (text, json, etc.)';
COMMENT ON COLUMN "HU_Workflow_Steps"."createdAt" IS 'Data e hora de criação do step';
COMMENT ON COLUMN "HU_Workflow_Steps"."updatedAt" IS 'Data e hora da última atualização (atualizado automaticamente via trigger)';

-- ============================================================================
-- FIM DO SCHEMA
-- ============================================================================

-- RESUMO FINAL:
-- ✅ Tabela: "HU_Workflow_Steps" (22 campos)
-- ✅ Colunas camelCase: id, "wkflId", "stepId", "title", "description", "order", "type", etc.
-- ✅ Índices camelCase: "idxWorkflowStepsWkflId", "idxWorkflowStepsSkillId", etc.
-- ✅ ENUMs: "stepTypeEnum", "expectedOutputTypeEnum"
-- ✅ FKs: "wkflId" → "CompanionWorkflow"(id), "skillId" → "Skills"(id), "mcpMappingId" → "SkillMcpMapping"(id)
-- ✅ Aspas duplas obrigatórias para preservar camelCase no PostgreSQL
