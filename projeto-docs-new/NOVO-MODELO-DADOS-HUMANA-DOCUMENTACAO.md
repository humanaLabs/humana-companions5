# 🏢 MODELO DE DADOS - PLATAFORMA HUMANA COMPANIONS v2.0

## 📋 ÍNDICE

1. [Visão Geral](#visão-geral)
2. [Princípios de Design](#princípios-de-design)
3. [Tabelas Core](#tabelas-core)
4. [Tabelas AI/Agênticas](#tabelas-aiagênticas)
5. [Tabelas Centrais/Compartilhadas](#tabelas-centraiscompartilhadas)
6. [Enumerações (ENUMs)](#enumerações-enums)
7. [Relacionamentos](#relacionamentos)
8. [Segurança e Isolamento](#segurança-e-isolamento)
9. [Índices e Performance](#índices-e-performance)
10. [Schemas JSONB](#schemas-jsonb)
11. [Regras de Negócio](#regras-de-negócio)
12. [Migrações e Evolução](#migrações-e-evolução)

---

## 🎯 VISÃO GERAL

### **Arquitetura**
O modelo de dados da Plataforma Humana Companions segue uma arquitetura **multi-tenant** com isolamento por **organização** e **workspace**, utilizando **PostgreSQL** com extensões **pgvector** para RAG e **Row-Level Security (RLS)** para isolamento de dados.

### **Hierarquia Principal**
```
ORGANIZATIONS (Empresas/Instituições)
  └── WORKSPACES (Espaços de trabalho: Pessoal ou Funcional)
       ├── USERS (Usuários/Perfis com roles)
       │    └── CHATS (Conversas)
       │         └── ARTIFACTS (Artefatos gerados)
       └── COMPANIONS (Agentes IA)
            └── SKILLS (Sub-agentes especializados)
                 └── STEPS (Fases de execução)
```

### **Tabelas Centrais**
- **KNOWLEDGE_RAG**: Sistema de conhecimento vetorizado (pgvector)
- **TOOLS_MCP**: Ferramentas/Integrações MCP
- **PERMISSIONS_ACL**: Controle de acesso granular

---

## 🔧 PRINCÍPIOS DE DESIGN

### 1. **Campos Mínimos + JSONB**
Todas as tabelas seguem o padrão:
- **Campos chave/header**: ID, FKs, nome, timestamps
- **Atributos JSONB**: Demais propriedades extensíveis

**Vantagem**: Evolução do modelo sem migrações de schema.

### 2. **ENUMs para Listas Fixas**
Valores categóricos são armazenados como ENUMs nativos do PostgreSQL.

### 3. **UUIDs como Primary Keys**
Todos os IDs são `UUID` para:
- Distribuição global
- Segurança (não sequencial)
- Facilidade em sistemas distribuídos

### 4. **Soft Deletes**
Campo `is_active BOOLEAN` para exclusão lógica.

### 5. **Auditoria Completa**
Todos os registros possuem:
- `created_at TIMESTAMP`
- `updated_at TIMESTAMP`
- `created_by_user_id UUID` (quando aplicável)

---

## 📊 TABELAS CORE

### **1. ORGANIZATIONS**

**Descrição**: Empresas/instituições que usam a plataforma.

#### **Campos**:
| Campo | Tipo | Constraints | Descrição |
|-------|------|-------------|-----------|
| `id` | UUID | PRIMARY KEY | Identificador único |
| `name` | VARCHAR(255) | NOT NULL | Nome da organização |
| `created_at` | TIMESTAMP | NOT NULL DEFAULT NOW() | Data de criação |
| `updated_at` | TIMESTAMP | NOT NULL DEFAULT NOW() | Última atualização |
| `is_active` | BOOLEAN | NOT NULL DEFAULT TRUE | Status ativo/inativo |
| `attributes` | JSONB | NOT NULL DEFAULT '{}' | Atributos extensíveis |

#### **Atributos JSONB** (Exemplos):
```json
{
  "domain": "empresa.com.br",
  "industry": "Manufacturing",
  "size": "Enterprise",
  "country": "BR",
  "timezone": "America/Sao_Paulo",
  "branding": {
    "logo_url": "https://...",
    "primary_color": "#3498db",
    "secondary_color": "#2c3e50"
  },
  "settings": {
    "max_users": 500,
    "max_storage_gb": 1000,
    "features_enabled": ["rag", "mcp", "workflows"]
  },
  "billing": {
    "plan": "enterprise",
    "payment_method": "invoice",
    "billing_email": "finance@empresa.com"
  }
}
```

#### **Índices**:
```sql
CREATE INDEX idx_organizations_name ON organizations(name);
CREATE INDEX idx_organizations_active ON organizations(is_active) WHERE is_active = TRUE;
CREATE INDEX idx_organizations_attributes_domain ON organizations USING GIN ((attributes->'domain'));
```

#### **RLS Policy**:
```sql
CREATE POLICY org_access ON organizations
  FOR ALL
  USING (id = current_setting('app.organization_id')::UUID);
```

---

### **2. WORKSPACES**

**Descrição**: Espaços de trabalho dentro de uma organização. Podem ser **pessoais** (MyWorkspace) ou **funcionais** (times, departamentos).

#### **Campos**:
| Campo | Tipo | Constraints | Descrição |
|-------|------|-------------|-----------|
| `id` | UUID | PRIMARY KEY | Identificador único |
| `organization_id` | UUID | NOT NULL, FK → organizations(id) | Organização dona |
| `name` | VARCHAR(255) | NOT NULL | Nome do workspace |
| `workspace_type` | ENUM | NOT NULL | Tipo: PERSONAL, FUNCTIONAL |
| `is_default` | BOOLEAN | NOT NULL DEFAULT FALSE | Workspace padrão da org |
| `created_at` | TIMESTAMP | NOT NULL DEFAULT NOW() | Data de criação |
| `updated_at` | TIMESTAMP | NOT NULL DEFAULT NOW() | Última atualização |
| `attributes` | JSONB | NOT NULL DEFAULT '{}' | Atributos extensíveis |

#### **ENUM workspace_type**:
```sql
CREATE TYPE workspace_type_enum AS ENUM ('PERSONAL', 'FUNCTIONAL');
```

#### **Atributos JSONB** (Exemplos):
```json
{
  "description": "Workspace de Vendas",
  "icon": "💼",
  "color": "#3498db",
  "visibility": "organization", // public, organization, team, private
  "owner_user_id": "uuid-do-criador",
  "department": "Sales",
  "team": "South Region",
  "settings": {
    "allow_guests": false,
    "auto_archive_chats_days": 90,
    "default_companion_id": "uuid-do-companion"
  },
  "organogram": {
    "parent_workspace_id": null,
    "child_workspaces": []
  }
}
```

#### **Índices**:
```sql
CREATE INDEX idx_workspaces_org ON workspaces(organization_id);
CREATE INDEX idx_workspaces_type ON workspaces(workspace_type);
CREATE INDEX idx_workspaces_default ON workspaces(is_default) WHERE is_default = TRUE;
CREATE INDEX idx_workspaces_attributes ON workspaces USING GIN (attributes);
```

#### **RLS Policy**:
```sql
CREATE POLICY workspace_access ON workspaces
  FOR ALL
  USING (
    organization_id = current_setting('app.organization_id')::UUID
    AND (
      -- OrgAdmin vê todos
      current_setting('app.role_code') = 'OA'
      OR
      -- Usuário vê workspaces que tem acesso
      id IN (
        SELECT workspace_id FROM workspace_users 
        WHERE user_id = current_setting('app.user_id')::UUID
        AND is_active = TRUE
      )
    )
  );
```

#### **Regras de Criação**:
1. Ao criar usuário → criar `MyWorkspace` (PERSONAL, privado)
2. Ao criar organização → criar `OrgWorkspace` (FUNCTIONAL, público)
3. OrgAdmin pode criar Workspaces FUNCTIONAL adicionais

---

### **3. USERS (PROFILES)**

**Descrição**: Perfis de usuários com roles e permissões.

#### **Campos**:
| Campo | Tipo | Constraints | Descrição |
|-------|------|-------------|-----------|
| `id` | UUID | PRIMARY KEY | Identificador único |
| `organization_id` | UUID | NOT NULL, FK → organizations(id) | Organização |
| `email` | VARCHAR(255) | NOT NULL, UNIQUE | Email (login) |
| `name` | VARCHAR(255) | NOT NULL | Nome completo |
| `role_code` | ENUM | NOT NULL | Role: MS, OA, WM, UR |
| `invite_code` | VARCHAR(50) | NULLABLE | Código de convite usado |
| `created_at` | TIMESTAMP | NOT NULL DEFAULT NOW() | Data de criação |
| `updated_at` | TIMESTAMP | NOT NULL DEFAULT NOW() | Última atualização |
| `attributes` | JSONB | NOT NULL DEFAULT '{}' | Atributos extensíveis |

#### **ENUM role_code**:
```sql
CREATE TYPE role_code_enum AS ENUM (
  'MS', -- MasterSys (super admin)
  'OA', -- OrgAdmin (admin da organização)
  'WM', -- WorkspaceManager (gerente de workspace)
  'UR'  -- User (usuário comum)
);
```

#### **Atributos JSONB** (Exemplos):
```json
{
  "avatar_url": "https://...",
  "phone": "+55 11 99999-9999",
  "department": "Sales",
  "job_title": "Sales Manager",
  "location": "São Paulo, BR",
  "timezone": "America/Sao_Paulo",
  "language": "pt-BR",
  "auth": {
    "provider": "google",
    "provider_id": "google-oauth-id",
    "last_login_at": "2025-01-15T10:30:00Z",
    "mfa_enabled": true
  },
  "preferences": {
    "theme": "dark",
    "notifications_email": true,
    "notifications_push": true,
    "default_workspace_id": "uuid-workspace"
  },
  "onboarding": {
    "completed": true,
    "completed_at": "2025-01-10T15:00:00Z",
    "steps": ["profile", "workspace", "companion"]
  },
  "invited_by": {
    "user_id": "uuid-convidador",
    "workspace_id": "uuid-workspace",
    "invited_at": "2025-01-09T10:00:00Z"
  }
}
```

#### **Índices**:
```sql
CREATE UNIQUE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_org ON users(organization_id);
CREATE INDEX idx_users_role ON users(role_code);
CREATE INDEX idx_users_invite ON users(invite_code) WHERE invite_code IS NOT NULL;
CREATE INDEX idx_users_attributes ON users USING GIN (attributes);
```

#### **RLS Policy**:
```sql
CREATE POLICY user_access ON users
  FOR ALL
  USING (
    organization_id = current_setting('app.organization_id')::UUID
    AND (
      current_setting('app.role_code') IN ('MS', 'OA') -- Admin vê todos
      OR id = current_setting('app.user_id')::UUID -- Usuário vê a si mesmo
    )
  );
```

---

### **4. CHATS**

**Descrição**: Conversas entre usuários e companions.

#### **Campos**:
| Campo | Tipo | Constraints | Descrição |
|-------|------|-------------|-----------|
| `id` | UUID | PRIMARY KEY | Identificador único |
| `user_id` | UUID | NOT NULL, FK → users(id) | Dono do chat |
| `workspace_id` | UUID | NOT NULL, FK → workspaces(id) | Workspace do chat |
| `companion_id` | UUID | NOT NULL, FK → companions(id) | Companion usado |
| `title` | VARCHAR(255) | NOT NULL | Título do chat |
| `messages` | JSONB[] | NOT NULL DEFAULT '[]' | Array de mensagens |
| `created_at` | TIMESTAMP | NOT NULL DEFAULT NOW() | Data de criação |
| `updated_at` | TIMESTAMP | NOT NULL DEFAULT NOW() | Última mensagem |
| `attributes` | JSONB | NOT NULL DEFAULT '{}' | Atributos extensíveis |

#### **Estrutura de `messages` JSONB[]**:
```json
[
  {
    "id": "msg-uuid",
    "role": "user",
    "content": "Como criar um relatório?",
    "timestamp": "2025-01-15T10:30:00Z",
    "metadata": {
      "tokens": 8,
      "attachments": []
    }
  },
  {
    "id": "msg-uuid-2",
    "role": "assistant",
    "content": "Para criar um relatório...",
    "timestamp": "2025-01-15T10:30:05Z",
    "metadata": {
      "tokens": 150,
      "model": "gpt-4o",
      "finish_reason": "stop",
      "tool_calls": []
    }
  }
]
```

#### **Atributos JSONB** (Exemplos):
```json
{
  "is_pinned": false,
  "is_archived": false,
  "summary": "Conversa sobre criação de relatórios",
  "tags": ["reports", "sales"],
  "last_activity_at": "2025-01-15T10:30:05Z",
  "message_count": 12,
  "context": {
    "knowledge_sources": ["doc-uuid-1", "doc-uuid-2"],
    "tools_used": ["mcp-database", "mcp-email"],
    "files_uploaded": []
  },
  "metadata": {
    "total_tokens": 5420,
    "cost_usd": 0.15,
    "duration_seconds": 45
  }
}
```

#### **Índices**:
```sql
CREATE INDEX idx_chats_user ON chats(user_id);
CREATE INDEX idx_chats_workspace ON chats(workspace_id);
CREATE INDEX idx_chats_companion ON chats(companion_id);
CREATE INDEX idx_chats_updated ON chats(updated_at DESC);
CREATE INDEX idx_chats_messages ON chats USING GIN (messages);
```

#### **RLS Policy**:
```sql
CREATE POLICY chat_access ON chats
  FOR ALL
  USING (
    user_id = current_setting('app.user_id')::UUID
    OR current_setting('app.role_code') = 'OA'
  );
```

---

### **5. ARTIFACTS**

**Descrição**: Artefatos gerados durante conversas (documentos, relatórios, diagramas, etc).

#### **Campos**:
| Campo | Tipo | Constraints | Descrição |
|-------|------|-------------|-----------|
| `id` | UUID | PRIMARY KEY | Identificador único |
| `chat_id` | UUID | NOT NULL, FK → chats(id) | Chat que gerou |
| `user_id` | UUID | NOT NULL, FK → users(id) | Dono do artefato |
| `workspace_id` | UUID | NOT NULL, FK → workspaces(id) | Workspace (pode ser compartilhado) |
| `title` | VARCHAR(255) | NOT NULL | Título do artefato |
| `content` | TEXT | NOT NULL | Conteúdo (Markdown/SVG/HTML) |
| `format` | ENUM | NOT NULL | Formato: MD, SVG, PDF, HTML |
| `created_at` | TIMESTAMP | NOT NULL DEFAULT NOW() | Data de criação |
| `attributes` | JSONB | NOT NULL DEFAULT '{}' | Atributos extensíveis |

#### **ENUM format**:
```sql
CREATE TYPE artifact_format_enum AS ENUM ('MD', 'SVG', 'PDF', 'HTML', 'JSON');
```

#### **Atributos JSONB** (Exemplos):
```json
{
  "version": 3,
  "versions_history": [
    {"version": 1, "created_at": "...", "diff": "..."},
    {"version": 2, "created_at": "...", "diff": "..."}
  ],
  "file_url": "https://blob.vercel-storage.com/...",
  "file_size_bytes": 52400,
  "visibility": "workspace", // private, workspace, organization
  "shared_with_workspaces": ["uuid-1", "uuid-2"],
  "export_formats": ["pdf", "docx"],
  "metadata": {
    "word_count": 1523,
    "pages": 5,
    "generated_by_skill_id": "uuid-skill",
    "generation_prompt": "Criar relatório de vendas...",
    "tokens_used": 2400
  },
  "tags": ["report", "sales", "Q1-2025"]
}
```

#### **Índices**:
```sql
CREATE INDEX idx_artifacts_chat ON artifacts(chat_id);
CREATE INDEX idx_artifacts_user ON artifacts(user_id);
CREATE INDEX idx_artifacts_workspace ON artifacts(workspace_id);
CREATE INDEX idx_artifacts_format ON artifacts(format);
CREATE INDEX idx_artifacts_created ON artifacts(created_at DESC);
```

#### **RLS Policy**:
```sql
CREATE POLICY artifact_access ON artifacts
  FOR ALL
  USING (
    user_id = current_setting('app.user_id')::UUID
    OR workspace_id IN (
      SELECT workspace_id FROM workspace_users 
      WHERE user_id = current_setting('app.user_id')::UUID
    )
  );
```

---

## 🤖 TABELAS AI/AGÊNTICAS

### **6. COMPANIONS**

**Descrição**: Agentes IA com instruções e conhecimento próprio.

#### **Campos**:
| Campo | Tipo | Constraints | Descrição |
|-------|------|-------------|-----------|
| `id` | UUID | PRIMARY KEY | Identificador único |
| `workspace_id` | UUID | NOT NULL, FK → workspaces(id) | Workspace dono |
| `organization_id` | UUID | NOT NULL, FK → organizations(id) | Organização |
| `created_by_user_id` | UUID | NOT NULL, FK → users(id) | Criador |
| `name` | VARCHAR(255) | NOT NULL | Nome do companion |
| `companion_type` | ENUM | NOT NULL | SUPER, FUNCTIONAL |
| `instructions` | TEXT | NOT NULL | Instruções/Prompt system |
| `is_active` | BOOLEAN | NOT NULL DEFAULT TRUE | Ativo/inativo |
| `created_at` | TIMESTAMP | NOT NULL DEFAULT NOW() | Data de criação |
| `attributes` | JSONB | NOT NULL DEFAULT '{}' | Atributos extensíveis |

#### **ENUM companion_type**:
```sql
CREATE TYPE companion_type_enum AS ENUM ('SUPER', 'FUNCTIONAL');
```

#### **Atributos JSONB** (Exemplos):
```json
{
  "description": "Companion especializado em vendas",
  "avatar_url": "https://...",
  "icon": "💼",
  "personality": {
    "tone": "professional",
    "style": "concise",
    "expertise_areas": ["sales", "crm", "reports"]
  },
  "model_config": {
    "provider": "azure",
    "model": "gpt-4o",
    "temperature": 0.7,
    "max_tokens": 4000,
    "top_p": 0.9
  },
  "knowledge_sources": [
    {
      "resource_kind": "KNW",
      "resource_id": "uuid-knowledge-1",
      "priority": 1
    }
  ],
  "tools_enabled": [
    "mcp-database",
    "mcp-email",
    "web-search"
  ],
  "permissions": {
    "can_execute_code": false,
    "can_access_files": true,
    "can_send_emails": true
  },
  "usage_stats": {
    "total_chats": 245,
    "total_messages": 3420,
    "avg_rating": 4.5
  }
}
```

#### **Índices**:
```sql
CREATE INDEX idx_companions_workspace ON companions(workspace_id);
CREATE INDEX idx_companions_org ON companions(organization_id);
CREATE INDEX idx_companions_type ON companions(companion_type);
CREATE INDEX idx_companions_active ON companions(is_active) WHERE is_active = TRUE;
```

#### **RLS Policy**:
```sql
CREATE POLICY companion_access ON companions
  FOR ALL
  USING (
    organization_id = current_setting('app.organization_id')::UUID
    AND (
      workspace_id IN (
        SELECT workspace_id FROM workspace_users 
        WHERE user_id = current_setting('app.user_id')::UUID
      )
      OR current_setting('app.role_code') = 'OA'
    )
  );
```

---

### **7. SKILLS**

**Descrição**: Sub-agentes especializados que pertencem a companions.

#### **Campos**:
| Campo | Tipo | Constraints | Descrição |
|-------|------|-------------|-----------|
| `id` | UUID | PRIMARY KEY | Identificador único |
| `companion_id` | UUID | NOT NULL, FK → companions(id) | Companion dono |
| `name` | VARCHAR(255) | NOT NULL | Nome da skill |
| `goal` | TEXT | NOT NULL | Objetivo da skill |
| `instructions` | TEXT | NOT NULL | Instruções específicas |
| `execution_order` | INTEGER | NOT NULL | Ordem de execução |
| `is_active` | BOOLEAN | NOT NULL DEFAULT TRUE | Ativo/inativo |
| `created_at` | TIMESTAMP | NOT NULL DEFAULT NOW() | Data de criação |
| `updated_at` | TIMESTAMP | NOT NULL DEFAULT NOW() | Última atualização |
| `attributes` | JSONB | NOT NULL DEFAULT '{}' | Atributos extensíveis |

#### **Atributos JSONB** (Schema padrão):
```json
{
  "name": "criar_perfil_funcionario",
  "goal": "Criar perfil completo de funcionário nos sistemas da Belgo",
  "data": {
    "organizacao": "Estruturas organizacionais Belgo, hierarquias, códigos",
    "candidato": "Dados do processo seletivo + documentos validados",
    "sistemas": "Odoo (RH), SAP (Folha), Email (Comunicação)"
  },
  "steps": [
    "1) Estruture dados organizacionais (departamento, cargo, hierarquia)",
    "2) Aplique códigos e classificações do sistema",
    "3) Configure acessos iniciais baseados no cargo",
    "4) Valide integrações com sistemas externos"
  ],
  "rules": [
    "Seguir estrutura organizacional da Belgo",
    "Aplicar políticas de acesso por cargo",
    "Validar dados antes de sincronizar",
    "Manter auditoria completa de criação"
  ],
  "tools": [
    "odoo_create_employee",
    "sap_sync_data",
    "email_send_welcome"
  ],
  "user_inputs": {
    "required": ["nome_completo", "cpf", "cargo_id"],
    "optional": ["data_nascimento", "endereco"]
  },
  "user_interactions": {
    "confirmations": ["confirmar_dados", "enviar_email_boas_vindas"],
    "approvals": ["aprovar_acesso_sistemas"]
  },
  "metadata": {
    "schema_name": "atributos_skills",
    "schema_version": "1.0",
    "estimated_duration_seconds": 120,
    "complexity": "medium"
  }
}
```

#### **Índices**:
```sql
CREATE INDEX idx_skills_companion ON skills(companion_id);
CREATE INDEX idx_skills_order ON skills(companion_id, execution_order);
CREATE INDEX idx_skills_active ON skills(is_active) WHERE is_active = TRUE;
CREATE INDEX idx_skills_attributes ON skills USING GIN (attributes);
```

---

### **8. STEPS**

**Descrição**: Fases individuais de execução dentro de uma skill.

#### **Campos**:
| Campo | Tipo | Constraints | Descrição |
|-------|------|-------------|-----------|
| `id` | UUID | PRIMARY KEY | Identificador único |
| `skill_id` | UUID | NOT NULL, FK → skills(id) | Skill dona |
| `name` | VARCHAR(255) | NOT NULL | Nome do step |
| `description` | TEXT | NOT NULL | Descrição do step |
| `instructions` | TEXT | NOT NULL | Instruções específicas |
| `step_order` | INTEGER | NOT NULL | Ordem de execução |
| `is_active` | BOOLEAN | NOT NULL DEFAULT TRUE | Ativo/inativo |
| `created_at` | TIMESTAMP | NOT NULL DEFAULT NOW() | Data de criação |
| `updated_at` | TIMESTAMP | NOT NULL DEFAULT NOW() | Última atualização |
| `attributes` | JSONB | NOT NULL DEFAULT '{}' | Atributos extensíveis |

#### **Atributos JSONB** (Exemplos):
```json
{
  "step_type": "validation", // validation, transformation, integration, approval
  "input_schema": {
    "type": "object",
    "properties": {
      "employee_data": {"type": "object"},
      "organization_code": {"type": "string"}
    },
    "required": ["employee_data", "organization_code"]
  },
  "output_schema": {
    "type": "object",
    "properties": {
      "validated": {"type": "boolean"},
      "errors": {"type": "array"}
    }
  },
  "tools_required": ["odoo_api", "validation_service"],
  "timeout_seconds": 30,
  "retry_config": {
    "max_retries": 3,
    "backoff_seconds": 5
  },
  "dependencies": {
    "previous_steps": ["step-uuid-1"],
    "required_data": ["organization_structure"]
  },
  "error_handling": {
    "on_failure": "rollback", // rollback, continue, stop
    "notify_user": true
  }
}
```

#### **Índices**:
```sql
CREATE INDEX idx_steps_skill ON steps(skill_id);
CREATE INDEX idx_steps_order ON steps(skill_id, step_order);
CREATE INDEX idx_steps_active ON steps(is_active) WHERE is_active = TRUE;
```

---

### **9. EXECUTIONS**

**Descrição**: Logs de execução de workflows agênticos (seguindo modelo Anthropic).

#### **Campos**:
| Campo | Tipo | Constraints | Descrição |
|-------|------|-------------|-----------|
| `id` | UUID | PRIMARY KEY | Identificador único |
| `chat_id` | UUID | NOT NULL, FK → chats(id) | Chat que iniciou |
| `skill_id` | UUID | NOT NULL, FK → skills(id) | Skill executada |
| `user_id` | UUID | NOT NULL, FK → users(id) | Usuário executor |
| `status` | ENUM | NOT NULL | Status da execução |
| `steps_log` | JSONB[] | NOT NULL DEFAULT '[]' | Log de cada step |
| `started_at` | TIMESTAMP | NOT NULL DEFAULT NOW() | Início |
| `completed_at` | TIMESTAMP | NULLABLE | Fim |
| `attributes` | JSONB | NOT NULL DEFAULT '{}' | Atributos extensíveis |

#### **ENUM status**:
```sql
CREATE TYPE execution_status_enum AS ENUM ('PENDING', 'RUNNING', 'COMPLETED', 'FAILED', 'CANCELLED');
```

#### **Estrutura `steps_log` JSONB[]**:
```json
[
  {
    "step_id": "uuid-step-1",
    "step_name": "Validar Dados",
    "status": "completed",
    "started_at": "2025-01-15T10:30:00Z",
    "completed_at": "2025-01-15T10:30:05Z",
    "duration_ms": 5000,
    "input": { "employee_data": {...} },
    "output": { "validated": true, "errors": [] },
    "tools_used": ["odoo_api"],
    "tokens_used": 250,
    "error": null
  },
  {
    "step_id": "uuid-step-2",
    "step_name": "Criar no Odoo",
    "status": "running",
    "started_at": "2025-01-15T10:30:05Z",
    "completed_at": null,
    "duration_ms": null,
    "input": { "validated_data": {...} },
    "output": null,
    "tools_used": ["odoo_create_employee"],
    "tokens_used": 0,
    "error": null
  }
]
```

#### **Atributos JSONB** (Exemplos):
```json
{
  "total_duration_ms": 15000,
  "total_tokens": 1250,
  "total_cost_usd": 0.05,
  "steps_completed": 3,
  "steps_total": 4,
  "user_approvals": [
    {
      "step_id": "uuid-step-3",
      "approved_at": "2025-01-15T10:30:10Z",
      "approved_by": "uuid-user"
    }
  ],
  "errors": [],
  "artifacts_generated": ["uuid-artifact-1"],
  "knowledge_used": ["uuid-knowledge-1", "uuid-knowledge-2"]
}
```

#### **Índices**:
```sql
CREATE INDEX idx_executions_chat ON executions(chat_id);
CREATE INDEX idx_executions_skill ON executions(skill_id);
CREATE INDEX idx_executions_user ON executions(user_id);
CREATE INDEX idx_executions_status ON executions(status);
CREATE INDEX idx_executions_started ON executions(started_at DESC);
```

---

## 🌐 TABELAS CENTRAIS/COMPARTILHADAS

### **10. KNOWLEDGE_RAG**

**Descrição**: Sistema de conhecimento vetorizado usando **pgvector** para busca semântica.

#### **Campos**:
| Campo | Tipo | Constraints | Descrição |
|-------|------|-------------|-----------|
| `id` | UUID | PRIMARY KEY | Identificador único |
| `resource_kind` | ENUM | NOT NULL | Tipo de recurso |
| `resource_id` | UUID | NOT NULL | ID do recurso |
| `class_info` | ENUM | NOT NULL | Nível de acesso |
| `restricts_stamps` | TEXT[] | NOT NULL DEFAULT '{}' | Classificações |
| `content` | TEXT | NOT NULL | Conteúdo do chunk |
| `embedding` | VECTOR(1536) | NOT NULL | Embedding vetorial |
| `chunk_index` | INTEGER | NOT NULL | Índice do chunk |
| `source_file` | VARCHAR(500) | NULLABLE | Arquivo de origem |
| `created_at` | TIMESTAMP | NOT NULL DEFAULT NOW() | Data de criação |
| `attributes` | JSONB | NOT NULL DEFAULT '{}' | Atributos extensíveis |

#### **ENUM resource_kind**:
```sql
CREATE TYPE resource_kind_enum AS ENUM (
  'ORG',  -- Organization
  'WSP',  -- Workspace
  'CMP',  -- Companion
  'PRL',  -- Profile (User)
  'CHT',  -- Chat
  'KNW',  -- Knowledge
  'TOL'   -- Tool
);
```

#### **ENUM class_info**:
```sql
CREATE TYPE class_info_enum AS ENUM (
  'PUB',  -- Public
  'ORG',  -- Organization
  'WSP',  -- Workspace
  'PVT'   -- Private
);
```

#### **Atributos JSONB** (Exemplos):
```json
{
  "chunk_size": 500,
  "chunk_overlap": 50,
  "total_chunks": 120,
  "embedding_model": "text-embedding-3-small",
  "embedding_dimensions": 1536,
  "file_metadata": {
    "filename": "Manual_RH.pdf",
    "file_type": "pdf",
    "file_size_bytes": 2400000,
    "pages": 150,
    "upload_date": "2025-01-10"
  },
  "extraction": {
    "method": "azure_document_intelligence",
    "confidence": 0.95,
    "language": "pt-BR"
  },
  "semantic_tags": ["rh", "políticas", "férias"],
  "named_entities": {
    "organizations": ["Empresa XYZ"],
    "dates": ["2025", "12 meses"],
    "persons": []
  },
  "quality_score": 0.92,
  "relevance_score": 0.85
}
```

#### **Índices** (CRÍTICO para performance):
```sql
-- Índice vetorial IVFFlat para busca de similaridade
CREATE INDEX idx_knowledge_embedding ON knowledge_rag 
  USING ivfflat (embedding vector_cosine_ops) 
  WITH (lists = 100);

-- Índices para filtros
CREATE INDEX idx_knowledge_resource ON knowledge_rag(resource_kind, resource_id);
CREATE INDEX idx_knowledge_class ON knowledge_rag(class_info);
CREATE INDEX idx_knowledge_restricts ON knowledge_rag USING GIN (restricts_stamps);
CREATE INDEX idx_knowledge_created ON knowledge_rag(created_at DESC);

-- Índice para busca full-text
CREATE INDEX idx_knowledge_content_fts ON knowledge_rag USING GIN (to_tsvector('portuguese', content));
```

#### **RLS Policy** (Multi-nível):
```sql
CREATE POLICY knowledge_access ON knowledge_rag
  FOR ALL
  USING (
    -- Filtro por class_info
    (
      class_info = 'PUB' -- Público para todos
      OR (
        class_info = 'ORG' 
        AND EXISTS (
          SELECT 1 FROM organizations o
          WHERE o.id::text = (attributes->>'organization_id')
          AND o.id = current_setting('app.organization_id')::UUID
        )
      )
      OR (
        class_info = 'WSP'
        AND EXISTS (
          SELECT 1 FROM workspace_users wu
          WHERE wu.workspace_id::text = (attributes->>'workspace_id')
          AND wu.user_id = current_setting('app.user_id')::UUID
        )
      )
      OR (
        class_info = 'PVT'
        AND (attributes->>'user_id')::UUID = current_setting('app.user_id')::UUID
      )
    )
    -- Verificar restricts_stamps baseado em role
    AND (
      restricts_stamps = '{}' -- Sem restrições
      OR current_setting('app.role_code') IN ('MS', 'OA') -- Admin vê tudo
    )
  );
```

#### **Busca Semântica** (Exemplo):
```sql
-- Gerar embedding da query (via aplicação)
-- query_embedding = [0.12, -0.45, ..., 0.33]

SELECT 
  id,
  content,
  resource_kind,
  resource_id,
  1 - (embedding <=> '[0.12,-0.45,...,0.33]'::vector) as similarity_score,
  attributes->'file_metadata'->>'filename' as source_file
FROM knowledge_rag
WHERE 
  class_info IN ('PUB', 'ORG') -- Filtros de acesso
  AND (embedding <=> '[0.12,-0.45,...,0.33]'::vector) < 0.3 -- Threshold de distância
ORDER BY embedding <=> '[0.12,-0.45,...,0.33]'::vector
LIMIT 10;
```

---

### **11. TOOLS_MCP**

**Descrição**: Ferramentas e integrações MCP (Model Context Protocol).

#### **Campos**:
| Campo | Tipo | Constraints | Descrição |
|-------|------|-------------|-----------|
| `id` | UUID | PRIMARY KEY | Identificador único |
| `organization_id` | UUID | NOT NULL, FK → organizations(id) | Organização |
| `configured_by_user_id` | UUID | NOT NULL, FK → users(id) | Quem configurou |
| `tool_name` | VARCHAR(255) | NOT NULL | Nome da ferramenta |
| `tool_type` | ENUM | NOT NULL | Tipo da ferramenta |
| `auth_type` | ENUM | NOT NULL | Tipo de autenticação |
| `config_data` | JSONB | NOT NULL | Configurações |
| `is_active` | BOOLEAN | NOT NULL DEFAULT TRUE | Ativo/inativo |
| `created_at` | TIMESTAMP | NOT NULL DEFAULT NOW() | Data de criação |
| `attributes` | JSONB | NOT NULL DEFAULT '{}' | Atributos extensíveis |

#### **ENUM tool_type**:
```sql
CREATE TYPE tool_type_enum AS ENUM ('DATABASE', 'API', 'FILESYSTEM', 'CUSTOM');
```

#### **ENUM auth_type**:
```sql
CREATE TYPE auth_type_enum AS ENUM ('BEARER', 'OAUTH', 'API_KEY', 'NONE');
```

#### **`config_data` JSONB** (Schemas por tipo):

**DATABASE:**
```json
{
  "connection_string": "postgresql://...",
  "database_type": "postgresql",
  "allowed_operations": ["SELECT", "INSERT", "UPDATE"],
  "schema_whitelist": ["public", "app"],
  "table_whitelist": ["employees", "departments"],
  "max_rows_per_query": 1000
}
```

**API:**
```json
{
  "base_url": "https://api.sistema.com",
  "endpoints": [
    {
      "name": "get_employee",
      "method": "GET",
      "path": "/employees/{id}",
      "description": "Buscar funcionário por ID"
    },
    {
      "name": "create_employee",
      "method": "POST",
      "path": "/employees",
      "description": "Criar novo funcionário"
    }
  ],
  "rate_limit": {
    "requests_per_minute": 60
  }
}
```

**FILESYSTEM:**
```json
{
  "storage_provider": "vercel_blob",
  "allowed_extensions": [".pdf", ".docx", ".xlsx"],
  "max_file_size_mb": 50,
  "paths": {
    "read": ["/documents", "/reports"],
    "write": ["/temp", "/exports"]
  }
}
```

#### **Atributos JSONB** (Exemplos):
```json
{
  "credentials": {
    "encrypted": true,
    "vault_key": "kms-key-id",
    "expires_at": "2026-01-01T00:00:00Z"
  },
  "usage_stats": {
    "total_calls": 1542,
    "last_used_at": "2025-01-15T10:30:00Z",
    "errors_count": 5,
    "avg_response_time_ms": 250
  },
  "permissions": {
    "allowed_users": ["uuid-1", "uuid-2"],
    "allowed_roles": ["WM", "OA"],
    "allowed_companions": ["uuid-companion-1"]
  },
  "monitoring": {
    "alerts_enabled": true,
    "alert_on_error": true,
    "alert_email": "admin@empresa.com"
  }
}
```

#### **Índices**:
```sql
CREATE INDEX idx_tools_org ON tools_mcp(organization_id);
CREATE INDEX idx_tools_type ON tools_mcp(tool_type);
CREATE INDEX idx_tools_active ON tools_mcp(is_active) WHERE is_active = TRUE;
CREATE INDEX idx_tools_config ON tools_mcp USING GIN (config_data);
```

#### **Fluxo de Acesso**:
1. **MasterSys** → Configura ferramentas globais
2. **OrgAdmin** → Habilita ferramentas para organização
3. **WorkspaceManager** → Concede acesso a companions
4. **User** → Usa via companion (transparente)

---

### **12. PERMISSIONS_ACL**

**Descrição**: Controle de acesso granular (Access Control List).

#### **Campos**:
| Campo | Tipo | Constraints | Descrição |
|-------|------|-------------|-----------|
| `id` | UUID | PRIMARY KEY | Identificador único |
| `resource_kind` | ENUM | NOT NULL | Tipo de recurso |
| `resource_id` | UUID | NOT NULL | ID do recurso |
| `action` | ENUM | NOT NULL | Ação permitida |
| `created_by_user_id` | UUID | NOT NULL, FK → users(id) | Quem concedeu |
| `created_for_user_id` | UUID | NOT NULL, FK → users(id) | Para quem |
| `created_at` | TIMESTAMP | NOT NULL DEFAULT NOW() | Data de criação |
| `valid_from` | TIMESTAMP | NOT NULL DEFAULT NOW() | Início validade |
| `valid_to` | TIMESTAMP | NULLABLE | Fim validade |
| `is_active` | BOOLEAN | NOT NULL DEFAULT TRUE | Ativo/inativo |
| `revoked_at` | TIMESTAMP | NULLABLE | Data de revogação |
| `attributes` | JSONB | NOT NULL DEFAULT '{}' | Atributos extensíveis |

#### **ENUM action**:
```sql
CREATE TYPE action_enum AS ENUM (
  'REA',  -- Read
  'WRI',  -- Write
  'UPD',  -- Update
  'MNG'   -- Manage (full control)
);
```

#### **Atributos JSONB** (Exemplos):
```json
{
  "granted_reason": "Membro do time de vendas",
  "conditions": {
    "ip_whitelist": ["192.168.1.0/24"],
    "time_restrictions": {
      "days_of_week": [1, 2, 3, 4, 5], // Seg-Sex
      "hours": "09:00-18:00"
    }
  },
  "scope": {
    "fields_allowed": ["name", "email"], // Campos específicos
    "operations_allowed": ["read", "list"]
  },
  "audit": {
    "last_access_at": "2025-01-15T10:30:00Z",
    "access_count": 45,
    "violations_count": 0
  },
  "revocation": {
    "revoked_by_user_id": null,
    "revoke_reason": null
  }
}
```

#### **Índices**:
```sql
CREATE INDEX idx_permissions_resource ON permissions_acl(resource_kind, resource_id);
CREATE INDEX idx_permissions_user ON permissions_acl(created_for_user_id);
CREATE INDEX idx_permissions_action ON permissions_acl(action);
CREATE INDEX idx_permissions_active ON permissions_acl(is_active, valid_from, valid_to) 
  WHERE is_active = TRUE AND revoked_at IS NULL;
CREATE INDEX idx_permissions_validity ON permissions_acl(valid_from, valid_to);
```

#### **Função de Verificação**:
```sql
CREATE OR REPLACE FUNCTION check_permission(
  p_user_id UUID,
  p_resource_kind resource_kind_enum,
  p_resource_id UUID,
  p_action action_enum
) RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM permissions_acl
    WHERE created_for_user_id = p_user_id
      AND resource_kind = p_resource_kind
      AND resource_id = p_resource_id
      AND action IN (p_action, 'MNG') -- MNG inclui todas as ações
      AND is_active = TRUE
      AND revoked_at IS NULL
      AND valid_from <= NOW()
      AND (valid_to IS NULL OR valid_to >= NOW())
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

#### **Exemplo de Uso**:
```sql
-- Verificar se usuário pode editar companion
SELECT check_permission(
  'user-uuid'::UUID,
  'CMP'::resource_kind_enum,
  'companion-uuid'::UUID,
  'UPD'::action_enum
); -- Retorna TRUE ou FALSE
```

---

### **13. WORKSPACE_USERS**

**Descrição**: Tabela de junção (N:M) entre workspaces e usuários.

#### **Campos**:
| Campo | Tipo | Constraints | Descrição |
|-------|------|-------------|-----------|
| `id` | UUID | PRIMARY KEY | Identificador único |
| `workspace_id` | UUID | NOT NULL, FK → workspaces(id) | Workspace |
| `user_id` | UUID | NOT NULL, FK → users(id) | Usuário |
| `granted_by_user_id` | UUID | NOT NULL, FK → users(id) | Quem concedeu acesso |
| `access_granted_at` | TIMESTAMP | NOT NULL DEFAULT NOW() | Data de concessão |
| `is_active` | BOOLEAN | NOT NULL DEFAULT TRUE | Ativo/inativo |
| `attributes` | JSONB | NOT NULL DEFAULT '{}' | Atributos extensíveis |

#### **Constraints**:
```sql
-- Impedir duplicatas
CREATE UNIQUE INDEX idx_workspace_users_unique 
  ON workspace_users(workspace_id, user_id) 
  WHERE is_active = TRUE;
```

#### **Atributos JSONB** (Exemplos):
```json
{
  "role_in_workspace": "member", // owner, admin, member
  "permissions": {
    "can_invite_users": false,
    "can_create_companions": false,
    "can_view_analytics": true
  },
  "onboarding": {
    "completed": true,
    "completed_at": "2025-01-10T15:00:00Z"
  },
  "favorites": {
    "companion_ids": ["uuid-1", "uuid-2"],
    "pinned_chats": ["uuid-chat-1"]
  },
  "last_activity_at": "2025-01-15T10:30:00Z"
}
```

#### **Índices**:
```sql
CREATE INDEX idx_workspace_users_workspace ON workspace_users(workspace_id);
CREATE INDEX idx_workspace_users_user ON workspace_users(user_id);
CREATE INDEX idx_workspace_users_granted_by ON workspace_users(granted_by_user_id);
CREATE INDEX idx_workspace_users_active ON workspace_users(is_active) WHERE is_active = TRUE;
```

---

## 📋 ENUMERAÇÕES (ENUMs)

### **Resumo de Todas as ENUMs**

| Nome | Valores | Descrição |
|------|---------|-----------|
| `role_code_enum` | MS, OA, WM, UR | Roles de usuários |
| `resource_kind_enum` | ORG, WSP, CMP, PRL, CHT, KNW, TOL | Tipos de recursos |
| `action_enum` | REA, WRI, UPD, MNG | Ações de permissão |
| `class_info_enum` | PUB, ORG, WSP, PVT | Níveis de acesso |
| `workspace_type_enum` | PERSONAL, FUNCTIONAL | Tipos de workspace |
| `companion_type_enum` | SUPER, FUNCTIONAL | Tipos de companion |
| `artifact_format_enum` | MD, SVG, PDF, HTML, JSON | Formatos de artefato |
| `execution_status_enum` | PENDING, RUNNING, COMPLETED, FAILED, CANCELLED | Status de execução |
| `tool_type_enum` | DATABASE, API, FILESYSTEM, CUSTOM | Tipos de ferramenta MCP |
| `auth_type_enum` | BEARER, OAUTH, API_KEY, NONE | Tipos de autenticação |

### **RESTRICTS_STAMPS** (Array de strings)
Classificações de sensibilidade de dados:
- **PII**: Personal Identifiable Information (CPF, RG, endereço)
- **FIN**: Financial (dados financeiros, salários)
- **COF**: Confidential (informações confidenciais da empresa)

---

## 🔗 RELACIONAMENTOS

### **Diagrama de Relacionamentos**

```
ORGANIZATIONS (1) ──┬─── (N) WORKSPACES
                    │
                    ├─── (N) USERS
                    │
                    ├─── (N) COMPANIONS
                    │
                    ├─── (N) TOOLS_MCP
                    │
                    └─── (N) KNOWLEDGE_RAG

WORKSPACES (N) ────┬─── (M) USERS (via WORKSPACE_USERS)
                   │
                   ├─── (N) COMPANIONS
                   │
                   ├─── (N) CHATS
                   │
                   ├─── (N) ARTIFACTS
                   │
                   └─── (N) KNOWLEDGE_RAG

USERS (1) ─────────┬─── (N) CHATS
                   │
                   ├─── (N) ARTIFACTS
                   │
                   ├─── (N) EXECUTIONS
                   │
                   └─── (N) PERMISSIONS_ACL

COMPANIONS (1) ────┬─── (N) SKILLS
                   │
                   ├─── (N) CHATS
                   │
                   └─── (N) KNOWLEDGE_RAG

SKILLS (1) ────────┬─── (N) STEPS
                   │
                   └─── (N) EXECUTIONS

CHATS (1) ─────────┬─── (N) ARTIFACTS
                   │
                   ├─── (N) EXECUTIONS
                   │
                   └─── (N) KNOWLEDGE_RAG (auto-indexado)
```

### **Foreign Keys**

Todas as FKs usam `ON DELETE CASCADE` ou `ON DELETE SET NULL` conforme a lógica de negócio:

- **CASCADE**: Deletar pai deleta filhos (ex: Organization → Workspaces)
- **SET NULL**: Deletar pai mantém filhos (ex: Companion → Chats continuam existindo)

---

## 🔒 SEGURANÇA E ISOLAMENTO

### **1. GUC (Global User Context)**

No início de cada request, o sistema configura variáveis de sessão:

```sql
-- Configurar contexto no início do request
SET LOCAL app.organization_id = 'uuid-org';
SET LOCAL app.workspace_id = 'uuid-workspace';
SET LOCAL app.user_id = 'uuid-user';
SET LOCAL app.role_code = 'WM';
```

### **2. RLS (Row-Level Security)**

Cada tabela possui policies RLS que leem o GUC:

```sql
-- Exemplo: Policy para CHATS
CREATE POLICY chat_access ON chats
  FOR ALL
  USING (
    -- Usuário vê seus próprios chats
    user_id = current_setting('app.user_id')::UUID
    OR
    -- OrgAdmin vê todos os chats da organização
    (
      current_setting('app.role_code') = 'OA'
      AND workspace_id IN (
        SELECT id FROM workspaces 
        WHERE organization_id = current_setting('app.organization_id')::UUID
      )
    )
  );
```

### **3. ACL (Access Control List)**

Controle granular por recurso via tabela `PERMISSIONS_ACL`:

```sql
-- Verificar antes de permitir ação
IF NOT check_permission(
  current_user_id,
  'CMP',
  companion_id,
  'UPD'
) THEN
  RAISE EXCEPTION 'Sem permissão para editar este companion';
END IF;
```

### **4. RAG (Knowledge Filtering)**

Filtragem de conhecimento por `class_info` e `restricts_stamps`:

```sql
-- Busca vetorial com filtros de segurança
SELECT * FROM knowledge_rag
WHERE 
  -- Filtro por class_info
  (
    class_info = 'PUB'
    OR (class_info = 'ORG' AND (attributes->>'organization_id')::UUID = current_setting('app.organization_id')::UUID)
    OR (class_info = 'PVT' AND (attributes->>'user_id')::UUID = current_setting('app.user_id')::UUID)
  )
  -- Filtro por restricts_stamps
  AND (
    restricts_stamps = '{}'
    OR current_setting('app.role_code') IN ('MS', 'OA')
  )
  -- Busca vetorial
  AND (embedding <=> query_embedding) < 0.3
ORDER BY embedding <=> query_embedding
LIMIT 10;
```

### **5. Fluxo de Segurança (GUC → RLS → ACL → RAG)**

```
REQUEST (HTTP) → Middleware Auth
  ↓
SET GUC (organization_id, user_id, role_code, workspace_id)
  ↓
QUERY com RLS (filtra linhas automaticamente)
  ↓
CHECK ACL (verifica permissões específicas se necessário)
  ↓
FILTER RAG (aplica class_info + restricts_stamps)
  ↓
RESPONSE (dados isolados e autorizados)
```

---

## ⚡ ÍNDICES E PERFORMANCE

### **Estratégia de Indexação**

#### **1. Primary Keys (Automático)**
Todos os `id UUID` são indexed automaticamente.

#### **2. Foreign Keys (Obrigatório)**
Todas as FKs devem ter índices:
```sql
CREATE INDEX idx_chats_user ON chats(user_id);
CREATE INDEX idx_chats_workspace ON chats(workspace_id);
CREATE INDEX idx_chats_companion ON chats(companion_id);
```

#### **3. Campos de Busca Frequente**
```sql
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role_code);
CREATE INDEX idx_companions_type ON companions(companion_type);
```

#### **4. Filtros Booleanos**
```sql
CREATE INDEX idx_companions_active ON companions(is_active) WHERE is_active = TRUE;
```

#### **5. Ordenação por Timestamp**
```sql
CREATE INDEX idx_chats_updated ON chats(updated_at DESC);
CREATE INDEX idx_executions_started ON executions(started_at DESC);
```

#### **6. JSONB (GIN Index)**
```sql
CREATE INDEX idx_users_attributes ON users USING GIN (attributes);
CREATE INDEX idx_skills_attributes ON skills USING GIN (attributes);
```

#### **7. Índices Vetoriais (pgvector)**
```sql
-- IVFFlat para busca de similaridade
CREATE INDEX idx_knowledge_embedding ON knowledge_rag 
  USING ivfflat (embedding vector_cosine_ops) 
  WITH (lists = 100);

-- Ajustar 'lists' conforme volume:
-- < 100k linhas: lists = 100
-- 100k-1M: lists = 1000
-- > 1M: lists = 10000
```

#### **8. Full-Text Search**
```sql
CREATE INDEX idx_knowledge_content_fts ON knowledge_rag 
  USING GIN (to_tsvector('portuguese', content));
```

### **Monitoramento de Índices**

```sql
-- Ver uso de índices
SELECT 
  schemaname,
  tablename,
  indexname,
  idx_scan,  -- Quantas vezes foi usado
  idx_tup_read,
  idx_tup_fetch
FROM pg_stat_user_indexes
ORDER BY idx_scan DESC;

-- Identificar índices não usados
SELECT 
  schemaname,
  tablename,
  indexname
FROM pg_stat_user_indexes
WHERE idx_scan = 0
  AND indexname NOT LIKE '%_pkey';
```

---

## 📦 SCHEMAS JSONB

### **Princípios de Design**

1. **Validação via JSON Schema**: Todas as `attributes` JSONB devem ter schemas definidos
2. **Versionamento**: Campo `metadata.schema_version` obrigatório
3. **Retrocompatibilidade**: Novos campos são opcionais
4. **Documentação**: Schemas publicados em `/schemas/` do repositório

### **Schema Padrão para `attributes`**

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "properties": {
    "metadata": {
      "type": "object",
      "properties": {
        "schema_name": {"type": "string"},
        "schema_version": {"type": "string", "pattern": "^\\d+\\.\\d+$"}
      },
      "required": ["schema_name", "schema_version"]
    }
  },
  "additionalProperties": true
}
```

### **Exemplo: Schema de SKILLS**

Ver linha 58-91 do arquivo `Definicoes_Edu.txt` para schema completo.

---

## 📐 REGRAS DE NEGÓCIO

### **1. Workspaces Padrão**

**Ao criar usuário**:
- Criar `MyWorkspace` (PERSONAL, privado)
- Criar `SuperCompanion` no `MyWorkspace`
- Conceder acesso ao `OrgWorkspace` (se role != MS)

**Ao criar organização**:
- Criar `OrgWorkspace` (FUNCTIONAL, público)

### **2. Hierarquia de Roles**

```
MasterSys (MS)
  ↓ pode criar
OrgAdmin (OA)
  ↓ pode criar
WorkspaceManager (WM)
  ↓ pode dar acesso
User (UR)
```

**Poderes por Role**:

| Ação | MS | OA | WM | UR |
|------|----|----|----|----|
| Criar organização | ✅ | ❌ | ❌ | ❌ |
| Criar workspace | ✅ | ✅ | ❌ | ❌ |
| Criar companion funcional | ✅ | ✅ | ✅ | ❌ |
| Editar companion funcional | ✅ | ✅ | ✅ | ❌ |
| Editar SuperCompanion | ✅ | ✅ | ✅ | ✅ |
| Criar chat | ✅ | ✅ | ✅ | ✅ |
| Ver analytics org | ✅ | ✅ | ❌ | ❌ |

### **3. Companions**

**SuperCompanion**:
- Criado automaticamente no `MyWorkspace`
- Template genérico com skills padrão
- Editável pelo dono

**Companion Funcional**:
- Criado por OA/WM
- Compartilhado no workspace
- Usuários podem usar (REA) mas não editar

### **4. Artifacts**

- **Salvamento automático**: Todo artefato gerado é salvo no `MyWorkspace` do usuário
- **Compartilhamento opcional**: Usuário pode copiar para outros workspaces
- **Formato padrão**: Markdown + SVG → PDF

### **5. Knowledge Auto-Indexação**

Sistema indexa automaticamente:
- Chats do usuário (após X mensagens)
- Artifacts gerados
- Documentos carregados

**Configurações**:
```json
{
  "auto_index": {
    "chats": {
      "enabled": true,
      "min_messages": 5,
      "class_info": "PVT"
    },
    "artifacts": {
      "enabled": true,
      "class_info": "WSP"
    },
    "documents": {
      "enabled": true,
      "class_info": "ORG"
    }
  }
}
```

### **6. Convites**

**Usuário sem convite**:
- Cadastro livre (se permitido pela org)
- Acesso apenas ao `MyWorkspace`
- Role inicial: UR

**Usuário com convite**:
- Código de convite gerado por OA/WM
- Acesso imediato aos workspaces definidos
- Role definida no convite

---

## 🔄 MIGRAÇÕES E EVOLUÇÃO

### **Estratégia de Migração**

1. **Drizzle ORM**: Usar para gerar migrações
2. **Versionamento**: Seguir padrão `XXXX_description.sql`
3. **Rollback**: Sempre incluir `up.sql` e `down.sql`
4. **Testing**: Testar em ambiente staging antes de prod

### **Exemplo de Migração**

```sql
-- 0001_create_organizations.sql

-- UP
CREATE TABLE organizations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  attributes JSONB NOT NULL DEFAULT '{}'
);

CREATE INDEX idx_organizations_name ON organizations(name);
CREATE INDEX idx_organizations_active ON organizations(is_active) WHERE is_active = TRUE;

-- RLS
ALTER TABLE organizations ENABLE ROW LEVEL SECURITY;

CREATE POLICY org_access ON organizations
  FOR ALL
  USING (id = current_setting('app.organization_id')::UUID);

-- DOWN (rollback)
-- DROP POLICY org_access ON organizations;
-- DROP TABLE organizations;
```

### **Ordem de Criação de Tabelas**

1. ENUMs
2. `organizations`
3. `workspaces`
4. `users`
5. `workspace_users`
6. `companions`
7. `skills`
8. `steps`
9. `chats`
10. `executions`
11. `artifacts`
12. `knowledge_rag` (requer pgvector extension)
13. `tools_mcp`
14. `permissions_acl`

### **Extensões PostgreSQL Necessárias**

```sql
-- Instalar extensões
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgvector";
CREATE EXTENSION IF NOT EXISTS "pg_trgm"; -- Para full-text search
```

---

## 📊 RESUMO EXECUTIVO

### **Tabelas Core (5)**
- Organizations
- Workspaces
- Users
- Chats
- Artifacts

### **Tabelas AI (4)**
- Companions
- Skills
- Steps
- Executions

### **Tabelas Centrais (3)**
- Knowledge_RAG (pgvector)
- Tools_MCP
- Permissions_ACL

### **Tabelas de Junção (1)**
- Workspace_Users

### **ENUMs (10)**
- role_code, resource_kind, action, class_info
- workspace_type, companion_type, artifact_format
- execution_status, tool_type, auth_type

### **Total**: 13 tabelas + 10 ENUMs

---

## 🎯 PRÓXIMOS PASSOS (FUTURO)

### **Fase 2 - Memória Dinâmica**
- Tabela `user_memory` para aprendizado contínuo
- Tabela `conversation_memory` para contexto de longo prazo

### **Fase 3 - Workflows Multi-Agentes**
- Tabela `agent_workflows` para orquestração
- Tabela `agent_communications` para mensagens entre agentes

### **Fase 4 - Auditoria Completa**
- Tabela `audit_log` com triggers automáticos
- Logs de todas as operações (CREATE, UPDATE, DELETE)

---

## 📚 REFERÊNCIAS

- **Definições originais**: `projeto-docs-new/Definicoes_Edu.txt`
- **Diagrama conceitual**: `projeto-docs-new/Rabisco_edu.jpeg`
- **Diagrama SVG**: `projeto-docs-new/NOVO-MODELO-DADOS-HUMANA.svg`
- **PostgreSQL Row-Level Security**: https://www.postgresql.org/docs/current/ddl-rowsecurity.html
- **pgvector Extension**: https://github.com/pgvector/pgvector
- **Anthropic Workflows**: https://docs.anthropic.com/en/docs/agents-and-tools

---

**Documento gerado em**: 2025-01-15  
**Versão**: 2.0  
**Autor**: Sistema de Documentação Humana Companions  
**Status**: ✅ Aprovado para implementação
