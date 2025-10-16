-- ============================================================
-- WORKFLOW_STEPS v2.0 - Schema SQL
-- ============================================================
-- Versão: 2.0
-- Data: 2025-01-10
-- Descrição: Passos de workflows agênticos (AI SDK 5.0 compatível)
-- ============================================================

-- ============================================================
-- ENUMS
-- ============================================================

CREATE TYPE step_type_enum AS ENUM (
  'ai_generation',
  'tool_execution',
  'conditional',
  'loop',
  'parallel_group',
  'merge',
  'transform'
);

CREATE TYPE expected_output_type_enum AS ENUM (
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
-- TABELA: workflow_steps
-- ============================================================

CREATE TABLE workflow_steps (
  -- Identificador único
  step_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Relacionamento com workflow
  wkfl_id UUID NOT NULL REFERENCES companion_workflow(wkfl_id) ON DELETE CASCADE,
  
  -- Identificação lógica
  step_step_id VARCHAR(100) NOT NULL,
  step_title VARCHAR(255) NOT NULL,
  step_description TEXT,
  step_order INTEGER NOT NULL,
  
  -- Tipo e classificação
  step_type step_type_enum NOT NULL DEFAULT 'ai_generation',
  
  -- Referências
  skill_id UUID REFERENCES skills(skil_id) ON DELETE SET NULL,
  mcp_mapping_id UUID REFERENCES skill_mcp_mapping(mapping_id) ON DELETE SET NULL,
  step_skill_name VARCHAR(100),
  step_tool_name VARCHAR(100),
  step_custom_prompt TEXT,
  
  -- Atributos JSONB (ai_config, dependencies, conditions, loop_config, output_schema, metadata)
  step_attributes JSONB NOT NULL DEFAULT '{}'::jsonb,
  
  -- Controle de fluxo
  step_is_parallel BOOLEAN NOT NULL DEFAULT FALSE,
  step_timeout_ms INTEGER NOT NULL DEFAULT 30000,
  step_retry_count INTEGER NOT NULL DEFAULT 0,
  step_retry_backoff_ms INTEGER NOT NULL DEFAULT 1000,
  
  -- Transformações
  step_input_transform TEXT,
  step_output_transform TEXT,
  step_expected_output_type expected_output_type_enum NOT NULL DEFAULT 'text',
  
  -- Timestamps
  step_created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  step_updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
  
  -- Constraints
  CONSTRAINT unique_step_id_per_workflow UNIQUE (wkfl_id, step_step_id),
  CONSTRAINT unique_step_order_per_workflow UNIQUE (wkfl_id, step_order),
  CONSTRAINT check_timeout_positive CHECK (step_timeout_ms > 0),
  CONSTRAINT check_retry_count_positive CHECK (step_retry_count >= 0),
  CONSTRAINT check_retry_backoff_positive CHECK (step_retry_backoff_ms >= 0)
);

-- ============================================================
-- ÍNDICES
-- ============================================================

-- Índices para relacionamentos
CREATE INDEX idx_workflowsteps_wkfl ON workflow_steps(wkfl_id);
CREATE INDEX idx_workflowsteps_skill ON workflow_steps(skill_id);
CREATE INDEX idx_workflowsteps_mcp ON workflow_steps(mcp_mapping_id);

-- Índices para tipo e ordem
CREATE INDEX idx_workflowsteps_type ON workflow_steps(step_type);
CREATE INDEX idx_workflowsteps_order ON workflow_steps(wkfl_id, step_order);

-- Índice parcial: apenas steps paralelos
CREATE INDEX idx_workflowsteps_parallel ON workflow_steps(step_is_parallel) 
  WHERE step_is_parallel = TRUE;

-- Índice GIN geral para attributes
CREATE INDEX idx_workflowsteps_attributes_gin ON workflow_steps 
  USING GIN (step_attributes);

-- Índices GIN para consultas específicas em step_attributes
CREATE INDEX idx_workflowsteps_dependencies ON workflow_steps 
  USING GIN ((step_attributes->'dependencies') jsonb_path_ops);
CREATE INDEX idx_workflowsteps_metadata ON workflow_steps 
  USING GIN ((step_attributes->'metadata'));
CREATE INDEX idx_workflowsteps_ai_config ON workflow_steps 
  USING GIN ((step_attributes->'ai_config'));

-- Índice para busca full-text no título
CREATE INDEX idx_workflowsteps_title_fts ON workflow_steps 
  USING GIN (to_tsvector('portuguese', step_title));

-- ============================================================
-- TRIGGER (auto-update updated_at)
-- ============================================================

CREATE OR REPLACE FUNCTION update_step_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.step_updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_step_updated_at
  BEFORE UPDATE ON workflow_steps
  FOR EACH ROW
  EXECUTE FUNCTION update_step_updated_at();

-- ============================================================
-- COMENTÁRIOS DAS COLUNAS
-- ============================================================

COMMENT ON COLUMN workflow_steps.step_id IS 'Identificador único do step (PK)';
COMMENT ON COLUMN workflow_steps.wkfl_id IS 'ID do workflow pai (FK → companion_workflow)';
COMMENT ON COLUMN workflow_steps.step_step_id IS 'Identificador lógico do step (único por workflow)';
COMMENT ON COLUMN workflow_steps.step_title IS 'Título do step exibido na UI';
COMMENT ON COLUMN workflow_steps.step_description IS 'Descrição detalhada do step';
COMMENT ON COLUMN workflow_steps.step_order IS 'Ordem de execução do step no workflow';
COMMENT ON COLUMN workflow_steps.step_type IS 'Tipo do step (ai_generation, tool_execution, conditional, loop, etc.)';
COMMENT ON COLUMN workflow_steps.skill_id IS 'ID da skill vinculada (FK → skills, opcional)';
COMMENT ON COLUMN workflow_steps.mcp_mapping_id IS 'ID do mapeamento MCP (FK → skill_mcp_mapping, opcional)';
COMMENT ON COLUMN workflow_steps.step_skill_name IS 'Nome da skill (redundante para busca sem JOIN)';
COMMENT ON COLUMN workflow_steps.step_tool_name IS 'Nome da ferramenta (redundante para execução sem JOIN)';
COMMENT ON COLUMN workflow_steps.step_custom_prompt IS 'Prompt customizado (alternativa à skill)';
COMMENT ON COLUMN workflow_steps.step_attributes IS 'Atributos JSONB (ai_config, dependencies, conditions, loop_config, output_schema, metadata)';
COMMENT ON COLUMN workflow_steps.step_is_parallel IS 'Indica se o step pode ser executado em paralelo';
COMMENT ON COLUMN workflow_steps.step_timeout_ms IS 'Timeout de execução em milissegundos';
COMMENT ON COLUMN workflow_steps.step_retry_count IS 'Número de tentativas em caso de falha';
COMMENT ON COLUMN workflow_steps.step_retry_backoff_ms IS 'Delay entre tentativas em milissegundos';
COMMENT ON COLUMN workflow_steps.step_input_transform IS 'Código JavaScript para transformar input';
COMMENT ON COLUMN workflow_steps.step_output_transform IS 'Código JavaScript para transformar output';
COMMENT ON COLUMN workflow_steps.step_expected_output_type IS 'Tipo de output esperado (text, json, etc.)';
COMMENT ON COLUMN workflow_steps.step_created_at IS 'Data e hora de criação do step';
COMMENT ON COLUMN workflow_steps.step_updated_at IS 'Data e hora da última atualização (atualizado automaticamente via trigger)';


