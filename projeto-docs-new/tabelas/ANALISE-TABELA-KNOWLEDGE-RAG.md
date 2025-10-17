# 🧠 ANÁLISE DETALHADA - TABELA KNOWLEDGE_RAG

**Documento**: Análise de estrutura da tabela KNOWLEDGE_RAG para refatoração do backend  
**Versão**: 1.0  
**Data**: 2025-01-15  
**Objetivo**: Definir estrutura otimizada para sistema de conhecimento vetorizado (RAG)

---

## 🎯 TABELA KNOWLEDGE_RAG - ANÁLISE COMPLETA

### 📋 **COLUNAS HEADER (Diretas) - ESTRUTURA FINAL**

| Campo | Tipo | Constraints | Justificativa Detalhada |
|-------|------|-------------|-------------------------|
| `know_id` | UUID | PRIMARY KEY | **Identificador único global** - Usado em todas as operações CRUD, relacionamentos, RLS policies e URLs da aplicação. UUID garante unicidade distribuída e segurança. |
| `know_resource_kind` | ENUM | NOT NULL | **Tipo de recurso** - `ORG`, `WSP`, `CMP`, `PRL`, `CHT`, `KNW`, `TOL`. Usado para filtragem por tipo de recurso e lógica de negócio. Essencial para RLS e organização. |
| `know_resource_id` | UUID | NOT NULL | **ID do recurso** - Identificador do recurso que gerou o conhecimento. Usado para rastreabilidade e relacionamento com recursos originais. |
| `know_class_info` | ENUM | NOT NULL | **Nível de acesso** - `PUB`, `ORG`, `WSP`, `PVT`. Usado para controle de acesso e filtragem de segurança. Essencial para RLS policies. |
| `know_restricts_stamps` | TEXT[] | NOT NULL DEFAULT '{}' | **Classificações de sensibilidade** - Array de classificações como `PII`, `FIN`, `COF`. Usado para filtragem de segurança baseada em role. |
| `know_content` | TEXT | NOT NULL | **Conteúdo do chunk** - Texto do conhecimento para busca e exibição. Usado para busca full-text e processamento. Essencial para funcionalidade core. |
| `know_embedding` | VECTOR(1536) | NOT NULL | **Embedding vetorial** - Vetor de 1536 dimensões para busca semântica. Usado para busca de similaridade com pgvector. Essencial para RAG. |
| `know_chunk_index` | INTEGER | NOT NULL | **Índice do chunk** - Posição do chunk no documento original. Usado para ordenação e reconstrução de documentos. |
| `know_source_file` | VARCHAR(500) | NULLABLE | **Arquivo de origem** - Nome do arquivo que gerou o chunk. Usado para rastreabilidade e referência. |
| `know_created_at` | TIMESTAMP | NOT NULL DEFAULT NOW() | **Auditoria temporal** - Data de criação do chunk. Usado para ordenação cronológica, analytics e auditoria. |

### 🔧 **ENUMs**
```sql
CREATE TYPE resource_kind_enum AS ENUM ('ORG', 'WSP', 'CMP', 'PRL', 'CHT', 'KNW', 'TOL');
CREATE TYPE class_info_enum AS ENUM ('PUB', 'ORG', 'WSP', 'PVT');
```

### 📦 **ATRIBUTOS JSONB - ESTRUTURA DETALHADA**

#### **1. chunk_metadata** - Metadados do Chunk
```json
{
  "chunk_size": 500,                  // Tamanho do chunk em caracteres
  "chunk_overlap": 50,                // Sobreposição com chunk anterior
  "total_chunks": 120,                // Total de chunks no documento
  "chunk_position": 15,               // Posição relativa no documento
  "paragraph_index": 3,               // Índice do parágrafo
  "sentence_index": 8,                // Índice da sentença
  "word_count": 85,                   // Número de palavras
  "character_count": 487,             // Número de caracteres
  "language": "pt-BR",                // Idioma detectado
  "encoding": "utf-8"                 // Codificação do texto
}
```
**Justificativa**: Metadados específicos do chunk para processamento e análise. Estrutura complexa que evolui com técnicas de chunking.

#### **2. embedding_config** - Configuração do Embedding
```json
{
  "embedding_model": "text-embedding-3-small", // Modelo usado
  "embedding_dimensions": 1536,        // Dimensões do vetor
  "embedding_provider": "openai",      // Provider do embedding
  "embedding_version": "3.0",          // Versão do modelo
  "embedding_cost_usd": 0.0001,       // Custo do embedding
  "embedding_tokens": 150,             // Tokens usados
  "embedding_created_at": "2025-01-15T10:00:00Z", // Data de criação
  "embedding_quality_score": 0.95,    // Score de qualidade
  "normalization": "l2",               // Tipo de normalização
  "similarity_function": "cosine"      // Função de similaridade
}
```
**Justificativa**: Configurações específicas do embedding. Essenciais para busca semântica e podem evoluir com novos modelos.

#### **3. file_metadata** - Metadados do Arquivo
```json
{
  "filename": "Manual_RH.pdf",        // Nome original do arquivo
  "file_type": "pdf",                 // Tipo do arquivo
  "file_size_bytes": 2400000,         // Tamanho em bytes
  "file_hash": "sha256:abc123...",    // Hash do arquivo
  "mime_type": "application/pdf",     // Tipo MIME
  "pages": 150,                       // Número de páginas
  "upload_date": "2025-01-10",        // Data de upload
  "uploaded_by": "uuid-user",         // Quem fez upload
  "file_url": "https://blob.vercel-storage.com/...", // URL do arquivo
  "thumbnail_url": "https://...",     // URL da miniatura
  "preview_url": "https://..."        // URL da prévia
}
```
**Justificativa**: Metadados específicos do arquivo original. Usados para referência e exibição, mas não para filtragem em larga escala.

#### **4. extraction_info** - Informações de Extração
```json
{
  "extraction_method": "azure_document_intelligence", // Método de extração
  "extraction_confidence": 0.95,      // Confiança da extração
  "extraction_language": "pt-BR",     // Idioma detectado
  "extraction_timestamp": "2025-01-15T10:00:00Z", // Data de extração
  "extraction_errors": [],            // Erros durante extração
  "extraction_warnings": [            // Avisos durante extração
    "Imagem sem texto detectada",
    "Tabela complexa encontrada"
  ],
  "ocr_confidence": 0.92,             // Confiança do OCR
  "layout_analysis": {                // Análise de layout
    "has_tables": true,
    "has_images": false,
    "has_headers": true,
    "column_count": 2
  },
  "text_quality": {                   // Qualidade do texto
    "readability_score": 0.85,
    "complexity_score": 0.7,
    "grammar_score": 0.9
  }
}
```
**Justificativa**: Informações específicas sobre como o conteúdo foi extraído. Essenciais para qualidade e debugging.

#### **5. semantic_analysis** - Análise Semântica
```json
{
  "semantic_tags": [                  // Tags semânticas
    "rh",
    "políticas",
    "férias",
    "funcionários"
  ],
  "named_entities": {                 // Entidades nomeadas
    "organizations": ["Empresa XYZ", "RH Corp"],
    "persons": ["João Silva", "Maria Santos"],
    "dates": ["2025", "12 meses", "Janeiro"],
    "locations": ["São Paulo", "Brasil"],
    "money": ["R$ 5.000", "salário mínimo"]
  },
  "topics": [                         // Tópicos identificados
    {
      "topic": "recursos_humanos",
      "confidence": 0.9,
      "keywords": ["funcionário", "contrato", "salário"]
    },
    {
      "topic": "políticas_empresariais",
      "confidence": 0.8,
      "keywords": ["regulamento", "norma", "procedimento"]
    }
  ],
  "sentiment": "neutral",             // Sentimento do texto
  "emotion": "informative",           // Emoção detectada
  "intent": "informational"           // Intenção do texto
}
```
**Justificativa**: Análise semântica complexa do conteúdo. Usada para categorização e busca inteligente.

#### **6. quality_metrics** - Métricas de Qualidade
```json
{
  "quality_score": 0.92,              // Score geral de qualidade
  "relevance_score": 0.85,            // Score de relevância
  "completeness_score": 0.9,          // Score de completude
  "accuracy_score": 0.88,             // Score de precisão
  "readability_score": 0.82,          // Score de legibilidade
  "coherence_score": 0.9,             // Score de coerência
  "duplicate_score": 0.1,             // Score de duplicação (baixo = único)
  "freshness_score": 0.95,            // Score de atualidade
  "authority_score": 0.9,             // Score de autoridade
  "last_quality_check": "2025-01-15T10:00:00Z", // Última verificação
  "quality_trend": "improving"        // Tendência da qualidade
}
```
**Justificativa**: Métricas de qualidade para otimização do sistema. Usadas para ranking e filtragem inteligente.

#### **7. usage_analytics** - Analytics de Uso
```json
{
  "view_count": 45,                   // Número de visualizações
  "search_count": 23,                 // Número de buscas que retornaram este chunk
  "click_count": 12,                  // Número de cliques
  "last_accessed_at": "2025-01-15T17:00:00Z", // Último acesso
  "avg_ranking_position": 3.2,        // Posição média nos resultados
  "conversion_rate": 0.15,            // Taxa de conversão
  "user_feedback": [                  // Feedback dos usuários
    {
      "user_id": "uuid-user-1",
      "rating": 5,
      "comment": "Muito útil!",
      "created_at": "2025-01-15T16:30:00Z"
    }
  ],
  "avg_rating": 4.5,                  // Avaliação média
  "popularity_score": 0.8             // Score de popularidade
}
```
**Justificativa**: Analytics de uso para otimização do sistema. Usadas para ranking e recomendações.

#### **8. security_compliance** - Segurança e Compliance
```json
{
  "data_classification": "internal",  // Classificação dos dados
  "sensitivity_level": "medium",      // Nível de sensibilidade
  "encryption_enabled": true,         // Criptografia habilitada
  "encryption_key_id": "uuid-key-1",  // ID da chave de criptografia
  "access_logging": true,             // Log de acesso habilitado
  "audit_trail": [                    // Trilha de auditoria
    {
      "action": "view",
      "user_id": "uuid-user-1",
      "timestamp": "2025-01-15T16:00:00Z",
      "ip_address": "192.168.1.100"
    }
  ],
  "retention_policy": {               // Política de retenção
    "retention_days": 2555,           // 7 anos
    "auto_delete": false,
    "archive_after_days": 1095        // 3 anos
  },
  "compliance_standards": [           // Padrões de compliance
    "GDPR",
    "LGPD",
    "SOX"
  ],
  "data_residency": "BR"              // Residência dos dados
}
```
**Justificativa**: Configurações de segurança e compliance. Específicas por organização e podem evoluir com regulamentações.

#### **9. search_optimization** - Otimização de Busca
```json
{
  "search_keywords": [                // Palavras-chave para busca
    "recursos humanos",
    "políticas",
    "férias",
    "funcionários"
  ],
  "search_aliases": [                 // Aliases para busca
    "rh",
    "pessoal",
    "colaboradores"
  ],
  "search_boost": 1.2,                // Boost de relevância
  "search_filters": {                 // Filtros de busca
    "department": "rh",
    "document_type": "policy",
    "year": 2025
  },
  "search_synonyms": [                // Sinônimos
    "funcionário",
    "colaborador",
    "empregado"
  ],
  "search_exclusions": [              // Palavras a excluir
    "exemplo",
    "teste",
    "dummy"
  ],
  "search_priority": "high"           // Prioridade na busca
}
```
**Justificativa**: Configurações específicas para otimização de busca. Podem variar por chunk e evoluir com algoritmos.

#### **10. integration_metadata** - Metadados de Integração
```json
{
  "source_systems": [                 // Sistemas de origem
    {
      "system": "odoo",
      "record_id": "uuid-record-1",
      "sync_enabled": true,
      "last_sync": "2025-01-15T16:00:00Z"
    }
  ],
  "webhook_endpoints": [              // Endpoints de webhook
    {
      "url": "https://api.empresa.com/webhooks/knowledge",
      "events": ["created", "updated", "deleted"],
      "secret": "webhook-secret",
      "enabled": true
    }
  ],
  "api_access": {                     // Acesso via API
    "api_key": "uuid-api-key",
    "rate_limit": 100,                // Requests por hora
    "expires_at": "2026-01-15T00:00:00Z"
  },
  "external_links": [                 // Links externos
    {
      "type": "jira",
      "url": "https://empresa.atlassian.net/browse/DOC-123",
      "title": "Documento relacionado"
    }
  ]
}
```
**Justificativa**: Metadados de integração com sistemas externos. Específicos por implementação e podem variar.

#### **11. version_control** - Controle de Versões
```json
{
  "version": 1,                       // Versão do chunk
  "parent_chunk_id": null,            // Chunk pai (se for atualização)
  "child_chunk_ids": [],              // Chunks filhos
  "version_history": [                // Histórico de versões
    {
      "version": 1,
      "created_at": "2025-01-15T10:00:00Z",
      "created_by": "uuid-user",
      "change_summary": "Criação inicial",
      "content_preview": "Primeira versão do chunk..."
    }
  ],
  "auto_versioning": true,            // Versionamento automático
  "max_versions": 10,                 // Máximo de versões mantidas
  "version_retention_days": 365       // Dias de retenção de versões
}
```
**Justificativa**: Controle de versões para chunks. Essencial para rastreabilidade e auditoria.

#### **12. ai_enhancement** - Melhorias de IA
```json
{
  "ai_enhanced": true,                // Se foi melhorado por IA
  "enhancement_type": "content_improvement", // Tipo de melhoria
  "enhancement_model": "gpt-4o",      // Modelo usado
  "enhancement_prompt": "Melhorar clareza e estrutura...", // Prompt usado
  "enhancement_changes": [            // Mudanças feitas
    {
      "type": "grammar_correction",
      "count": 3,
      "description": "Correções gramaticais"
    },
    {
      "type": "structure_improvement",
      "count": 2,
      "description": "Melhorias de estrutura"
    }
  ],
  "enhancement_quality_score": 0.9,   // Score de qualidade da melhoria
  "enhancement_cost_usd": 0.02,       // Custo da melhoria
  "enhancement_tokens": 200,          // Tokens usados
  "enhancement_time_ms": 3000         // Tempo de processamento
}
```
**Justificativa**: Melhorias automáticas de IA. Específicas da implementação e podem evoluir com novos modelos.

### 📊 **ÍNDICES RECOMENDADOS**

```sql
-- Índices existentes (manter)
CREATE INDEX idx_knowledge_resource ON knowledge_rag(know_resource_kind, know_resource_id);
CREATE INDEX idx_knowledge_class ON knowledge_rag(know_class_info);
CREATE INDEX idx_knowledge_restricts ON knowledge_rag USING GIN (know_restricts_stamps);
CREATE INDEX idx_knowledge_created ON knowledge_rag(know_created_at DESC);

-- Índice vetorial IVFFlat para busca de similaridade
CREATE INDEX idx_knowledge_embedding ON knowledge_rag 
  USING ivfflat (know_embedding vector_cosine_ops) 
  WITH (lists = 100);

-- Novos índices para knowledge_rag
CREATE INDEX idx_knowledge_chunk_index ON knowledge_rag(know_chunk_index);
CREATE INDEX idx_knowledge_source_file ON knowledge_rag(know_source_file);

-- Índices compostos para consultas frequentes
CREATE INDEX idx_knowledge_resource_class ON knowledge_rag(know_resource_kind, know_resource_id, know_class_info);
CREATE INDEX idx_knowledge_class_restricts ON knowledge_rag(know_class_info, know_restricts_stamps);

-- Índices JSONB para consultas específicas
CREATE INDEX idx_knowledge_embedding_model ON knowledge_rag USING GIN ((know_attributes->'embedding_config'->>'embedding_model'));
CREATE INDEX idx_knowledge_quality_score ON knowledge_rag USING GIN ((know_attributes->'quality_metrics'->>'quality_score'));
CREATE INDEX idx_knowledge_semantic_tags ON knowledge_rag USING GIN ((know_attributes->'semantic_analysis'->'semantic_tags'));
CREATE INDEX idx_knowledge_topics ON knowledge_rag USING GIN ((know_attributes->'semantic_analysis'->'topics'));
CREATE INDEX idx_knowledge_file_type ON knowledge_rag USING GIN ((know_attributes->'file_metadata'->>'file_type'));
CREATE INDEX idx_knowledge_language ON knowledge_rag USING GIN ((know_attributes->'chunk_metadata'->>'language'));
CREATE INDEX idx_knowledge_classification ON knowledge_rag USING GIN ((know_attributes->'security_compliance'->>'data_classification'));

-- Índice para busca full-text no conteúdo
CREATE INDEX idx_knowledge_content_fts ON knowledge_rag USING GIN (to_tsvector('portuguese', know_content));

-- Índice para busca full-text no source_file
CREATE INDEX idx_knowledge_source_fts ON knowledge_rag USING GIN (to_tsvector('portuguese', know_source_file));
```

---

## 🎯 **RESUMO EXECUTIVO - TABELA KNOWLEDGE_RAG**

### **COLUNAS HEADER (10 campos):**
- **Identificadores**: `id`, `resource_kind`, `resource_id`
- **Segurança**: `class_info`, `restricts_stamps`
- **Conteúdo**: `content`, `embedding`, `chunk_index`, `source_file`
- **Temporal**: `created_at`

### **ATRIBUTOS JSONB (12 seções):**
- Metadados de chunk, configuração de embedding, metadados de arquivo, extração, análise semântica, qualidade, analytics, segurança, otimização de busca, integração, versionamento, melhorias de IA

### **BENEFÍCIOS DESTA ESTRUTURA**

1. **Performance**: Colunas diretas para consultas frequentes e RLS
2. **Flexibilidade**: JSONB para evolução sem migrações
3. **Escalabilidade**: Índices vetoriais otimizados para pgvector
4. **Funcionalidades Avançadas**: Suporte completo a RAG e busca semântica
5. **Segurança**: Controle de acesso granular com class_info e restricts_stamps

### **CASOS DE USO PRINCIPAIS**

1. **Busca Semântica**: Busca por similaridade usando embeddings
2. **RAG (Retrieval Augmented Generation)**: Recuperação de conhecimento para IA
3. **Análise de Conteúdo**: Categorização e análise semântica
4. **Compliance**: Controle de acesso baseado em classificação
5. **Analytics**: Métricas de uso e qualidade do conhecimento

---

**Documento gerado em**: 2025-01-15  
**Versão**: 1.0  
**Status**: ✅ Pronto para implementação
