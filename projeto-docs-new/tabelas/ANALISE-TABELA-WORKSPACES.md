# 🏢 ANÁLISE DETALHADA - TABELA WORKSPACES

**Documento**: Análise de estrutura da tabela WORKSPACES para refatoração do backend  
**Versão**: 2.0  
**Data**: 2025-01-15  
**Status**: Implementado  
**Mudanças v2.0**: Adicionados triggers automáticos para criação de workspaces organizacionais e pessoais  
**Objetivo**: Definir estrutura otimizada para Workspaces com funcionalidades avançadas

---

## 🎯 TABELA WORKSPACES - ANÁLISE COMPLETA

### 📋 **COLUNAS HEADER (Diretas) - ESTRUTURA FINAL**

| Campo | Tipo | Constraints | Justificativa Detalhada |
|-------|------|-------------|-------------------------|
| `wksp_id` | UUID | PRIMARY KEY | **Identificador único global** - Usado em todas as operações CRUD, relacionamentos, RLS policies e URLs da aplicação. UUID garante unicidade distribuída e segurança. |
| `organization_id` | UUID | NOT NULL, FK → organizations(orgs_id) | **Multi-tenancy** - Define a organização dona do workspace. Essencial para RLS e isolamento de dados. Usado em 100% das consultas para filtragem por organização. |
| `wksp_name` | VARCHAR(255) | NOT NULL | **Identificação** - Nome do workspace exibido na UI. Usado para busca textual, ordenação alfabética e identificação visual. Limite 255 para performance e compatibilidade. |
| `wksp_type` | ENUM | NOT NULL | **Classificação** - `PERSONAL` ou `FUNCTIONAL`. Usado para lógica de negócio, permissões e comportamento da aplicação. Essencial para diferenciação de tipos. |
| `wksp_is_default` | BOOLEAN | NOT NULL DEFAULT FALSE | **Workspace padrão** - Indica se é o workspace padrão da organização. Usado para seleção automática e lógica de criação de usuários. |
| `wksp_created_at` | TIMESTAMP | NOT NULL DEFAULT NOW() | **Auditoria temporal** - Data de criação do workspace. Usado para ordenação cronológica, analytics e auditoria. |
| `wksp_updated_at` | TIMESTAMP | NOT NULL DEFAULT NOW() | **Última atividade** - Data da última atualização. Usado para ordenação, limpeza automática e analytics. |
| `wksp_is_active` | BOOLEAN | NOT NULL DEFAULT TRUE | **Soft delete** - Status ativo/inativo. Usado para soft delete, filtragem de workspaces ativos e lógica de negócio. |

### 🔧 **ENUM workspace_type_enum**
```sql
CREATE TYPE workspace_type_enum AS ENUM ('PERSONAL', 'FUNCTIONAL');
```

### 📦 **ATRIBUTOS JSONB - ESTRUTURA DETALHADA**

#### **1. basic_info** - Informações Básicas
```json
{
  "description": "Workspace de Vendas da Região Sul", // Descrição detalhada
  "icon": "💼",                    // Ícone do workspace
  "color": "#3498db",              // Cor principal
  "banner_url": "https://...",     // URL do banner
  "logo_url": "https://...",       // URL do logo
  "website": "https://vendas.empresa.com", // Website do workspace
  "timezone": "America/Sao_Paulo"  // Fuso horário
}
```
**Justificativa**: Informações de apresentação e identificação visual. Podem variar e evoluir sem impacto no schema.

#### **2. visibility_settings** - Configurações de Visibilidade
```json
{
  "visibility": "organization",     // public, organization, team, private
  "allow_guests": false,            // Permitir convidados
  "guest_permissions": [],          // Permissões para convidados
  "public_description": "Workspace público...", // Descrição pública
  "discoverable": true,             // Aparecer em buscas
  "require_approval": false         // Requer aprovação para entrar
}
```
**Justificativa**: Configurações de visibilidade e acesso. Específicas por workspace e podem evoluir com políticas de segurança.

#### **3. ownership_info** - Informações de Propriedade
```json
{
  "owner_user_id": "uuid-owner",    // Usuário dono do workspace
  "created_by_user_id": "uuid-creator", // Quem criou
  "department": "Sales",            // Departamento
  "team": "South Region",           // Time/equipe
  "cost_center": "CC-001",          // Centro de custo
  "budget_code": "BUD-2025-001"     // Código orçamentário
}
```
**Justificativa**: Informações organizacionais e de propriedade. Usadas para relatórios e controle, mas não para filtragem em larga escala.

#### **4. settings** - Configurações do Workspace
```json
{
  "auto_archive_chats_days": 90,    // Auto-arquivar chats após X dias
  "max_users": 50,                  // Máximo de usuários
  "max_storage_gb": 100,            // Máximo de armazenamento
  "default_companion_id": "uuid-companion", // Companion padrão
  "default_language": "pt-BR",      // Idioma padrão
  "timezone": "America/Sao_Paulo",  // Fuso horário padrão
  "date_format": "DD/MM/YYYY",      // Formato de data
  "currency": "BRL",                // Moeda padrão
  "working_hours": {                // Horário de funcionamento
    "start": "09:00",
    "end": "18:00",
    "timezone": "America/Sao_Paulo",
    "working_days": [1, 2, 3, 4, 5] // Seg-Sex
  }
}
```
**Justificativa**: Configurações específicas do workspace. Podem variar por workspace e evoluir com funcionalidades.

#### **5. features_enabled** - Funcionalidades Habilitadas
```json
{
  "rag_enabled": true,              // RAG habilitado
  "mcp_tools_enabled": true,        // Ferramentas MCP habilitadas
  "workflows_enabled": true,        // Workflows agênticos habilitados
  "analytics_enabled": true,        // Analytics habilitado
  "file_upload_enabled": true,      // Upload de arquivos habilitado
  "voice_enabled": false,           // Funcionalidade de voz
  "video_enabled": false,           // Funcionalidade de vídeo
  "collaboration_enabled": true,    // Colaboração em tempo real
  "version_control_enabled": true,  // Controle de versão
  "backup_enabled": true            // Backup automático
}
```
**Justificativa**: Controle de funcionalidades por workspace. Permite habilitar/desabilitar features sem alterar schema.

#### **6. security_policies** - Políticas de Segurança
```json
{
  "password_policy": {              // Política de senhas
    "min_length": 8,
    "require_special_chars": true,
    "require_numbers": true,
    "require_uppercase": true,
    "expire_days": 90
  },
  "session_policy": {               // Política de sessão
    "timeout_minutes": 480,         // 8 horas
    "max_concurrent_sessions": 3,
    "require_mfa": false
  },
  "data_retention": {               // Retenção de dados
    "chats_days": 365,
    "artifacts_days": 730,
    "logs_days": 90,
    "auto_delete": true
  },
  "ip_restrictions": {              // Restrições de IP
    "enabled": false,
    "allowed_ips": [],
    "blocked_ips": []
  },
  "encryption": {                   // Criptografia
    "level": "standard",            // standard, high, maximum
    "key_rotation_days": 90,
    "backup_encrypted": true
  }
}
```
**Justificativa**: Políticas de segurança específicas por workspace. Estrutura complexa que pode evoluir com regulamentações.

#### **7. integrations** - Integrações Externas
```json
{
  "slack": {                        // Integração Slack
    "enabled": false,
    "webhook_url": null,
    "channel": null,
    "notifications": {
      "new_chats": true,
      "workflow_completed": true,
      "errors": true
    }
  },
  "teams": {                        // Integração Microsoft Teams
    "enabled": false,
    "webhook_url": null,
    "channel": null
  },
  "email": {                        // Integração Email
    "enabled": true,
    "smtp_config": {
      "host": "smtp.empresa.com",
      "port": 587,
      "secure": true
    },
    "notifications": {
      "daily_summary": true,
      "weekly_report": true
    }
  },
  "calendar": {                     // Integração Calendário
    "enabled": false,
    "provider": "google",           // google, outlook, caldav
    "sync_enabled": false
  }
}
```
**Justificativa**: Configurações de integrações externas. Específicas por workspace e podem variar conforme necessidades.

#### **8. analytics_config** - Configuração de Analytics
```json
{
  "tracking_enabled": true,         // Rastreamento habilitado
  "metrics_to_track": [             // Métricas a rastrear
    "user_activity",
    "chat_volume",
    "tool_usage",
    "cost_analysis",
    "performance_metrics"
  ],
  "retention_days": 365,            // Retenção de dados de analytics
  "real_time_enabled": true,        // Analytics em tempo real
  "dashboard_config": {             // Configuração do dashboard
    "default_view": "overview",
    "refresh_interval": 300,        // 5 minutos
    "charts_enabled": true
  },
  "reports": {                      // Configuração de relatórios
    "daily_enabled": true,
    "weekly_enabled": true,
    "monthly_enabled": true,
    "recipients": ["admin@empresa.com"]
  }
}
```
**Justificativa**: Configurações específicas de analytics. Podem variar por workspace e evoluir com funcionalidades.

#### **9. billing_info** - Informações de Cobrança
```json
{
  "billing_enabled": true,          // Cobrança habilitada
  "plan": "enterprise",             // Plano atual
  "billing_cycle": "monthly",       // Ciclo de cobrança
  "cost_per_user": 50.00,           // Custo por usuário
  "included_features": [            // Funcionalidades incluídas
    "unlimited_chats",
    "rag_access",
    "mcp_tools",
    "analytics"
  ],
  "usage_limits": {                 // Limites de uso
    "max_chats_per_month": 1000,
    "max_tokens_per_month": 1000000,
    "max_storage_gb": 100
  },
  "payment_method": {               // Método de pagamento
    "type": "invoice",              // invoice, credit_card, bank_transfer
    "billing_email": "finance@empresa.com",
    "po_number": "PO-2025-001"
  }
}
```
**Justificativa**: Informações de cobrança e limites. Específicas por workspace e podem variar conforme planos.

#### **10. organogram** - Estrutura Organizacional
```json
{
  "parent_workspace_id": null,      // Workspace pai (hierarquia)
  "child_workspaces": [             // Workspaces filhos
    "uuid-workspace-1",
    "uuid-workspace-2"
  ],
  "department_hierarchy": {         // Hierarquia departamental
    "level": 1,
    "parent_department": null,
    "child_departments": ["Sales", "Marketing"]
  },
  "reporting_structure": {          // Estrutura de relatórios
    "reports_to_workspace": null,
    "manages_workspaces": ["uuid-1", "uuid-2"]
  }
}
```
**Justificativa**: Estrutura organizacional complexa. Permite hierarquias flexíveis sem alterar schema.

#### **11. templates** - Templates e Configurações Padrão
```json
{
  "chat_templates": [               // Templates de chat
    {
      "id": "uuid-template-1",
      "name": "Reunião de Vendas",
      "description": "Template para reuniões de vendas",
      "companion_id": "uuid-companion",
      "system_prompt": "Você é um assistente de vendas...",
      "tools_enabled": ["mcp-database", "mcp-email"]
    }
  ],
  "companion_templates": [          // Templates de companions
    {
      "id": "uuid-companion-template",
      "name": "Assistente de Vendas",
      "description": "Companion especializado em vendas",
      "instructions": "Você é um especialista em vendas...",
      "skills": ["prospecting", "negotiation", "closing"]
    }
  ],
  "workflow_templates": [           // Templates de workflows
    {
      "id": "uuid-workflow-template",
      "name": "Processo de Vendas",
      "description": "Workflow completo de vendas",
      "steps": ["qualification", "proposal", "negotiation", "closing"]
    }
  ]
}
```
**Justificativa**: Templates específicos do workspace. Permitem padronização e reutilização de configurações.

#### **12. compliance** - Conformidade e Auditoria
```json
{
  "data_classification": "internal", // Classificação dos dados
  "compliance_standards": [          // Padrões de conformidade
    "GDPR",
    "LGPD",
    "SOX"
  ],
  "audit_requirements": {            // Requisitos de auditoria
    "log_all_actions": true,
    "retention_years": 7,
    "encryption_required": true,
    "access_logging": true
  },
  "data_residency": "BR",            // Residência dos dados
  "backup_policy": {                 // Política de backup
    "frequency": "daily",
    "retention_days": 30,
    "encryption": true,
    "offsite": true
  },
  "disaster_recovery": {             // Recuperação de desastres
    "rto_hours": 4,                  // Recovery Time Objective
    "rpo_hours": 1,                  // Recovery Point Objective
    "backup_location": "secondary-datacenter"
  }
}
```
**Justificativa**: Configurações de conformidade e auditoria. Específicas por organização e podem evoluir com regulamentações.

### 📊 **ÍNDICES RECOMENDADOS**

```sql
-- Índices existentes (manter)
CREATE INDEX idx_workspaces_org ON workspaces(organization_id);
CREATE INDEX idx_workspaces_type ON workspaces(wksp_type);
CREATE INDEX idx_workspaces_default ON workspaces(wksp_is_default) WHERE wksp_is_default = TRUE;

-- Novos índices para workspaces
CREATE INDEX idx_workspaces_active ON workspaces(wksp_is_active) WHERE wksp_is_active = TRUE;
CREATE INDEX idx_workspaces_updated ON workspaces(wksp_updated_at DESC);

-- Índices compostos para consultas frequentes
CREATE INDEX idx_workspaces_org_type ON workspaces(organization_id, wksp_type);
CREATE INDEX idx_workspaces_org_active ON workspaces(organization_id, wksp_is_active);
CREATE INDEX idx_workspaces_type_active ON workspaces(wksp_type, wksp_is_active);

-- Índices JSONB para consultas específicas
CREATE INDEX idx_workspaces_visibility ON workspaces USING GIN ((attributes->'visibility_settings'->>'visibility'));
CREATE INDEX idx_workspaces_department ON workspaces USING GIN ((attributes->'ownership_info'->>'department'));
CREATE INDEX idx_workspaces_team ON workspaces USING GIN ((attributes->'ownership_info'->>'team'));
CREATE INDEX idx_workspaces_features ON workspaces USING GIN ((attributes->'features_enabled'));
CREATE INDEX idx_workspaces_billing_plan ON workspaces USING GIN ((attributes->'billing_info'->>'plan'));
CREATE INDEX idx_workspaces_compliance ON workspaces USING GIN ((attributes->'compliance'->>'data_classification'));

-- Índice para busca full-text no nome
CREATE INDEX idx_workspaces_name_fts ON workspaces USING GIN (to_tsvector('portuguese', wksp_name));
```

---

## 🎯 **RESUMO EXECUTIVO - TABELA WORKSPACES**

### **COLUNAS HEADER (8 campos):**
- **Identificadores**: `id`, `organization_id`
- **Identificação**: `name`, `workspace_type`
- **Estado**: `is_default`, `is_active`
- **Temporais**: `created_at`, `updated_at`

### **ATRIBUTOS JSONB (12 seções):**
- Informações básicas, visibilidade, segurança, integrações, compliance

### **BENEFÍCIOS DESTA ESTRUTURA**

1. **Performance**: Colunas diretas para consultas frequentes
2. **Flexibilidade**: JSONB para evolução sem migrações
3. **Escalabilidade**: Índices otimizados para crescimento
4. **Manutenibilidade**: Estrutura clara e documentada
5. **Funcionalidades Avançadas**: Suporte a integrações e compliance

---

## 📜 SCRIPT SQL DE CRIAÇÃO COMPLETO

```sql
-- ============================================
-- TABELA: WORKSPACES
-- Descrição: Workspaces para organização de companions, chats e recursos
-- Multi-tenancy: organization_id
-- ============================================

-- Criar ENUM
CREATE TYPE workspace_type_enum AS ENUM ('PERSONAL', 'FUNCTIONAL');

-- Criar tabela
CREATE TABLE workspaces (
  -- ============================================
  -- IDENTIFICAÇÃO
  -- ============================================
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  name VARCHAR(255) NOT NULL,
  workspace_type workspace_type_enum NOT NULL,
  
  -- ============================================
  -- ESTADO
  -- ============================================
  is_default BOOLEAN NOT NULL DEFAULT FALSE,
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
  CONSTRAINT check_name_not_empty CHECK (LENGTH(TRIM(name)) > 0)
);

-- ============================================
-- ÍNDICES
-- ============================================

-- Índices para relacionamentos
CREATE INDEX idx_workspaces_org ON workspaces(organization_id);

-- Índices para tipo e estado
CREATE INDEX idx_workspaces_type ON workspaces(workspace_type);
CREATE INDEX idx_workspaces_default ON workspaces(is_default) WHERE is_default = TRUE;
CREATE INDEX idx_workspaces_active ON workspaces(is_active) WHERE is_active = TRUE;

-- Índice para ordenação
CREATE INDEX idx_workspaces_updated ON workspaces(updated_at DESC);

-- Índices compostos para consultas frequentes
CREATE INDEX idx_workspaces_org_type ON workspaces(organization_id, workspace_type);
CREATE INDEX idx_workspaces_org_active ON workspaces(organization_id, is_active);
CREATE INDEX idx_workspaces_type_active ON workspaces(workspace_type, is_active);

-- Índices JSONB para consultas específicas
CREATE INDEX idx_workspaces_visibility ON workspaces 
  USING GIN ((attributes->'visibility_settings'->>'visibility'));
CREATE INDEX idx_workspaces_department ON workspaces 
  USING GIN ((attributes->'ownership_info'->>'department'));
CREATE INDEX idx_workspaces_team ON workspaces 
  USING GIN ((attributes->'ownership_info'->>'team'));
CREATE INDEX idx_workspaces_features ON workspaces 
  USING GIN ((attributes->'features_enabled'));
CREATE INDEX idx_workspaces_billing_plan ON workspaces 
  USING GIN ((attributes->'billing_info'->>'plan'));
CREATE INDEX idx_workspaces_compliance ON workspaces 
  USING GIN ((attributes->'compliance'->>'data_classification'));

-- Índice para busca full-text no nome
CREATE INDEX idx_workspaces_name_fts ON workspaces 
  USING GIN (to_tsvector('portuguese', name));

-- ============================================
-- COMENTÁRIOS
-- ============================================
COMMENT ON TABLE workspaces IS 
  'Workspaces para organização de companions, chats e recursos por equipe/departamento';

COMMENT ON COLUMN workspaces.workspace_type IS 
  'PERSONAL = workspace pessoal do usuário, FUNCTIONAL = workspace de equipe/departamento';

COMMENT ON COLUMN workspaces.is_default IS 
  'Workspace padrão da organização (apenas um por org)';

COMMENT ON COLUMN workspaces.attributes IS 
  'Atributos extensíveis em JSONB: basic_info, visibility_settings, ownership_info, settings, features_enabled, security_policies, integrations, analytics_config, billing_info, organogram, templates, compliance';

-- ============================================
-- TRIGGER PARA UPDATED_AT
-- ============================================
CREATE OR REPLACE FUNCTION update_workspaces_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_workspaces_updated_at
  BEFORE UPDATE ON workspaces
  FOR EACH ROW
  EXECUTE FUNCTION update_workspaces_updated_at();

-- ============================================
-- TRIGGERS DE CRIAÇÃO AUTOMÁTICA
-- ============================================
-- Workspace Padrão da Organização
CREATE OR REPLACE FUNCTION create_default_workspace_for_org()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO workspaces (
    organization_id,
    wksp_name,
    wksp_type,
    wksp_is_default,
    wksp_is_active
  ) VALUES (
    NEW.orgs_id,
    'Workspace ' || NEW.orgs_name,
    'FUNCTIONAL',
    TRUE,
    TRUE
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_create_default_workspace
  AFTER INSERT ON organizations
  FOR EACH ROW
  EXECUTE FUNCTION create_default_workspace_for_org();

-- Workspace Pessoal do Usuário
CREATE OR REPLACE FUNCTION create_personal_workspace_for_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO workspaces (
    organization_id,
    wksp_name,
    wksp_type,
    wksp_is_default,
    wksp_is_active
  ) VALUES (
    NEW.organization_id,
    'Myworkspace',
    'PERSONAL',
    TRUE,
    TRUE
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_create_personal_workspace
  AFTER INSERT ON users
  FOR EACH ROW
  EXECUTE FUNCTION create_personal_workspace_for_user();

-- ============================================
-- RLS (Row Level Security)
-- ============================================
ALTER TABLE workspaces ENABLE ROW LEVEL SECURITY;

-- Policy: Users can only see workspaces from their organization
CREATE POLICY workspaces_select_policy ON workspaces
  FOR SELECT
  USING (organization_id = current_setting('app.current_organization_id')::uuid);

-- Policy: Only org admins can insert workspaces
CREATE POLICY workspaces_insert_policy ON workspaces
  FOR INSERT
  WITH CHECK (
    organization_id = current_setting('app.current_organization_id')::uuid
    AND current_setting('app.current_user_role') IN ('MS', 'OA')
  );

-- Policy: Only org admins and workspace managers can update workspaces
CREATE POLICY workspaces_update_policy ON workspaces
  FOR UPDATE
  USING (
    organization_id = current_setting('app.current_organization_id')::uuid
    AND current_setting('app.current_user_role') IN ('MS', 'OA', 'WM')
  );

-- Policy: Only org admins can delete workspaces
CREATE POLICY workspaces_delete_policy ON workspaces
  FOR DELETE
  USING (
    organization_id = current_setting('app.current_organization_id')::uuid
    AND current_setting('app.current_user_role') IN ('MS', 'OA')
  );
```

---

**Documento gerado em**: 2025-01-15  
**Versão**: 2.0  
**Status**: ✅ Completo com SQL
