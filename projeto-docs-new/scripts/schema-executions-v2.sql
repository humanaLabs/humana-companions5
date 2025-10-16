-- ============================================================
-- EXECUTIONS v2.0 - Schema SQL Unificado
-- ============================================================
-- Versão: 2.0
-- Data: 2025-01-10
-- Descrição: Tabela unificada de execuções (Skills + Workflows)
-- Convenção: Nomenclatura v2.0 (prefixo execution_)
-- ============================================================

-- ============================================================
-- ENUM: execution_type
-- ============================================================

CREATE TYPE execution_type AS ENUM (
  'SKILL',      -- Execução de uma skill individual
  'WORKFLOW',   -- Execução de um workflow completo
  'STEP'        -- Execução de um step dentro de um workflow
);

COMMENT ON TYPE execution_type IS 'Tipo de execução: SKILL (skill individual), WORKFLOW (workflow completo), STEP (step de workflow)';

-- ============================================================
-- ENUM: execution_status
-- ============================================================

CREATE TYPE execution_status AS ENUM (
  'pending',    -- Aguardando início
  'running',    -- Em execução
  'completed',  -- Concluída com sucesso
  'failed',     -- Falhou
  'cancelled',  -- Cancelada pelo usuário
  'paused',     -- Pausada temporariamente
  'timeout'     -- Timeout/expirada
);

COMMENT ON TYPE execution_status IS 'Status da execução';

-- ============================================================
-- TABELA UNIFICADA: executions
-- ============================================================

CREATE TABLE executions (
  -- Identificadores únicos
  exec_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  exec_external_id VARCHAR(100) UNIQUE,  -- ID legível/rastreável (opcional)
  
  -- Tipo de execução
  exec_type execution_type NOT NULL,
  
  -- Relacionamentos (FKs flexíveis baseados no tipo)
  skill_id UUID REFERENCES skills(skil_id),           -- NOT NULL se exec_type = 'SKILL'
  wkfl_id UUID REFERENCES workflows(wkfl_id),   -- NOT NULL se exec_type = 'WORKFLOW'
  companion_id UUID NOT NULL REFERENCES companions(companion_id),
  user_id UUID NOT NULL REFERENCES users(user_id),
  organization_id UUID NOT NULL REFERENCES organizations(organization_id),
  
  -- Relacionamento hierárquico (para STEP)
  exec_parent_id UUID REFERENCES executions(exec_id) ON DELETE CASCADE,  -- Parent workflow
  
  -- Status e controle
  exec_status execution_status NOT NULL DEFAULT 'pending',
  exec_session_id VARCHAR(100) NOT NULL,
  exec_conversation_id VARCHAR(100),
  
  -- Progresso (aplicável a WORKFLOW e STEP)
  exec_step_order INTEGER,                -- Ordem do step (se STEP)
  exec_current_step_id VARCHAR(100),      -- Step atual (se WORKFLOW)
  exec_current_step_order INTEGER,        -- Ordem do step atual (se WORKFLOW)
  exec_total_steps INTEGER,               -- Total de steps (se WORKFLOW)
  exec_completed_steps INTEGER DEFAULT 0, -- Steps concluídos (se WORKFLOW)
  
  -- Temporalidade
  exec_started_at TIMESTAMP NOT NULL DEFAULT NOW(),
  exec_completed_at TIMESTAMP,
  exec_duration_ms INTEGER,
  exec_avg_step_duration_ms REAL,         -- Média por step (se WORKFLOW)
  
  -- Erro
  exec_error_message TEXT,
  exec_error_step VARCHAR(100),           -- Step que causou erro (se WORKFLOW)
  exec_error_code VARCHAR(50),            -- Código de erro padronizado
  
  -- Debug
  exec_debug_mode BOOLEAN NOT NULL DEFAULT FALSE,
  exec_log_level VARCHAR(20) NOT NULL DEFAULT 'info',
  
  -- Atributos JSONB (estrutura varia por tipo)
  exec_attributes JSONB NOT NULL DEFAULT '{}'::jsonb,
  -- SKILL: { input_data, output_data, metadata }
  -- WORKFLOW: { initial_input, final_output, step_results, execution_config, metadata }
  -- STEP: { input_data, output_data, step_config, metadata }
  
  -- Timestamps
  exec_created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  exec_updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
  
  -- Constraints de integridade referencial baseadas no tipo
  CONSTRAINT check_skill_fk CHECK (
    (exec_type = 'SKILL' AND skill_id IS NOT NULL) OR 
    (exec_type != 'SKILL')
  ),
  CONSTRAINT check_workflow_fk CHECK (
    (exec_type IN ('WORKFLOW', 'STEP') AND wkfl_id IS NOT NULL) OR 
    (exec_type = 'SKILL')
  ),
  CONSTRAINT check_step_parent CHECK (
    (exec_type = 'STEP' AND exec_parent_id IS NOT NULL) OR 
    (exec_type != 'STEP')
  ),
  
  -- Constraints de validação
  CONSTRAINT check_duration_positive CHECK (exec_duration_ms IS NULL OR exec_duration_ms >= 0),
  CONSTRAINT check_total_steps_positive CHECK (exec_total_steps IS NULL OR exec_total_steps > 0),
  CONSTRAINT check_completed_steps_range CHECK (
    (exec_completed_steps IS NULL) OR 
    (exec_completed_steps >= 0 AND exec_completed_steps <= COALESCE(exec_total_steps, exec_completed_steps))
  ),
  CONSTRAINT check_step_order_positive CHECK (exec_step_order IS NULL OR exec_step_order > 0),
  CONSTRAINT valid_attributes CHECK (jsonb_typeof(exec_attributes) = 'object')
);

-- ============================================================
-- ÍNDICES PRINCIPAIS
-- ============================================================

-- PKs e Unique
CREATE INDEX idx_exec_external_id ON executions(exec_external_id) WHERE exec_external_id IS NOT NULL;

-- Tipo de execução
CREATE INDEX idx_exec_type ON executions(exec_type);
CREATE INDEX idx_exec_type_status ON executions(exec_type, exec_status);

-- FKs principais
CREATE INDEX idx_exec_skill ON executions(skill_id) WHERE skill_id IS NOT NULL;
CREATE INDEX idx_exec_wkfl ON executions(wkfl_id) WHERE wkfl_id IS NOT NULL;
CREATE INDEX idx_exec_companion ON executions(companion_id);
CREATE INDEX idx_exec_user ON executions(user_id);
CREATE INDEX idx_exec_org ON executions(organization_id);
CREATE INDEX idx_exec_parent ON executions(exec_parent_id) WHERE exec_parent_id IS NOT NULL;
  
  -- Status e controle
CREATE INDEX idx_exec_status ON executions(exec_status);
CREATE INDEX idx_exec_session ON executions(exec_session_id);
CREATE INDEX idx_exec_conversation ON executions(exec_conversation_id) WHERE exec_conversation_id IS NOT NULL;

-- Temporalidade (queries de listagem e analytics)
CREATE INDEX idx_exec_started ON executions(exec_started_at DESC);
CREATE INDEX idx_exec_duration ON executions(exec_duration_ms DESC) WHERE exec_duration_ms IS NOT NULL;
CREATE INDEX idx_exec_completed ON executions(exec_completed_at DESC) WHERE exec_completed_at IS NOT NULL;

-- Índices compostos para queries comuns
CREATE INDEX idx_exec_org_type_started ON executions(organization_id, exec_type, exec_started_at DESC);
CREATE INDEX idx_exec_user_status_started ON executions(user_id, exec_status, exec_started_at DESC);
CREATE INDEX idx_exec_companion_type_started ON executions(companion_id, exec_type, exec_started_at DESC);

-- Índice parcial para workflows em execução
CREATE INDEX idx_exec_running_workflows ON executions(exec_current_step_order, exec_completed_steps) 
  WHERE exec_type = 'WORKFLOW' AND exec_status IN ('running', 'paused');

-- Índice parcial para execuções com erro
CREATE INDEX idx_exec_errors ON executions(exec_error_code, exec_started_at DESC) 
  WHERE exec_status = 'failed' AND exec_error_code IS NOT NULL;

-- ============================================================
-- ÍNDICES JSONB
-- ============================================================

-- Índice GIN geral para attributes
CREATE INDEX idx_exec_attributes_gin ON executions USING GIN (exec_attributes);

-- Índices JSONB para consultas específicas por tipo
CREATE INDEX idx_exec_skill_output ON executions 
  USING GIN ((exec_attributes->'output_data')) 
  WHERE exec_type = 'SKILL';

CREATE INDEX idx_exec_workflow_results ON executions 
  USING GIN ((exec_attributes->'step_results')) 
  WHERE exec_type = 'WORKFLOW';

CREATE INDEX idx_exec_metadata ON executions 
  USING GIN ((exec_attributes->'metadata'));

-- ============================================================
-- TRIGGER (auto-update updated_at)
-- ============================================================

CREATE OR REPLACE FUNCTION update_exec_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.exec_updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_exec_updated_at
  BEFORE UPDATE ON executions
  FOR EACH ROW
  EXECUTE FUNCTION update_exec_updated_at();

-- ============================================================
-- TRIGGER (auto-calculate duration)
-- ============================================================

CREATE OR REPLACE FUNCTION calculate_exec_duration()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.exec_completed_at IS NOT NULL AND NEW.exec_started_at IS NOT NULL THEN
    NEW.exec_duration_ms = EXTRACT(EPOCH FROM (NEW.exec_completed_at - NEW.exec_started_at)) * 1000;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_exec_duration
  BEFORE INSERT OR UPDATE OF exec_completed_at ON executions
  FOR EACH ROW
  EXECUTE FUNCTION calculate_exec_duration();

-- ============================================================
-- COMENTÁRIOS DA TABELA
-- ============================================================

COMMENT ON TABLE executions IS 'Tabela unificada de execuções (Skills, Workflows, Steps)';

-- PKs e identificadores
COMMENT ON COLUMN executions.exec_id IS 'Identificador único da execução (PK UUID)';
COMMENT ON COLUMN executions.exec_external_id IS 'Identificador legível/rastreável (opcional, UNIQUE)';

-- Tipo e status
COMMENT ON COLUMN executions.exec_type IS 'Tipo de execução: SKILL, WORKFLOW ou STEP';
COMMENT ON COLUMN executions.exec_status IS 'Status: pending, running, completed, failed, cancelled, paused, timeout';

-- FKs
COMMENT ON COLUMN executions.skill_id IS 'ID da skill (FK → skills, NOT NULL se exec_type = SKILL)';
COMMENT ON COLUMN executions.wkfl_id IS 'ID do workflow (FK → workflows, NOT NULL se exec_type = WORKFLOW/STEP)';
COMMENT ON COLUMN executions.companion_id IS 'ID do companion (FK → companions, sempre NOT NULL)';
COMMENT ON COLUMN executions.user_id IS 'ID do usuário (FK → users, sempre NOT NULL)';
COMMENT ON COLUMN executions.organization_id IS 'ID da organização (FK → organizations, sempre NOT NULL, RLS)';
COMMENT ON COLUMN executions.exec_parent_id IS 'ID da execução pai (FK → executions, NOT NULL se exec_type = STEP)';

-- Controle
COMMENT ON COLUMN executions.exec_session_id IS 'ID da sessão de chat';
COMMENT ON COLUMN executions.exec_conversation_id IS 'ID da conversa';

-- Progresso
COMMENT ON COLUMN executions.exec_step_order IS 'Ordem do step (se exec_type = STEP)';
COMMENT ON COLUMN executions.exec_current_step_id IS 'ID do step atual (se exec_type = WORKFLOW)';
COMMENT ON COLUMN executions.exec_current_step_order IS 'Ordem do step atual (se exec_type = WORKFLOW)';
COMMENT ON COLUMN executions.exec_total_steps IS 'Total de steps (se exec_type = WORKFLOW)';
COMMENT ON COLUMN executions.exec_completed_steps IS 'Steps concluídos (se exec_type = WORKFLOW)';

-- Temporalidade
COMMENT ON COLUMN executions.exec_started_at IS 'Data e hora de início';
COMMENT ON COLUMN executions.exec_completed_at IS 'Data e hora de conclusão';
COMMENT ON COLUMN executions.exec_duration_ms IS 'Duração em milissegundos (calculado automaticamente via trigger)';
COMMENT ON COLUMN executions.exec_avg_step_duration_ms IS 'Duração média por step (se exec_type = WORKFLOW)';

-- Erro
COMMENT ON COLUMN executions.exec_error_message IS 'Mensagem de erro (se failed)';
COMMENT ON COLUMN executions.exec_error_step IS 'ID do step que causou erro (se exec_type = WORKFLOW)';
COMMENT ON COLUMN executions.exec_error_code IS 'Código de erro padronizado (ex: TIMEOUT, VALIDATION_ERROR)';

-- Debug
COMMENT ON COLUMN executions.exec_debug_mode IS 'Indica se está em modo debug';
COMMENT ON COLUMN executions.exec_log_level IS 'Nível de log: info, debug, error';

-- JSONB
COMMENT ON COLUMN executions.exec_attributes IS 'Atributos JSONB - estrutura varia por tipo: SKILL {input_data, output_data, metadata}, WORKFLOW {initial_input, final_output, step_results, execution_config, metadata}, STEP {input_data, output_data, step_config, metadata}';

-- Timestamps
COMMENT ON COLUMN executions.exec_created_at IS 'Data e hora de criação';
COMMENT ON COLUMN executions.exec_updated_at IS 'Data e hora da última atualização (atualizado automaticamente via trigger)';

-- ============================================================
-- VIEWS ÚTEIS
-- ============================================================

-- View para execuções de Skills
CREATE OR REPLACE VIEW skill_executions AS
SELECT 
  exec_id,
  exec_external_id,
  skill_id,
  companion_id,
  user_id,
  organization_id,
  exec_status,
  exec_session_id,
  exec_conversation_id,
  exec_step_order,
  exec_started_at,
  exec_completed_at,
  exec_duration_ms,
  exec_error_message,
  exec_error_code,
  exec_attributes,
  exec_created_at
FROM executions
WHERE exec_type = 'SKILL';

COMMENT ON VIEW skill_executions IS 'View filtrada para execuções de Skills';

-- View para execuções de Workflows
CREATE OR REPLACE VIEW workflow_executions AS
SELECT 
  exec_id,
  exec_external_id,
  wkfl_id,
  companion_id,
  user_id,
  organization_id,
  exec_status,
  exec_session_id,
  exec_conversation_id,
  exec_current_step_id,
  exec_current_step_order,
  exec_total_steps,
  exec_completed_steps,
  exec_started_at,
  exec_completed_at,
  exec_duration_ms,
  exec_avg_step_duration_ms,
  exec_error_message,
  exec_error_step,
  exec_error_code,
  exec_debug_mode,
  exec_log_level,
  exec_attributes,
  exec_created_at,
  exec_updated_at
FROM executions
WHERE exec_type = 'WORKFLOW';

COMMENT ON VIEW workflow_executions IS 'View filtrada para execuções de Workflows';

-- View para execuções de Steps
CREATE OR REPLACE VIEW step_executions AS
SELECT 
  exec_id,
  exec_parent_id AS workflow_exec_id,
  wkfl_id,
  companion_id,
  user_id,
  organization_id,
  exec_step_order,
  exec_status,
  exec_started_at,
  exec_completed_at,
  exec_duration_ms,
  exec_error_message,
  exec_error_code,
  exec_attributes,
  exec_created_at
FROM executions
WHERE exec_type = 'STEP';

COMMENT ON VIEW step_executions IS 'View filtrada para execuções de Steps';

-- ============================================================
-- EXEMPLOS DE QUERIES
-- ============================================================

/*
-- Inserir execução de SKILL
INSERT INTO executions (
  exec_type,
  skill_id,
  companion_id,
  user_id,
  organization_id,
  exec_status,
  exec_session_id,
  exec_attributes
) VALUES (
  'SKILL',
  'skill-uuid',
  'companion-uuid',
  'user-uuid',
  'org-uuid',
  'pending',
  'session-123',
  '{"input_data": {"query": "test"}, "metadata": {"version": "1.0"}}'::jsonb
);

-- Inserir execução de WORKFLOW
INSERT INTO executions (
  exec_type,
  wkfl_id,
  companion_id,
  user_id,
  organization_id,
  exec_total_steps,
  exec_session_id,
  exec_attributes
) VALUES (
  'WORKFLOW',
  'workflow-uuid',
  'companion-uuid',
  'user-uuid',
  'org-uuid',
  5,
  'session-123',
  '{"initial_input": {"data": "test"}, "execution_config": {"timeout": 30000}}'::jsonb
);

-- Buscar execuções de um companion
SELECT 
  exec_id,
  exec_type,
  exec_status,
  exec_started_at,
  exec_duration_ms
FROM executions
WHERE companion_id = 'companion-uuid'
  AND organization_id = 'org-uuid'
ORDER BY exec_started_at DESC
LIMIT 20;

-- Buscar workflows em execução
SELECT 
  exec_id,
  wkfl_id,
  exec_current_step_order,
  exec_total_steps,
  exec_completed_steps,
  (exec_completed_steps::float / exec_total_steps * 100) AS progress_percentage
FROM executions
WHERE exec_type = 'WORKFLOW'
  AND exec_status = 'running'
  AND user_id = 'user-uuid';

-- Analytics: Tempo médio de execução por tipo
SELECT 
  exec_type,
  exec_status,
  COUNT(*) AS total_executions,
  AVG(exec_duration_ms) AS avg_duration_ms,
  PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY exec_duration_ms) AS median_duration_ms,
  PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY exec_duration_ms) AS p95_duration_ms
FROM executions
WHERE exec_started_at >= NOW() - INTERVAL '7 days'
  AND organization_id = 'org-uuid'
GROUP BY exec_type, exec_status;

-- Buscar execuções com erro
SELECT 
  exec_id,
  exec_type,
  exec_error_code,
  exec_error_message,
  exec_started_at
FROM executions
WHERE exec_status = 'failed'
  AND organization_id = 'org-uuid'
  AND exec_error_code IS NOT NULL
ORDER BY exec_started_at DESC
LIMIT 50;
*/
