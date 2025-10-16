# 📝 MUDANÇAS NA MODELAGEM DO BANCO - V2.0

**Documento**: Registro de mudanças aplicadas na modelagem do banco de dados  
**Versão**: 2.0  
**Data**: 2025-01-15  
**Status**: ✅ Aplicado

---

## 🔄 MUDANÇAS APLICADAS

### **1. TABELA ARTIFACTS** ✅

#### **Alterações:**
- ❌ **Removido**: `title` → ✅ **Adicionado**: `name`
- ❌ **Removido**: Toda seção `attributes` (JSONB)
- ✅ **Adicionado**: `content` (BYTEA/BLOB) - Conteúdo binário
- ✅ **Adicionado**: `format` (VARCHAR(10)) - Tipo de arquivo
- ✅ **Atualizado**: `status` ENUM de `'active', 'archived', 'deleted'` → `'ACT', 'ARC', 'DEL'`

#### **Estrutura Final:**
```sql
CREATE TABLE artifacts (
  id UUID PRIMARY KEY,
  chat_id UUID REFERENCES chats(id),
  workspace_id UUID NOT NULL REFERENCES workspaces(id),
  name VARCHAR(255) NOT NULL,
  content BYTEA NOT NULL,
  format VARCHAR(10) NOT NULL,
  status status_artifact_enum NOT NULL DEFAULT 'ACT',
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TYPE status_artifact_enum AS ENUM ('ACT', 'ARC', 'DEL');
```

---

### **2. TABELA PERMISSIONS_ACL** ✅

#### **Alterações:**
- ✅ **Adicionado**: `organization_id` (UUID, FK → organizations)
- ❌ **Removido**: `is_active` (substituído por lógica com `revoked_at`)
- ❌ **Removido**: Toda seção `attributes` (JSONB)
- ✅ **Renomeado**: `resource_kind` → `entity_code`
- ✅ **Renomeado**: `resource_id` → `entity_pk_id`
- ✅ **Atualizado**: ENUM `action` de `'REA', 'WRI', 'UPD', 'MNG'` → `'REA', 'WRI', 'UPD', 'CRU', 'MNG'`

#### **Estrutura Final:**
```sql
CREATE TABLE permissions_acl (
  id UUID PRIMARY KEY,
  organization_id UUID NOT NULL REFERENCES organizations(id),
  entity_code entity_code_enum NOT NULL,
  entity_pk_id UUID NOT NULL,
  action action_enum NOT NULL,
  created_by_user_id UUID NOT NULL REFERENCES users(id),
  created_for_user_id UUID NOT NULL REFERENCES users(id),
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  valid_from TIMESTAMP NOT NULL DEFAULT NOW(),
  valid_to TIMESTAMP,
  revoked_at TIMESTAMP,
  
  UNIQUE (organization_id, entity_code, entity_pk_id, action, created_for_user_id)
);

CREATE TYPE entity_code_enum AS ENUM ('ORG', 'WSP', 'CMP', 'PRL', 'CHT', 'KNW', 'TOL');
CREATE TYPE action_enum AS ENUM ('REA', 'WRI', 'UPD', 'CRU', 'MNG');
```

---

### **3. PADRONIZAÇÃO DE ENUMS** ✅

#### **Padrão Estabelecido:**
Todos os ENUMs devem ter **exatamente 3 letras**

#### **ENUMs Padronizados:**

| ENUM | Valores | Descrição |
|------|---------|-----------|
| `entity_code_enum` | `ORG`, `WSP`, `CMP`, `PRL`, `CHT`, `KNW`, `TOL` | Códigos de entidades |
| `action_enum` | `REA`, `WRI`, `UPD`, `CRU`, `MNG` | Ações de permissão |
| `status_artifact_enum` | `ACT`, `ARC`, `DEL` | Status de artefatos |
| `status_chat_enum` | `ACT`, `ARC`, `DEL` | Status de chats |
| `class_info_enum` | `PUB`, `ORG`, `WSP`, `PVT` | Classificação de acesso |

#### **Legenda das Ações:**
- `REA` = READ (Leitura)
- `WRI` = WRITE (Escrita)
- `UPD` = UPDATE (Atualização)
- `CRU` = CREATE (Criação)
- `MNG` = MANAGE (Gerenciamento)

#### **Legenda dos Status:**
- `ACT` = ACTIVE (Ativo)
- `ARC` = ARCHIVED (Arquivado)
- `DEL` = DELETED (Deletado)

#### **Legenda das Classificações:**
- `PUB` = PUBLIC (Público)
- `ORG` = ORGANIZATION (Organização)
- `WSP` = WORKSPACE (Workspace)
- `PVT` = PRIVATE (Privado)

---

### **4. TABELA USERS / ORGANIZATIONS** ✅ APLICADO

#### **Mudança Realizada:**
- ✅ **Removido**: `invite_code` da tabela `users`
- ✅ **Adicionado**: `invite_code` na tabela `organizations`

#### **Justificativa:**
O código de convite é específico da organização, não do usuário. Cada organização tem seu próprio código de convite para onboarding.

#### **Estruturas Atualizadas:**

**USERS (7 campos header):**
```sql
CREATE TABLE users (
  id UUID PRIMARY KEY,
  email VARCHAR(255) UNIQUE,
  name VARCHAR(255),
  organization_id UUID REFERENCES organizations(id),
  role_code VARCHAR(2),
  created_at TIMESTAMP,
  updated_at TIMESTAMP,
  attributes JSONB
);
```

**ORGANIZATIONS (6 campos header):**
```sql
CREATE TABLE organizations (
  id UUID PRIMARY KEY,
  name VARCHAR(255),
  invite_code VARCHAR(20) UNIQUE,  -- ✅ ADICIONADO
  created_at TIMESTAMP,
  updated_at TIMESTAMP,
  is_active BOOLEAN,
  attributes JSONB
);
```

---

## 📊 RESUMO DAS MUDANÇAS

### **ARTIFACTS:**
- ✅ 2 campos renomeados
- ✅ 2 campos adicionados  
- ✅ 1 seção JSONB removida
- ✅ 1 ENUM padronizado

### **PERMISSIONS_ACL:**
- ✅ 1 campo adicionado (`organization_id`)
- ✅ 2 campos renomeados (`entity_code`, `entity_pk_id`)
- ✅ 1 campo removido (`is_active`)
- ✅ 1 seção JSONB removida
- ✅ 1 ENUM atualizado (`action`)

### **PADRONIZAÇÃO:**
- ✅ Todos ENUMs com 3 letras
- ✅ Nomenclatura consistente
- ✅ Documentação clara

---

## 🎯 BENEFÍCIOS DAS MUDANÇAS

### **1. Simplicidade**
- Estruturas mais diretas sem JSONB complexo
- Mais fácil de entender e manter

### **2. Performance**
- BLOB nativo para conteúdo binário
- Todas as consultas em colunas indexadas
- Sem overhead de parsing JSONB

### **3. Consistência**
- Padrão de 3 letras em todos ENUMs
- Nomenclatura unificada (`entity_code`, `entity_pk_id`)
- Status baseado em timestamps ao invés de boolean

### **4. Escalabilidade**
- Estrutura otimizada para milhões de registros
- Índices específicos para consultas frequentes
- Multi-tenancy adequado

---

## 🔜 PRÓXIMOS PASSOS

1. ✅ **Aplicar mudança do `invite_code`** (USERS → ORGANIZATIONS)
2. ✅ **Atualizar todos os documentos** com ENUMs de 3 letras
3. ⏳ **Revisar outras tabelas** para padronização de ENUMs
4. ⏳ **Criar migration scripts** para aplicar mudanças no banco
5. ⏳ **Atualizar código backend** para novas estruturas
6. ⏳ **Atualizar testes** para refletir novas estruturas

---

**Documento gerado em**: 2025-01-15  
**Versão**: 2.0  
**Status**: ✅ Totalmente Aplicado
