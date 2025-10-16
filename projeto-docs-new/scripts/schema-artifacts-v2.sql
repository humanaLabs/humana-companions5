-- ============================================================
-- ARTIFACTS v2.0 - Schema SQL
-- ============================================================
-- Versão: 2.0
-- Data: 2025-01-10
-- Descrição: Artefatos gerados (documentos, imagens, arquivos)
-- ============================================================

-- ============================================================
-- ENUMS
-- ============================================================

CREATE TYPE status_artifact_enum AS ENUM (
  'ACT',      -- Active
  'ARC',      -- Archived
  'DEL'       -- Deleted
);

-- ============================================================
-- TABELA: artifacts
-- ============================================================

CREATE TABLE artifacts (
  -- Identificador único
  artf_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Relacionamentos
  chat_id UUID REFERENCES chats(chat_id) ON DELETE SET NULL,
  workspace_id UUID NOT NULL REFERENCES workspaces(wksp_id),
  
  -- Identificação
  artf_name VARCHAR(255) NOT NULL,
  
  -- Conteúdo
  artf_content BYTEA NOT NULL,
  artf_format VARCHAR(10) NOT NULL,
  
  -- Estado
  artf_status status_artifact_enum NOT NULL DEFAULT 'ACT',
  
  -- Timestamps
  artf_created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  artf_updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- ============================================================
-- ÍNDICES
-- ============================================================

-- Índices para relacionamentos
CREATE INDEX idx_artifacts_chat ON artifacts(chat_id);
CREATE INDEX idx_artifacts_workspace ON artifacts(workspace_id);

-- Índice para status
CREATE INDEX idx_artifacts_status ON artifacts(artf_status);

-- Índice para formato
CREATE INDEX idx_artifacts_format ON artifacts(artf_format);

-- Índices para ordenação temporal
CREATE INDEX idx_artifacts_created ON artifacts(artf_created_at DESC);
CREATE INDEX idx_artifacts_updated ON artifacts(artf_updated_at DESC);

-- Índices compostos para consultas frequentes
CREATE INDEX idx_artifacts_workspace_status ON artifacts(workspace_id, artf_status);
CREATE INDEX idx_artifacts_chat_status ON artifacts(chat_id, artf_status) WHERE chat_id IS NOT NULL;
CREATE INDEX idx_artifacts_format_status ON artifacts(artf_format, artf_status);

-- Índice para busca full-text no nome
CREATE INDEX idx_artifacts_name_fts ON artifacts 
  USING GIN (to_tsvector('portuguese', artf_name));

-- ============================================================
-- TRIGGER (auto-update updated_at)
-- ============================================================

CREATE OR REPLACE FUNCTION update_artf_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.artf_updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_artf_updated_at
  BEFORE UPDATE ON artifacts
  FOR EACH ROW
  EXECUTE FUNCTION update_artf_updated_at();

-- ============================================================
-- COMENTÁRIOS DAS COLUNAS
-- ============================================================

COMMENT ON COLUMN artifacts.artf_id IS 'Identificador único do artefato (PK)';
COMMENT ON COLUMN artifacts.chat_id IS 'ID do chat que gerou o artefato (FK → chats_v5, NULLABLE)';
COMMENT ON COLUMN artifacts.workspace_id IS 'ID do workspace do artefato (FK → workspaces)';
COMMENT ON COLUMN artifacts.artf_name IS 'Nome do artefato exibido na UI';
COMMENT ON COLUMN artifacts.artf_content IS 'Conteúdo binário do artefato (BYTEA)';
COMMENT ON COLUMN artifacts.artf_format IS 'Formato do arquivo (MD, SVG, PDF, HTML, JSON, PNG, DOCX, etc.)';
COMMENT ON COLUMN artifacts.artf_status IS 'Status do artefato (ACT, ARC, DEL)';
COMMENT ON COLUMN artifacts.artf_created_at IS 'Data e hora de criação do artefato';
COMMENT ON COLUMN artifacts.artf_updated_at IS 'Data e hora da última atualização (atualizado automaticamente via trigger)';


