# 🔧 ANÁLISE DETALHADA - TABELA TOOLS_MCP

**Documento**: Análise de estrutura da tabela TOOLS_MCP para refatoração do backend  
**Versão**: 1.0  
**Data**: 2025-01-15  
**Objetivo**: Definir estrutura otimizada para ferramentas MCP (Model Context Protocol)

---

## 🎯 TABELA TOOLS_MCP - ANÁLISE COMPLETA

### 📋 **COLUNAS HEADER (Diretas) - ESTRUTURA FINAL**

| Campo | Tipo | Constraints | Justificativa Detalhada |
|-------|------|-------------|-------------------------|
| `tool_id` | UUID | PRIMARY KEY | **Identificador único global** - Usado em todas as operações CRUD, relacionamentos, RLS policies e URLs da aplicação. UUID garante unicidade distribuída e segurança. |
| `organization_id` | UUID | NOT NULL, FK → organizations(orgs_id) | **Multi-tenancy** - Define a organização dona da ferramenta. Essencial para RLS e isolamento de dados. Usado em 100% das consultas para filtragem por organização. |
| `configured_by_user_id` | UUID | NOT NULL, FK → users(user_id) | **Propriedade** - Define quem configurou a ferramenta. Essencial para auditoria e controle de acesso. Usado para rastreabilidade e permissões. |
| `tool_name` | VARCHAR(255) | NOT NULL | **Identificação** - Nome da ferramenta exibido na UI. Usado para busca textual, ordenação alfabética e identificação visual. Limite 255 para performance e compatibilidade. |
| `tool_type` | ENUM | NOT NULL | **Classificação** - `DATABASE`, `API`, `FILESYSTEM`, `CUSTOM`. Usado para lógica de negócio, validação e comportamento específico por tipo. Essencial para funcionalidade core. |
| `tool_auth_type` | ENUM | NOT NULL | **Tipo de autenticação** - `BEARER`, `OAUTH`, `API_KEY`, `NONE`. Usado para validação de credenciais e configuração de segurança. Essencial para funcionalidade de autenticação. |
| `tool_attributes` | JSONB | NOT NULL DEFAULT '{}' | **Atributos JSONB** - Configurações e metadados (basic_info, auth_config, connection_config, performance_metrics, compliance_audit, monitoring_alerting, ai_enhancement). Estrutura complexa que varia por tipo. |
| `tool_is_active` | BOOLEAN | NOT NULL DEFAULT TRUE | **Soft delete** - Status ativo/inativo. Usado para soft delete, filtragem de ferramentas ativas e lógica de negócio. |
| `tool_created_at` | TIMESTAMP | NOT NULL DEFAULT NOW() | **Auditoria temporal** - Data de criação da ferramenta. Usado para ordenação cronológica, analytics e auditoria. |
| `tool_updated_at` | TIMESTAMP | NOT NULL DEFAULT NOW() | **Última modificação** - Data da última atualização. Usado para ordenação por atividade, versionamento e analytics. |

### 🔧 **ENUMs**
```sql
CREATE TYPE tool_type_enum AS ENUM ('DATABASE', 'API', 'FILESYSTEM', 'CUSTOM');
CREATE TYPE auth_type_enum AS ENUM ('BEARER', 'OAUTH', 'API_KEY', 'NONE');
```

### 📦 **ATRIBUTOS JSONB - ESTRUTURA DETALHADA**

#### **1. basic_info** - Informações Básicas
```json
{
  "description": "Ferramenta para consulta de banco de dados PostgreSQL", // Descrição detalhada
  "version": "1.2.0",                // Versão da ferramenta
  "category": "database",             // Categoria da ferramenta
  "tags": ["postgresql", "database", "sql"], // Tags para busca
  "icon": "🗄️",                      // Ícone da ferramenta
  "color": "#3498db",                // Cor da ferramenta
  "website": "https://postgresql.org", // Website oficial
  "documentation_url": "https://docs.postgresql.org", // URL da documentação
  "support_email": "support@empresa.com" // Email de suporte
}
```
**Justificativa**: Informações de apresentação e identificação. Podem variar e evoluir sem impacto no schema.

#### **2. execution_config** - Configuração de Execução
```json
{
  "timeout_seconds": 30,             // Timeout para execução
  "retry_attempts": 3,               // Número de tentativas
  "retry_delay_seconds": 5,          // Delay entre tentativas
  "max_concurrent_executions": 10,   // Máximo de execuções simultâneas
  "rate_limit": {                    // Limite de taxa
    "requests_per_minute": 60,
    "requests_per_hour": 1000,
    "burst_limit": 10
  },
  "circuit_breaker": {               // Circuit breaker
    "enabled": true,
    "failure_threshold": 5,
    "recovery_timeout_seconds": 60
  },
  "caching": {                       // Configuração de cache
    "enabled": true,
    "ttl_seconds": 300,
    "max_size_mb": 100
  }
}
```
**Justificativa**: Configurações específicas de execução. Podem variar por ferramenta e evoluir com funcionalidades.

#### **3. security_settings** - Configurações de Segurança
```json
{
  "encryption_enabled": true,        // Criptografia habilitada
  "encryption_key_id": "uuid-key-1", // ID da chave de criptografia
  "ssl_required": true,              // SSL obrigatório
  "certificate_validation": true,    // Validação de certificado
  "ip_whitelist": [                  // Lista de IPs permitidos
    "192.168.1.0/24",
    "10.0.0.0/8"
  ],
  "allowed_domains": [               // Domínios permitidos
    "api.empresa.com",
    "database.empresa.com"
  ],
  "permission_requirements": [       // Permissões necessárias
    "database:read",
    "database:write"
  ],
  "audit_logging": true,             // Log de auditoria
  "sensitive_data_masking": true     // Mascaramento de dados sensíveis
}
```
**Justificativa**: Configurações de segurança específicas por ferramenta. Estrutura complexa que pode evoluir com políticas de segurança.

#### **4. credentials_management** - Gerenciamento de Credenciais
```json
{
  "credentials_storage": "vault",    // Onde as credenciais são armazenadas
  "vault_key": "kms-key-id",         // Chave do vault
  "encrypted": true,                 // Se as credenciais estão criptografadas
  "expires_at": "2026-01-01T00:00:00Z", // Data de expiração
  "rotation_enabled": true,          // Rotação automática habilitada
  "rotation_interval_days": 90,      // Intervalo de rotação
  "last_rotation": "2025-01-15T10:00:00Z", // Última rotação
  "credential_types": [              // Tipos de credenciais
    "username_password",
    "api_key",
    "oauth_token"
  ],
  "backup_credentials": true         // Backup das credenciais
}
```
**Justificativa**: Gerenciamento seguro de credenciais. Essencial para segurança e pode evoluir com sistemas de vault.

#### **5. usage_analytics** - Analytics de Uso
```json
{
  "total_executions": 1542,          // Total de execuções
  "successful_executions": 1480,     // Execuções bem-sucedidas
  "failed_executions": 62,           // Execuções com falha
  "avg_response_time_ms": 250,       // Tempo médio de resposta
  "last_used_at": "2025-01-15T10:30:00Z", // Último uso
  "usage_by_user": [                 // Uso por usuário
    {
      "user_id": "uuid-user-1",
      "executions": 45,
      "last_used": "2025-01-15T10:00:00Z"
    }
  ],
  "usage_by_companion": [            // Uso por companion
    {
      "companion_id": "uuid-companion-1",
      "executions": 120,
      "last_used": "2025-01-15T09:30:00Z"
    }
  ],
  "error_analytics": {               // Analytics de erros
    "error_count": 62,
    "error_rate": 0.04,
    "common_errors": [
      {
        "error_type": "timeout",
        "count": 25,
        "percentage": 40.3
      },
      {
        "error_type": "authentication",
        "count": 20,
        "percentage": 32.3
      }
    ]
  }
}
```
**Justificativa**: Analytics de uso para otimização e monitoramento. Usadas para relatórios e melhorias.

#### **6. performance_metrics** - Métricas de Performance
```json
{
  "avg_latency_ms": 250,             // Latência média
  "p95_latency_ms": 500,             // Latência P95
  "p99_latency_ms": 1000,            // Latência P99
  "throughput_per_second": 2.5,      // Throughput por segundo
  "cpu_usage_percent": 15.5,         // Uso de CPU
  "memory_usage_mb": 128,            // Uso de memória
  "disk_usage_mb": 256,              // Uso de disco
  "network_io_mb": 1024,             // I/O de rede
  "concurrent_connections": 5,       // Conexões simultâneas
  "queue_length": 2,                 // Tamanho da fila
  "performance_trend": "stable"      // Tendência de performance
}
```
**Justificativa**: Métricas de performance para monitoramento e otimização. Essenciais para operações.

#### **7. integration_settings** - Configurações de Integração
```json
{
  "webhook_endpoints": [             // Endpoints de webhook
    {
      "url": "https://api.empresa.com/webhooks/tool-execution",
      "events": ["execution_started", "execution_completed", "execution_failed"],
      "secret": "webhook-secret",
      "enabled": true
    }
  ],
  "api_endpoints": [                 // Endpoints da API
    {
      "name": "execute_tool",
      "method": "POST",
      "path": "/api/tools/{tool_id}/execute",
      "description": "Executa a ferramenta"
    }
  ],
  "sdk_integration": {               // Integração com SDK
    "sdk_version": "1.0.0",
    "supported_languages": ["javascript", "python", "java"],
    "documentation_url": "https://docs.empresa.com/sdk"
  },
  "external_dependencies": [         // Dependências externas
    {
      "name": "postgresql",
      "version": "14.0",
      "required": true
    }
  ]
}
```
**Justificativa**: Configurações de integração com sistemas externos. Específicas por implementação e podem variar.

#### **8. monitoring_alerting** - Monitoramento e Alertas
```json
{
  "monitoring_enabled": true,        // Monitoramento habilitado
  "health_check_interval_seconds": 60, // Intervalo de health check
  "alerts_enabled": true,            // Alertas habilitados
  "alert_conditions": [              // Condições de alerta
    {
      "metric": "error_rate",
      "threshold": 0.1,
      "operator": ">",
      "severity": "warning"
    },
    {
      "metric": "response_time",
      "threshold": 1000,
      "operator": ">",
      "severity": "critical"
    }
  ],
  "notification_channels": [         // Canais de notificação
    {
      "type": "email",
      "address": "admin@empresa.com",
      "enabled": true
    },
    {
      "type": "slack",
      "webhook_url": "https://hooks.slack.com/...",
      "enabled": true
    }
  ],
  "dashboards": [                    // Dashboards configurados
    {
      "name": "Tool Performance",
      "url": "https://grafana.empresa.com/d/tool-performance",
      "refresh_interval": 300
    }
  ]
}
```
**Justificativa**: Configurações de monitoramento e alertas. Essenciais para operações e podem evoluir com ferramentas.

#### **9. compliance_audit** - Compliance e Auditoria
```json
{
  "data_classification": "internal", // Classificação dos dados
  "compliance_standards": [          // Padrões de compliance
    "GDPR",
    "LGPD",
    "SOX"
  ],
  "audit_requirements": {            // Requisitos de auditoria
    "log_all_executions": true,
    "log_input_output": false,       // Dados sensíveis
    "retention_days": 2555,          // 7 anos
    "encryption_required": true
  },
  "data_residency": "BR",            // Residência dos dados
  "backup_policy": {                 // Política de backup
    "frequency": "daily",
    "retention_days": 30,
    "encryption": true
  },
  "access_controls": {               // Controles de acesso
    "require_approval": false,
    "max_access_duration_hours": 24,
    "session_timeout_minutes": 480
  }
}
```
**Justificativa**: Configurações de compliance e auditoria. Específicas por organização e podem evoluir com regulamentações.

#### **10. error_handling** - Tratamento de Erros
```json
{
  "error_handling_strategy": "retry_with_fallback", // Estratégia de tratamento
  "fallback_tool_id": "uuid-fallback-tool", // Ferramenta de fallback
  "error_categories": [              // Categorias de erro
    {
      "category": "network",
      "retry_count": 3,
      "retry_delay_seconds": 5
    },
    {
      "category": "authentication",
      "retry_count": 1,
      "retry_delay_seconds": 10
    }
  ],
  "error_notifications": {           // Notificações de erro
    "enabled": true,
    "threshold": 5,                  // Número de erros para notificar
    "cooldown_minutes": 30           // Cooldown entre notificações
  },
  "error_recovery": {                // Recuperação de erro
    "auto_recovery": true,
    "recovery_actions": [
      "restart_connection",
      "refresh_credentials",
      "fallback_to_backup"
    ]
  }
}
```
**Justificativa**: Configurações de tratamento de erros. Específicas da implementação e podem variar por ferramenta.

#### **11. testing_validation** - Testes e Validação
```json
{
  "test_enabled": true,              // Testes habilitados
  "test_frequency": "daily",         // Frequência dos testes
  "test_scenarios": [                // Cenários de teste
    {
      "name": "basic_connection",
      "description": "Testa conexão básica",
      "enabled": true
    },
    {
      "name": "authentication",
      "description": "Testa autenticação",
      "enabled": true
    }
  ],
  "validation_rules": [              // Regras de validação
    {
      "field": "config_data.connection_string",
      "type": "required",
      "message": "Connection string é obrigatória"
    }
  ],
  "test_results": {                  // Resultados dos testes
    "last_test_at": "2025-01-15T10:00:00Z",
    "success_rate": 0.95,
    "last_failure": null
  }
}
```
**Justificativa**: Configurações de testes e validação. Essenciais para qualidade e podem evoluir com ferramentas.

#### **12. ai_integration** - Integração com IA
```json
{
  "ai_enabled": true,                // IA habilitada
  "ai_model": "gpt-4o",              // Modelo de IA usado
  "ai_prompts": {                    // Prompts de IA
    "description": "Descreva o que esta ferramenta faz",
    "usage": "Como usar esta ferramenta",
    "troubleshooting": "Como resolver problemas comuns"
  },
  "ai_optimization": {               // Otimização de IA
    "auto_optimize": true,
    "optimization_frequency": "weekly",
    "last_optimization": "2025-01-15T10:00:00Z"
  },
  "ai_insights": {                   // Insights de IA
    "usage_patterns": "Padrões de uso identificados",
    "optimization_suggestions": "Sugestões de otimização",
    "performance_insights": "Insights de performance"
  }
}
```
**Justificativa**: Integração com IA para otimização e insights. Específica da implementação e pode evoluir com modelos.

### 📊 **ÍNDICES RECOMENDADOS**

```sql
-- Índices existentes (manter)
CREATE INDEX idx_tools_org ON tools_mcp(organization_id);
CREATE INDEX idx_tools_type ON tools_mcp(tool_type);
CREATE INDEX idx_tools_auth ON tools_mcp(tool_auth_type);
CREATE INDEX idx_tools_active ON tools_mcp(tool_is_active) WHERE tool_is_active = TRUE;

-- Novos índices para tools_mcp
CREATE INDEX idx_tools_configured_by ON tools_mcp(configured_by_user_id);
CREATE INDEX idx_tools_updated ON tools_mcp(tool_updated_at DESC);

-- Índices compostos para consultas frequentes
CREATE INDEX idx_tools_org_type ON tools_mcp(organization_id, tool_type);
CREATE INDEX idx_tools_org_active ON tools_mcp(organization_id, tool_is_active);
CREATE INDEX idx_tools_type_active ON tools_mcp(tool_type, tool_is_active);

-- Índices JSONB para consultas específicas
CREATE INDEX idx_tools_category ON tools_mcp USING GIN ((tool_attributes->'basic_info'->>'category'));
CREATE INDEX idx_tools_tags ON tools_mcp USING GIN ((tool_attributes->'basic_info'->'tags'));
CREATE INDEX idx_tools_version ON tools_mcp USING GIN ((tool_attributes->'basic_info'->>'version'));
CREATE INDEX idx_tools_performance ON tools_mcp USING GIN ((tool_attributes->'performance_metrics'));
CREATE INDEX idx_tools_compliance ON tools_mcp USING GIN ((tool_attributes->'compliance_audit'->>'data_classification'));
CREATE INDEX idx_tools_monitoring ON tools_mcp USING GIN ((tool_attributes->'monitoring_alerting'->>'monitoring_enabled'));

-- Índice para busca full-text no nome
CREATE INDEX idx_tools_name_fts ON tools_mcp USING GIN (to_tsvector('portuguese', tool_name));
```

---

## 🎯 **RESUMO EXECUTIVO - TABELA TOOLS_MCP**

### **COLUNAS HEADER (10 campos):**
- **Identificadores**: `id`, `organization_id`, `configured_by_user_id`
- **Identificação**: `tool_name`, `tool_type`, `auth_type`
- **Configuração**: `config_data` (JSONB)
- **Estado**: `is_active`
- **Temporais**: `created_at`, `updated_at`

### **ATRIBUTOS JSONB (12 seções):**
- Informações básicas, execução, segurança, credenciais, analytics, performance, integração, monitoramento, compliance, tratamento de erros, testes, integração com IA

### **BENEFÍCIOS DESTA ESTRUTURA**

1. **Performance**: Colunas diretas para consultas frequentes e RLS
2. **Flexibilidade**: JSONB para evolução sem migrações
3. **Escalabilidade**: Índices otimizados para crescimento
4. **Funcionalidades Avançadas**: Suporte completo a MCP e integrações
5. **Segurança**: Gerenciamento seguro de credenciais e compliance

### **CASOS DE USO PRINCIPAIS**

1. **Integração MCP**: Ferramentas para companions executarem ações
2. **Gerenciamento de Credenciais**: Armazenamento seguro de credenciais
3. **Monitoramento**: Analytics e alertas de performance
4. **Compliance**: Auditoria e conformidade regulatória
5. **Testes**: Validação e testes automatizados

---

## 📜 SCRIPT SQL DE CRIAÇÃO COMPLETO

```sql
-- ============================================
-- TABELA: TOOLS_MCP
-- Descrição: Ferramentas MCP (Model Context Protocol)
-- Multi-tenancy: organization_id
-- ============================================

-- Criar ENUMs
CREATE TYPE tool_type_enum AS ENUM ('DATABASE', 'API', 'FILESYSTEM', 'CUSTOM');
CREATE TYPE auth_type_enum AS ENUM ('BEARER', 'OAUTH', 'API_KEY', 'NONE');

-- Criar tabela
CREATE TABLE tools_mcp (
  -- ============================================
  -- IDENTIFICAÇÃO
  -- ============================================
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  configured_by_user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  tool_name VARCHAR(255) NOT NULL,
  
  -- ============================================
  -- TIPO E AUTENTICAÇÃO
  -- ============================================
  tool_type tool_type_enum NOT NULL,
  auth_type auth_type_enum NOT NULL,
  
  -- ============================================
  -- CONFIGURAÇÃO (JSONB)
  -- ============================================
  config_data JSONB NOT NULL DEFAULT '{}'::jsonb,
  
  -- ============================================
  -- ESTADO
  -- ============================================
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  
  -- ============================================
  -- AUDITORIA
  -- ============================================
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
  
  -- ============================================
  -- ATRIBUTOS EXTENSÍVEIS (JSONB)
  -- ============================================
  attributes JSONB NOT NULL DEFAULT '{}'::jsonb,
  
  -- ============================================
  -- CONSTRAINTS
  -- ============================================
  CONSTRAINT check_tool_name_not_empty CHECK (LENGTH(TRIM(tool_name)) > 0)
);

-- ============================================
-- ÍNDICES
-- ============================================

-- Índices para relacionamentos
CREATE INDEX idx_tools_org ON tools_mcp(organization_id);
CREATE INDEX idx_tools_configured_by ON tools_mcp(configured_by_user_id);

-- Índices para tipo e autenticação
CREATE INDEX idx_tools_type ON tools_mcp(tool_type);
CREATE INDEX idx_tools_auth ON tools_mcp(tool_auth_type);
CREATE INDEX idx_tools_active ON tools_mcp(tool_is_active) WHERE tool_is_active = TRUE;

-- Índice para ordenação
CREATE INDEX idx_tools_updated ON tools_mcp(tool_updated_at DESC);

-- Índices compostos para consultas frequentes
CREATE INDEX idx_tools_org_type ON tools_mcp(organization_id, tool_type);
CREATE INDEX idx_tools_org_active ON tools_mcp(organization_id, tool_is_active);
CREATE INDEX idx_tools_type_active ON tools_mcp(tool_type, tool_is_active);

-- Índices JSONB para consultas específicas em tool_attributes
CREATE INDEX idx_tools_category ON tools_mcp 
  USING GIN ((tool_attributes->'basic_info'->>'category'));
CREATE INDEX idx_tools_tags ON tools_mcp 
  USING GIN ((tool_attributes->'basic_info'->'tags'));
CREATE INDEX idx_tools_version ON tools_mcp 
  USING GIN ((tool_attributes->'basic_info'->>'version'));
CREATE INDEX idx_tools_performance ON tools_mcp 
  USING GIN ((tool_attributes->'performance_metrics'));
CREATE INDEX idx_tools_compliance ON tools_mcp 
  USING GIN ((tool_attributes->'compliance_audit'->>'data_classification'));
CREATE INDEX idx_tools_monitoring ON tools_mcp 
  USING GIN ((tool_attributes->'monitoring_alerting'->>'monitoring_enabled'));

-- Índice GIN geral para config_data
CREATE INDEX idx_tools_config_data_gin ON tools_mcp 
  USING GIN (tool_attributes);

-- Índice para busca full-text no nome
CREATE INDEX idx_tools_name_fts ON tools_mcp 
  USING GIN (to_tsvector('portuguese', tool_name));

-- ============================================
-- COMENTÁRIOS
-- ============================================
COMMENT ON TABLE tools_mcp IS 
  'Ferramentas MCP (Model Context Protocol) para integração com companions e skills';

COMMENT ON COLUMN tools_mcp.tool_type IS 
  'Tipo da ferramenta: DATABASE, API, FILESYSTEM, CUSTOM';

COMMENT ON COLUMN tools_mcp.auth_type IS 
  'Tipo de autenticação: BEARER, OAUTH, API_KEY, NONE';

COMMENT ON COLUMN tools_mcp.config_data IS 
  'Dados de configuração específicos por tipo de ferramenta (endpoints, connection strings, etc.)';

COMMENT ON COLUMN tools_mcp.attributes IS 
  'Atributos extensíveis em JSONB: basic_info, execution_config, security_settings, credentials_management, usage_analytics, performance_metrics, integration_settings, monitoring_alerting, compliance_audit, error_handling, testing_validation, ai_integration';

-- ============================================
-- TRIGGER PARA UPDATED_AT
-- ============================================
CREATE OR REPLACE FUNCTION update_tools_mcp_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_tools_mcp_updated_at
  BEFORE UPDATE ON tools_mcp
  FOR EACH ROW
  EXECUTE FUNCTION update_tools_mcp_updated_at();

-- ============================================
-- RLS (Row Level Security)
-- ============================================
ALTER TABLE tools_mcp ENABLE ROW LEVEL SECURITY;

-- Policy: Users can only see tools from their organization
CREATE POLICY tools_mcp_select_policy ON tools_mcp
  FOR SELECT
  USING (organization_id = current_setting('app.current_organization_id')::uuid);

-- Policy: Only org admins and workspace managers can insert tools
CREATE POLICY tools_mcp_insert_policy ON tools_mcp
  FOR INSERT
  WITH CHECK (
    organization_id = current_setting('app.current_organization_id')::uuid
    AND current_setting('app.current_user_role') IN ('MS', 'OA', 'WM')
  );

-- Policy: Only org admins, workspace managers, and tool owner can update tools
CREATE POLICY tools_mcp_update_policy ON tools_mcp
  FOR UPDATE
  USING (
    organization_id = current_setting('app.current_organization_id')::uuid
    AND (
      current_setting('app.current_user_role') IN ('MS', 'OA', 'WM')
      OR configured_by_user_id = current_setting('app.current_user_id')::uuid
    )
  );

-- Policy: Only org admins and tool owner can delete tools
CREATE POLICY tools_mcp_delete_policy ON tools_mcp
  FOR DELETE
  USING (
    organization_id = current_setting('app.current_organization_id')::uuid
    AND (
      current_setting('app.current_user_role') IN ('MS', 'OA')
      OR configured_by_user_id = current_setting('app.current_user_id')::uuid
    )
  );
```

---

**Documento gerado em**: 2025-01-15  
**Versão**: 2.0  
**Status**: ✅ Completo com SQL
