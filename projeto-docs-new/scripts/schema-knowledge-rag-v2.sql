-- ============================================================
-- KNOWLEDGE_RAG v2.0 - Schema SQL
-- ============================================================
-- Versão: 2.0
-- Data: 2025-01-10
-- Descrição: Sistema de conhecimento vetorizado (RAG com pgvector)
-- ============================================================

-- ============================================================
-- EXTENSÕES
-- ============================================================

-- Habilitar pgvector para embeddings
CREATE EXTENSION IF NOT EXISTS vector;

-- ============================================================
-- ENUMS
-- ============================================================

CREATE TYPE resource_kind_enum AS ENUM (
  'ORG',      -- Organização
  'WSP',      -- Workspace
  'CMP',      -- Companion
  'PRL',      -- Profile
  'CHT',      -- Chat
  'KNW',      -- Knowledge
  'TOL'       -- Tool
);

CREATE TYPE class_info_enum AS ENUM (
  'PUB',      -- Público
  'ORG',      -- Organização
  'WSP',      -- Workspace
  'PVT'       -- Privado
);

-- ============================================================
-- TABELA: knowledge_rag
-- ============================================================

CREATE TABLE knowledge_rag (
  -- Identificador único
  know_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Recurso de origem
  know_resource_kind resource_kind_enum NOT NULL,
  know_resource_id UUID NOT NULL,
  
  -- Controle de acesso
  know_class_info class_info_enum NOT NULL,
  know_restricts_stamps TEXT[] NOT NULL DEFAULT '{}',
  
  -- Conteúdo e embedding
  know_content TEXT NOT NULL,
  know_embedding VECTOR(1536) NOT NULL,
  
  -- Metadados do chunk
  know_chunk_index INTEGER NOT NULL,
  know_source_file VARCHAR(500),
  
  -- Atributos adicionais (JSONB)
  know_attributes JSONB NOT NULL DEFAULT '{}'::jsonb,
  
  -- Timestamp
  know_created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  
  -- Constraints
  CONSTRAINT check_chunk_index_positive CHECK (know_chunk_index >= 0),
  CONSTRAINT valid_attributes CHECK (jsonb_typeof(know_attributes) = 'object')
);

-- ============================================================
-- ÍNDICES
-- ============================================================

-- Índices para recurso de origem
CREATE INDEX idx_knowledge_resource ON knowledge_rag(know_resource_kind, know_resource_id);

-- Índice para controle de acesso
CREATE INDEX idx_knowledge_class ON knowledge_rag(know_class_info);
CREATE INDEX idx_knowledge_restricts ON knowledge_rag USING GIN (know_restricts_stamps);

-- Índice para data de criação
CREATE INDEX idx_knowledge_created ON knowledge_rag(know_created_at DESC);

-- Índice vetorial IVFFlat para busca de similaridade
-- NOTA: Ajustar 'lists' baseado no volume de dados (√total_rows)
CREATE INDEX idx_knowledge_embedding ON knowledge_rag 
  USING ivfflat (know_embedding vector_cosine_ops) 
  WITH (lists = 100);

-- Índices para metadados do chunk
CREATE INDEX idx_knowledge_chunk_index ON knowledge_rag(know_chunk_index);
CREATE INDEX idx_knowledge_source_file ON knowledge_rag(know_source_file);

-- Índices compostos para consultas frequentes
CREATE INDEX idx_knowledge_resource_class ON knowledge_rag(know_resource_kind, know_resource_id, know_class_info);
CREATE INDEX idx_knowledge_class_restricts ON knowledge_rag(know_class_info, know_restricts_stamps);

-- Índice GIN geral para atributos JSONB
CREATE INDEX idx_knowledge_attributes_gin ON knowledge_rag USING GIN (know_attributes);

-- Índices JSONB para consultas específicas
CREATE INDEX idx_knowledge_embedding_model ON knowledge_rag 
  USING GIN ((know_attributes->'embedding_config'->>'embedding_model'));
CREATE INDEX idx_knowledge_file_type ON knowledge_rag 
  USING GIN ((know_attributes->'file_metadata'->>'file_type'));
CREATE INDEX idx_knowledge_language ON knowledge_rag 
  USING GIN ((know_attributes->'chunk_metadata'->>'language'));

-- Índice para busca full-text no conteúdo
CREATE INDEX idx_knowledge_content_fts ON knowledge_rag 
  USING GIN (to_tsvector('portuguese', know_content));

-- Índice para busca full-text no arquivo de origem
CREATE INDEX idx_knowledge_source_fts ON knowledge_rag 
  USING GIN (to_tsvector('portuguese', know_source_file));

-- ============================================================
-- COMENTÁRIOS DAS COLUNAS
-- ============================================================

COMMENT ON COLUMN knowledge_rag.know_id IS 'Identificador único do chunk de conhecimento (PK)';
COMMENT ON COLUMN knowledge_rag.know_resource_kind IS 'Tipo do recurso que gerou o conhecimento (ORG, WSP, CMP, etc.)';
COMMENT ON COLUMN knowledge_rag.know_resource_id IS 'ID do recurso que gerou o conhecimento';
COMMENT ON COLUMN knowledge_rag.know_class_info IS 'Nível de acesso do conhecimento (PUB, ORG, WSP, PVT)';
COMMENT ON COLUMN knowledge_rag.know_restricts_stamps IS 'Array de classificações de sensibilidade (PII, FIN, COF, etc.)';
COMMENT ON COLUMN knowledge_rag.know_content IS 'Conteúdo textual do chunk de conhecimento';
COMMENT ON COLUMN knowledge_rag.know_embedding IS 'Vetor de embedding (1536 dimensões) para busca semântica';
COMMENT ON COLUMN knowledge_rag.know_chunk_index IS 'Índice do chunk no documento original (para ordenação)';
COMMENT ON COLUMN knowledge_rag.know_source_file IS 'Nome do arquivo de origem (opcional)';
COMMENT ON COLUMN knowledge_rag.know_attributes IS 'Atributos adicionais em JSONB (chunk_metadata, embedding_config, file_metadata, etc.)';
COMMENT ON COLUMN knowledge_rag.know_created_at IS 'Data e hora de criação do chunk';


