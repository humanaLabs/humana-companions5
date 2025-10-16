-- ============================================================
-- SKILLS v2.0 - Schema SQL
-- ============================================================
-- Versão: 2.0
-- Data: 2025-01-10
-- Descrição: Skills/Capacidades dos Companions (AI SDK 5.0 Tools)
-- ============================================================

-- ============================================================
-- TABELA: skills
-- ============================================================

CREATE TABLE skills (
  -- Identificador único
  skil_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Relacionamentos (multi-tenancy)
  organization_id UUID NOT NULL REFERENCES organizations(orgs_id) ON DELETE CASCADE,
  companion_id UUID NOT NULL REFERENCES new_companions(companion_id) ON DELETE CASCADE,
  
  -- Identificação
  skil_name VARCHAR(100) NOT NULL,
  skil_display_name VARCHAR(150) NOT NULL,
  skil_description TEXT,
  
  -- AI SDK 5.0 Tool Interface
  skil_tool_name VARCHAR(100) NOT NULL,
  skil_tool_description TEXT NOT NULL,
  
  -- Classificação
  skil_category VARCHAR(50) NOT NULL,
  skil_execution_type VARCHAR(20) NOT NULL DEFAULT 'sync',
  skil_version VARCHAR(20) NOT NULL DEFAULT '1.0.0',
  
  -- Estado
  skil_is_active BOOLEAN NOT NULL DEFAULT TRUE,
  skil_is_deprecated BOOLEAN NOT NULL DEFAULT FALSE,
  
  -- Integração MCP
  skil_mcp_integration BOOLEAN NOT NULL DEFAULT FALSE,
  skil_has_mcp_mapping BOOLEAN NOT NULL DEFAULT FALSE,
  mcp_server_id UUID REFERENCES mcp_servers(server_id) ON DELETE SET NULL,
  
  -- Configurações de Execução
  skil_max_retries INTEGER NOT NULL DEFAULT 3,
  skil_timeout_ms INTEGER NOT NULL DEFAULT 30000,
  skil_cacheable BOOLEAN NOT NULL DEFAULT FALSE,
  skil_cache_expiry_ms INTEGER,
  
  -- Métricas de Performance
  skil_avg_execution_time_ms NUMERIC(10,2) DEFAULT 0,
  skil_success_rate NUMERIC(5,2) DEFAULT 100.0,
  skil_error_rate NUMERIC(5,2) DEFAULT 0,
  skil_usage_count INTEGER NOT NULL DEFAULT 0,
  skil_last_used TIMESTAMP,
  
  -- Atributos JSONB (tool_schema, metadata)
  skil_attributes JSONB NOT NULL DEFAULT '{}'::jsonb,
  
  -- Timestamps
  skil_created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  skil_updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
  
  -- Constraints
  CONSTRAINT unique_skill_name_per_org UNIQUE (organization_id, skil_name),
  CONSTRAINT check_timeout_positive CHECK (skil_timeout_ms > 0),
  CONSTRAINT check_max_retries_positive CHECK (skil_max_retries >= 0),
  CONSTRAINT check_success_rate_range CHECK (skil_success_rate >= 0 AND skil_success_rate <= 100),
  CONSTRAINT check_error_rate_range CHECK (skil_error_rate >= 0 AND skil_error_rate <= 100),
  CONSTRAINT valid_attributes CHECK (jsonb_typeof(skil_attributes) = 'object')
);

-- ============================================================
-- ÍNDICES
-- ============================================================

-- Índices para relacionamentos
CREATE INDEX idx_skills_org ON skills(organization_id);
CREATE INDEX idx_skills_companion ON skills(companion_id);
CREATE INDEX idx_skills_mcp_server ON skills(mcp_server_id);

-- Índice parcial: apenas skills ativas
CREATE INDEX idx_skills_active ON skills(skil_is_active) WHERE skil_is_active = TRUE;

-- Índices para classificação
CREATE INDEX idx_skills_category ON skills(skil_category);
CREATE INDEX idx_skills_execution_type ON skills(skil_execution_type);

-- Índices para métricas
CREATE INDEX idx_skills_usage ON skills(skil_usage_count DESC);
CREATE INDEX idx_skills_performance ON skills(skil_success_rate DESC, skil_avg_execution_time_ms);
CREATE INDEX idx_skills_last_used ON skills(skil_last_used DESC);

-- Índice GIN geral para attributes
CREATE INDEX idx_skills_attributes_gin ON skills USING GIN (skil_attributes);

-- Índices GIN para consultas específicas em skil_attributes
CREATE INDEX idx_skills_tool_schema ON skills 
  USING GIN ((skil_attributes->'tool_schema'));
CREATE INDEX idx_skills_metadata ON skills 
  USING GIN ((skil_attributes->'metadata'));

-- Índice para busca full-text
CREATE INDEX idx_skills_name_fts ON skills 
  USING GIN (to_tsvector('portuguese', skil_name || ' ' || skil_display_name));

-- ============================================================
-- TRIGGER (auto-update updated_at)
-- ============================================================

CREATE OR REPLACE FUNCTION update_skil_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.skil_updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_skil_updated_at
  BEFORE UPDATE ON skills
  FOR EACH ROW
  EXECUTE FUNCTION update_skil_updated_at();

-- ============================================================
-- COMENTÁRIOS DAS COLUNAS
-- ============================================================

COMMENT ON COLUMN skills.skil_id IS 'Identificador único da skill (PK)';
COMMENT ON COLUMN skills.organization_id IS 'ID da organização (FK → organizations)';
COMMENT ON COLUMN skills.companion_id IS 'ID do companion dono da skill (FK → new_companions)';
COMMENT ON COLUMN skills.skil_name IS 'Nome interno da skill (único por organização)';
COMMENT ON COLUMN skills.skil_display_name IS 'Nome exibido na UI';
COMMENT ON COLUMN skills.skil_description IS 'Descrição detalhada da skill';
COMMENT ON COLUMN skills.skil_tool_name IS 'Nome da tool no AI SDK 5.0';
COMMENT ON COLUMN skills.skil_tool_description IS 'Descrição da tool para o LLM entender quando usar';
COMMENT ON COLUMN skills.skil_category IS 'Categoria da skill (THINK, ACT, etc.)';
COMMENT ON COLUMN skills.skil_execution_type IS 'Tipo de execução (sync, async)';
COMMENT ON COLUMN skills.skil_version IS 'Versão da skill';
COMMENT ON COLUMN skills.skil_is_active IS 'Indica se a skill está ativa';
COMMENT ON COLUMN skills.skil_is_deprecated IS 'Indica se a skill está deprecada';
COMMENT ON COLUMN skills.skil_mcp_integration IS 'Indica se usa integração MCP';
COMMENT ON COLUMN skills.skil_has_mcp_mapping IS 'Indica se possui mapeamento MCP configurado';
COMMENT ON COLUMN skills.mcp_server_id IS 'ID do servidor MCP (FK → mcp_servers, opcional)';
COMMENT ON COLUMN skills.skil_max_retries IS 'Número máximo de tentativas em caso de falha';
COMMENT ON COLUMN skills.skil_timeout_ms IS 'Timeout de execução em milissegundos';
COMMENT ON COLUMN skills.skil_cacheable IS 'Indica se o resultado pode ser cacheado';
COMMENT ON COLUMN skills.skil_cache_expiry_ms IS 'Tempo de expiração do cache em milissegundos';
COMMENT ON COLUMN skills.skil_avg_execution_time_ms IS 'Tempo médio de execução em milissegundos';
COMMENT ON COLUMN skills.skil_success_rate IS 'Taxa de sucesso em porcentagem (0-100)';
COMMENT ON COLUMN skills.skil_error_rate IS 'Taxa de erro em porcentagem (0-100)';
COMMENT ON COLUMN skills.skil_usage_count IS 'Contador de uso da skill';
COMMENT ON COLUMN skills.skil_last_used IS 'Data e hora do último uso';
COMMENT ON COLUMN skills.skil_attributes IS 'Atributos JSONB (tool_schema, metadata)';
COMMENT ON COLUMN skills.skil_created_at IS 'Data e hora de criação da skill';
COMMENT ON COLUMN skills.skil_updated_at IS 'Data e hora da última atualização (atualizado automaticamente via trigger)';


