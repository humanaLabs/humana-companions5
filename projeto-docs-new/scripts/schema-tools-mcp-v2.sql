-- ============================================================
-- TOOLS_MCP v2.0 - Schema SQL
-- ============================================================
-- Versão: 2.0
-- Data: 2025-01-10
-- Descrição: Ferramentas MCP (Model Context Protocol)
-- ============================================================

-- ============================================================
-- ENUMS
-- ============================================================

CREATE TYPE tool_type_enum AS ENUM (
  'DATABASE',     -- Ferramenta de banco de dados
  'API',          -- Ferramenta de API
  'FILESYSTEM',   -- Ferramenta de sistema de arquivos
  'CUSTOM'        -- Ferramenta customizada
);

CREATE TYPE auth_type_enum AS ENUM (
  'BEARER',       -- Bearer token
  'OAUTH',        -- OAuth 2.0
  'API_KEY',      -- API Key
  'NONE'          -- Sem autenticação
);

-- ============================================================
-- TABELA: tools_mcp
-- ============================================================

CREATE TABLE tools_mcp (
  -- Identificador único
  tool_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Multi-tenancy (isolamento por organização)
  organization_id UUID NOT NULL REFERENCES organizations(orgs_id) ON DELETE CASCADE,
  
  -- Propriedade (quem configurou)
  configured_by_user_id UUID NOT NULL REFERENCES users(user_id),
  
  -- Identificação
  tool_name VARCHAR(255) NOT NULL,
  tool_type tool_type_enum NOT NULL,
  
  -- Autenticação
  tool_auth_type auth_type_enum NOT NULL,
  
  -- Atributos JSONB (configurações e metadados)
  tool_attributes JSONB NOT NULL DEFAULT '{}'::jsonb,
  
  -- Estado
  tool_is_active BOOLEAN NOT NULL DEFAULT TRUE,
  
  -- Timestamps
  tool_created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  tool_updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
  
  -- Constraints
  CONSTRAINT valid_attributes CHECK (jsonb_typeof(tool_attributes) = 'object')
);

-- ============================================================
-- ÍNDICES
-- ============================================================

-- Índices para relacionamentos
CREATE INDEX idx_tools_org ON tools_mcp(organization_id);
CREATE INDEX idx_tools_configured_by ON tools_mcp(configured_by_user_id);

-- Índices para tipo e autenticação
CREATE INDEX idx_tools_type ON tools_mcp(tool_type);
CREATE INDEX idx_tools_auth ON tools_mcp(tool_auth_type);

-- Índice parcial: apenas ferramentas ativas
CREATE INDEX idx_tools_active ON tools_mcp(tool_is_active) WHERE tool_is_active = TRUE;

-- Índice para ordenação por data de atualização
CREATE INDEX idx_tools_updated ON tools_mcp(tool_updated_at DESC);

-- Índices compostos para consultas frequentes
CREATE INDEX idx_tools_org_type ON tools_mcp(organization_id, tool_type);
CREATE INDEX idx_tools_org_active ON tools_mcp(organization_id, tool_is_active);
CREATE INDEX idx_tools_type_active ON tools_mcp(tool_type, tool_is_active);

-- Índice GIN geral para attributes
CREATE INDEX idx_tools_attributes_gin ON tools_mcp USING GIN (tool_attributes);

-- Índices JSONB para consultas específicas em tool_attributes
CREATE INDEX idx_tools_category ON tools_mcp 
  USING GIN ((tool_attributes->'basic_info'->>'category'));
CREATE INDEX idx_tools_tags ON tools_mcp 
  USING GIN ((tool_attributes->'basic_info'->'tags'));
CREATE INDEX idx_tools_version ON tools_mcp 
  USING GIN ((tool_attributes->'basic_info'->>'version'));

-- Índice para busca full-text no nome
CREATE INDEX idx_tools_name_fts ON tools_mcp 
  USING GIN (to_tsvector('portuguese', tool_name));

-- ============================================================
-- TRIGGER (auto-update updated_at)
-- ============================================================

CREATE OR REPLACE FUNCTION update_tool_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.tool_updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_tool_updated_at
  BEFORE UPDATE ON tools_mcp
  FOR EACH ROW
  EXECUTE FUNCTION update_tool_updated_at();

-- ============================================================
-- COMENTÁRIOS DAS COLUNAS
-- ============================================================

COMMENT ON COLUMN tools_mcp.tool_id IS 'Identificador único da ferramenta MCP (PK)';
COMMENT ON COLUMN tools_mcp.organization_id IS 'ID da organização dona da ferramenta (FK → organizations)';
COMMENT ON COLUMN tools_mcp.configured_by_user_id IS 'ID do usuário que configurou a ferramenta (FK → users)';
COMMENT ON COLUMN tools_mcp.tool_name IS 'Nome da ferramenta exibido na UI';
COMMENT ON COLUMN tools_mcp.tool_type IS 'Tipo da ferramenta (DATABASE, API, FILESYSTEM, CUSTOM)';
COMMENT ON COLUMN tools_mcp.tool_auth_type IS 'Tipo de autenticação (BEARER, OAUTH, API_KEY, NONE)';
COMMENT ON COLUMN tools_mcp.tool_attributes IS 'Atributos JSONB (basic_info, auth_config, connection_config, performance_metrics, compliance_audit, monitoring_alerting, ai_enhancement)';
COMMENT ON COLUMN tools_mcp.tool_is_active IS 'Indica se a ferramenta está ativa (soft delete)';
COMMENT ON COLUMN tools_mcp.tool_created_at IS 'Data e hora de criação da ferramenta';
COMMENT ON COLUMN tools_mcp.tool_updated_at IS 'Data e hora da última atualização (atualizado automaticamente via trigger)';


