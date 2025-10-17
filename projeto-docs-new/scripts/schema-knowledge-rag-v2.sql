-- ============================================================
-- KNOWLEDGE_RAG v3.0 - Schema SQL (camelCase)
-- ============================================================
-- Versão: 3.0
-- Data: 2025-01-15
-- Descrição: Sistema de conhecimento vetorizado (RAG com pgvector)
-- Mudanças v3.0: Nomenclatura camelCase com aspas duplas
-- ============================================================

-- ============================================================
-- EXTENSÕES
-- ============================================================

-- Habilitar pgvector para embeddings
CREATE EXTENSION IF NOT EXISTS vector;

-- ============================================================
-- ENUMS
-- ============================================================

CREATE TYPE "resourceKindEnum" AS ENUM (
  'ORG',      -- Organização
  'WSP',      -- Workspace
  'CMP',      -- Companion
  'PRL',      -- Profile
  'CHT',      -- Chat
  'KNW',      -- Knowledge
  'TOL'       -- Tool
);

CREATE TYPE "classInfoEnum" AS ENUM (
  'PUB',      -- Público
  'ORG',      -- Organização
  'WSP',      -- Workspace
  'PVT'       -- Privado
);

-- ============================================================
-- TABELA: KnowledgeRag
-- ============================================================

CREATE TABLE "HU_Knowledge_RAG" (
  -- Identificador único
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Recurso de origem
  "resourceKind" "resourceKindEnum" NOT NULL,
  "resourceId" UUID NOT NULL,
  
  -- Controle de acesso
  "classInfo" "classInfoEnum" NOT NULL,
  "restrictsStamps" TEXT[] NOT NULL DEFAULT '{}',
  
  -- Conteúdo e embedding
  "content" TEXT NOT NULL,
  "embedding" VECTOR(1536) NOT NULL,
  
  -- Metadados do chunk
  "chunkIndex" INTEGER NOT NULL,
  "sourceFile" VARCHAR(500),
  
  -- Atributos adicionais (JSONB)
  "attributes" JSONB NOT NULL DEFAULT '{}'::jsonb,
  
  -- Timestamp
  "createdAt" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  
  -- Constraints
  CONSTRAINT check_chunk_index_positive CHECK ("chunkIndex" >= 0),
  CONSTRAINT valid_attributes CHECK (jsonb_typeof("attributes") = 'object')
);

-- ============================================================
-- ÍNDICES
-- ============================================================

-- Índices para recurso de origem
CREATE INDEX "idxKnowledgeResource" ON "HU_Knowledge_RAG"("resourceKind", "resourceId");

-- Índice para controle de acesso
CREATE INDEX "idxKnowledgeClass" ON "HU_Knowledge_RAG"("classInfo");
CREATE INDEX "idxKnowledgeRestricts" ON "HU_Knowledge_RAG" USING GIN ("restrictsStamps");

-- Índice para data de criação
CREATE INDEX "idxKnowledgeCreatedAt" ON "HU_Knowledge_RAG"("createdAt" DESC);

-- Índice vetorial IVFFlat para busca de similaridade
-- NOTA: Ajustar 'lists' baseado no volume de dados (√total_rows)
CREATE INDEX "idxKnowledgeEmbedding" ON "HU_Knowledge_RAG" 
  USING ivfflat ("embedding" vector_cosine_ops) 
  WITH (lists = 100);

-- Índices para metadados do chunk
CREATE INDEX "idxKnowledgeChunkIndex" ON "HU_Knowledge_RAG"("chunkIndex");
CREATE INDEX "idxKnowledgeSourceFile" ON "HU_Knowledge_RAG"("sourceFile");

-- Índices compostos para consultas frequentes
CREATE INDEX "idxKnowledgeResourceClass" ON "HU_Knowledge_RAG"("resourceKind", "resourceId", "classInfo");
CREATE INDEX "idxKnowledgeClassRestricts" ON "HU_Knowledge_RAG"("classInfo", "restrictsStamps");

-- Índice GIN geral para atributos JSONB
CREATE INDEX "idxKnowledgeAttributes" ON "HU_Knowledge_RAG" USING GIN ("attributes");

-- Índices JSONB para consultas específicas
CREATE INDEX "idxKnowledgeEmbeddingModel" ON "HU_Knowledge_RAG" 
  USING GIN (("attributes"->'embedding_config'->>'embedding_model'));
CREATE INDEX "idxKnowledgeFileType" ON "HU_Knowledge_RAG" 
  USING GIN (("attributes"->'file_metadata'->>'file_type'));
CREATE INDEX "idxKnowledgeLanguage" ON "HU_Knowledge_RAG" 
  USING GIN (("attributes"->'chunk_metadata'->>'language'));

-- Índice para busca full-text no conteúdo
CREATE INDEX "idxKnowledgeContentFts" ON "HU_Knowledge_RAG" 
  USING GIN (to_tsvector('portuguese', "content"));

-- Índice para busca full-text no arquivo de origem
CREATE INDEX "idxKnowledgeSourceFts" ON "HU_Knowledge_RAG" 
  USING GIN (to_tsvector('portuguese', "sourceFile"));

-- ============================================================
-- COMENTÁRIOS DAS COLUNAS
-- ============================================================

COMMENT ON TABLE "HU_Knowledge_RAG" IS 'Tabela de conhecimento RAG v3.0 - Sistema vetorizado com pgvector';

COMMENT ON COLUMN "HU_Knowledge_RAG".id IS 'PK - Identificador único do chunk de conhecimento';
COMMENT ON COLUMN "HU_Knowledge_RAG"."resourceKind" IS 'Tipo do recurso que gerou o conhecimento (ORG, WSP, CMP, etc.)';
COMMENT ON COLUMN "HU_Knowledge_RAG"."resourceId" IS 'ID do recurso que gerou o conhecimento';
COMMENT ON COLUMN "HU_Knowledge_RAG"."classInfo" IS 'Nível de acesso do conhecimento (PUB, ORG, WSP, PVT)';
COMMENT ON COLUMN "HU_Knowledge_RAG"."restrictsStamps" IS 'Array de classificações de sensibilidade (PII, FIN, COF, etc.)';
COMMENT ON COLUMN "HU_Knowledge_RAG"."content" IS 'Conteúdo textual do chunk de conhecimento';
COMMENT ON COLUMN "HU_Knowledge_RAG"."embedding" IS 'Vetor de embedding (1536 dimensões) para busca semântica';
COMMENT ON COLUMN "HU_Knowledge_RAG"."chunkIndex" IS 'Índice do chunk no documento original (para ordenação)';
COMMENT ON COLUMN "HU_Knowledge_RAG"."sourceFile" IS 'Nome do arquivo de origem (opcional)';
COMMENT ON COLUMN "HU_Knowledge_RAG"."attributes" IS 'Atributos adicionais em JSONB (chunk_metadata, embedding_config, file_metadata, etc.)';
COMMENT ON COLUMN "HU_Knowledge_RAG"."createdAt" IS 'Data e hora de criação do chunk';

-- ============================================================================
-- FIM DO SCHEMA
-- ============================================================================

-- RESUMO FINAL:
-- ✅ Tabela: "HU_Knowledge_RAG" (10 campos)
-- ✅ Colunas camelCase: id, "resourceKind", "resourceId", "classInfo", "restrictsStamps", "content", "embedding", "chunkIndex", "sourceFile", "attributes", "createdAt"
-- ✅ Índices camelCase: "idxKnowledgeResource", "idxKnowledgeClass", "idxKnowledgeEmbedding", etc.
-- ✅ ENUMs: "resourceKindEnum", "classInfoEnum"
-- ✅ pgvector: Vetores de 1536 dimensões para busca semântica
-- ✅ Aspas duplas obrigatórias para preservar camelCase no PostgreSQL
