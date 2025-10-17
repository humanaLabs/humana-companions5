# 📊 ANÁLISE DE MODELAGEM - TABELA SKILLS

**Data**: 08/01/2025  
**Objetivo**: Definir quais dados devem ser colunas fixas e quais devem estar em atributos JSON

---

## 🎯 CONTEXTO DA FUNCIONALIDADE

A tabela **Skills** armazena as capacidades (habilidades) dos Companions, seguindo o padrão do AI SDK 5.0. 

### **Onde é consumida:**
1. **Skill Selector** (`components/flow/core/skill-selector.tsx`)
   - Lista skills por companion
   - Filtra por categoria (THINK/ACT)
   - Exibe nome, descrição, ícone, categoria
   - Drag and drop de skills para workflows

2. **Skills Sidebar** (`components/flow/core/skills-sidebar.tsx`)
   - Exibe skills do companion selecionado
   - Mostra nome, descrição, tipo (PENSAR/EXECUTAR)
   - Suporta drag para canvas de workflow

3. **Skills Carousel** (`components/skills-carousel.tsx`)
   - Visualização em cards
   - Exibe: nome, descrição, categoria, ícone, usageCount
   - Botões de editar/deletar
   - Badge de categoria com cores

4. **Chat V5** (`components/v5/chat/chat-v5-with-workers-integration.tsx`)
   - Converte skills em tools do AI SDK 5.0
   - Usa toolName, toolSchema, toolDescription para LLM
   - Executa skills durante chat

5. **Workflow Designer** (`components/flow/core/skills-flow-canvas.tsx`)
   - Adiciona skills como steps em workflows
   - Referencia skillId em WorkflowSteps

### **APIs que consomem:**
- `GET /api/skills` - Lista skills por organizationId, companionId, category
- `GET /api/v5/skills` - Skills ativas para Chat V5
- `GET /api/companions/skills` - Skills de companion específico
- `GET /api/workflow-skills` - Skills vinculadas a workflows

---

## 📋 ANÁLISE DE CAMPOS

### ✅ **COLUNAS FIXAS (Headers)**
Campos usados em:
- Queries frequentes (WHERE, JOIN, ORDER BY)
- Índices de busca
- Relacionamentos (Foreign Keys)
- Filtros de UI
- Queries de performance

| Campo | Tipo | Justificativa |
|-------|------|---------------|
| **skil_id** | UUID | PK, referenciado em WorkflowSteps, SkillExecutions |
| **skil_name** | VARCHAR(100) | ✅ **Busca/filtro frequente**, índice único, exibido em UI |
| **skil_display_name** | VARCHAR(150) | ✅ **Exibição principal na UI** (cards, selectors) |
| **skil_description** | TEXT | ✅ **Exibido em cards, tooltips** - pode ser TEXT puro |
| **companion_id** | UUID | ✅ **FK crítica**, filtro principal, JOIN com Companions |
| **organization_id** | UUID | ✅ **FK crítica**, filtro de tenancy, índice |
| **skil_category** | VARCHAR(50) | ✅ **Filtro frequente** (THINK/ACT, API, etc), índice |
| **skil_tool_name** | VARCHAR(100) | ✅ **Identificador único da tool no AI SDK 5.0** |
| **skil_tool_description** | TEXT | ✅ **Usado pelo LLM para entender quando usar a tool** |
| **skil_execution_type** | VARCHAR(20) | ✅ **Filtro por tipo de execução**, índice (sync/async) |
| **skil_version** | VARCHAR(20) | ✅ **Controle de versão**, queries de compatibilidade |
| **skil_is_active** | BOOLEAN | ✅ **Filtro crítico** (só buscar ativas), índice WHERE |
| **skil_is_deprecated** | BOOLEAN | ✅ **Controle de ciclo de vida**, filtros |
| **skil_mcp_integration** | BOOLEAN | ✅ **Filtro por tipo de integração** |
| **skil_has_mcp_mapping** | BOOLEAN | ✅ **Filtro de configuração MCP** |
| **mcp_server_id** | UUID | ✅ **FK para MCPServers**, JOIN quando necessário |
| **skil_max_retries** | INTEGER | ✅ **Config de execução**, usado em lógica |
| **skil_timeout_ms** | INTEGER | ✅ **Config de execução**, usado em lógica |
| **skil_cacheable** | BOOLEAN | ✅ **Lógica de cache**, queries de otimização |
| **skil_cache_expiry_ms** | INTEGER | ✅ **Config de cache** |
| **skil_avg_execution_time_ms** | NUMERIC | ✅ **Métricas de performance**, ORDER BY, dashboards |
| **skil_success_rate** | NUMERIC | ✅ **Métricas de performance**, ORDER BY, índice |
| **skil_error_rate** | NUMERIC | ✅ **Métricas de performance**, alertas |
| **skil_usage_count** | INTEGER | ✅ **Contador de uso**, ORDER BY, índice, dashboard |
| **skil_last_used** | TIMESTAMP | ✅ **Queries temporais**, ORDER BY recentes |
| **skil_attributes** | JSONB | ✅ **Atributos JSONB** - tool_schema, metadata |
| **skil_created_at** | TIMESTAMP | ✅ **Auditoria**, ORDER BY cronológico |
| **skil_updated_at** | TIMESTAMP | ✅ **Auditoria**, trigger automático |

---

### 🗂️ **ATRIBUTOS JSON**
Campos que devem estar em JSONB por serem:
- Estruturas complexas/aninhadas
- Esquemas variáveis/extensíveis
- Não usados em queries diretas
- Configurações específicas por tipo

#### **1. toolSchema (JSONB)** ✅ Já está JSON
```json
{
  "type": "object",
  "properties": {
    "query": { "type": "string", "description": "Texto da pesquisa" },
    "filters": { "type": "object" },
    "maxResults": { "type": "number", "default": 10 }
  },
  "required": ["query"]
}
```
**Justificativa**: Schema Zod complexo, varia por skill, não usado em WHERE

#### **2. responseSchema (JSONB)** ✅ Já está JSON
```json
{
  "type": "object",
  "properties": {
    "results": { "type": "array" },
    "totalFound": { "type": "number" },
    "source": { "type": "string" }
  }
}
```
**Justificativa**: Schema de resposta esperada, varia por skill

#### **3. metadata (JSONB)** - **⚠️ ADICIONAR SE NÃO EXISTE**
```json
{
  "icon": "Search",
  "color": "#3b82f6",
  "tags": ["pesquisa", "web", "rag"],
  "examples": [
    {
      "input": { "query": "IA generativa" },
      "expectedOutput": { "results": [...] }
    }
  ],
  "dependencies": ["rag_service", "search_api"],
  "pricing": {
    "costPerExecution": 0.01,
    "currency": "USD"
  },
  "documentation": {
    "url": "https://docs.example.com/skills/search",
    "changelog": "v1.2.0 - Adicionado filtro por data"
  }
}
```
**Justificativa**: 
- Ícone/cor usados na UI mas não em queries SQL
- Tags extensíveis para categorização
- Exemplos de uso (documentação)
- Dependências de serviços externos
- Dados de precificação variáveis
- Links de documentação

---

## 🔄 MIGRAÇÃO RECOMENDADA

### **Schema Atual (Correto)**
```typescript
export const newSkill = pgTable("NewSkills", {
  // ✅ Campos estruturais já estão como colunas
  id: uuid("id").primaryKey().defaultRandom(),
  name: varchar("name", { length: 100 }).notNull(),
  displayName: varchar("displayName", { length: 150 }),
  description: text("description").notNull(),
  companionId: uuid("companionId").notNull().references(() => newCompanion.id),
  organizationId: uuid("organizationId").references(() => organization.id),
  category: varchar("category", { length: 50 }),
  
  // ✅ AI SDK 5.0 - Colunas corretas
  toolName: varchar("toolName", { length: 100 }).notNull(),
  toolSchema: jsonb("toolSchema").notNull(), // ✅ JSON
  responseSchema: jsonb("responseSchema"), // ✅ JSON
  toolDescription: text("toolDescription"),
  executionType: varchar("executionType", { length: 20 }).default("sync"),
  
  // ✅ Configurações - Colunas corretas
  maxRetries: integer("maxRetries").default(3),
  timeoutMs: integer("timeoutMs").default(30000),
  cacheable: boolean("cacheable").default(false),
  cacheExpiryMs: integer("cacheExpiryMs").default(300000),
  
  // ✅ Performance - Colunas corretas
  avgExecutionTimeMs: numeric("avgExecutionTimeMs"),
  successRate: numeric("successRate"),
  errorRate: numeric("errorRate"),
  usageCount: integer("usageCount").default(0),
  lastUsed: timestamp("lastUsed"),
  
  // ✅ Controle - Colunas corretas
  version: varchar("version", { length: 20 }).default("1.0.0"),
  isActive: boolean("isActive").default(true),
  isDeprecated: boolean("isDeprecated").default(false),
  
  // ✅ MCP - Colunas corretas
  mcpIntegration: boolean("mcpIntegration").default(false),
  hasMcpMapping: boolean("hasMcpMapping").default(false),
  mcpServerId: uuid("mcpServerId").references(() => mcpServer.id),
  
  // ✅ Auditoria - Colunas corretas
  createdAt: timestamp("createdAt").defaultNow(),
  updatedAt: timestamp("updatedAt").defaultNow(),
});
```

### **⚠️ AJUSTE RECOMENDADO**
**Adicionar campo `metadata` JSONB** para dados extensíveis:

```sql
ALTER TABLE "NewSkills" 
ADD COLUMN metadata JSONB DEFAULT '{}';
```

```typescript
export const newSkill = pgTable("NewSkills", {
  // ... campos existentes ...
  
  // ✨ NOVO: Metadados extensíveis
  metadata: jsonb("metadata").default({}),
});
```

---

## 📊 ÍNDICES RECOMENDADOS

```sql
-- ✅ Já existentes
CREATE INDEX idx_newskills_org ON new_skills(organization_id);
CREATE INDEX idx_newskills_active ON new_skills(skil_is_active) WHERE skil_is_active = TRUE;
CREATE INDEX idx_newskills_execution_type ON new_skills(skil_execution_type);
CREATE INDEX idx_newskills_usage ON new_skills(skil_usage_count DESC);
CREATE INDEX idx_newskills_performance ON new_skills(skil_success_rate DESC, skil_avg_execution_time_ms);
CREATE UNIQUE INDEX unique_skill_name_per_org ON new_skills(organization_id, skil_name);

-- ✅ Adicionar se não existir
CREATE INDEX idx_newskills_companion ON new_skills(companion_id);
CREATE INDEX idx_newskills_category ON new_skills(skil_category);
CREATE INDEX idx_newskills_last_used ON new_skills(skil_last_used DESC);

-- 🔍 Índice GIN geral para skil_attributes
CREATE INDEX idx_newskills_attributes_gin ON new_skills USING GIN (skil_attributes);

-- 🔍 Índices GIN para consultas específicas em skil_attributes
CREATE INDEX idx_newskills_tool_schema ON new_skills USING GIN ((skil_attributes->'tool_schema'));
CREATE INDEX idx_newskills_metadata ON new_skills USING GIN ((skil_attributes->'metadata'));
```

---

## ✅ CONCLUSÃO

### **✅ Manter como COLUNAS:**
- Campos de identificação (id, name, toolName)
- Foreign keys (companionId, organizationId, mcpServerId)
- Campos de filtro/busca (category, isActive, executionType)
- Métricas de performance (usageCount, successRate, avgExecutionTimeMs)
- Configurações de execução (timeoutMs, maxRetries, cacheable)
- Timestamps de auditoria (createdAt, updatedAt, lastUsed)

### **✅ Manter como JSON:**
- toolSchema (schema Zod complexo)
- responseSchema (estrutura de resposta variável)

### **✅ ADICIONAR como JSON:**
- **metadata** (ícone, cor, tags, exemplos, documentação, pricing)
  - Permite extensibilidade sem migrations
  - Dados de UI não usados em queries SQL
  - Facilita evolução do sistema

---

## 🎯 REGRAS DE DECISÃO

| Critério | Coluna Fixa | JSON |
|----------|-------------|------|
| Usado em WHERE/JOIN | ✅ | ❌ |
| Usado em ORDER BY | ✅ | ❌ |
| Tem índice | ✅ | ❌ |
| Foreign Key | ✅ | ❌ |
| Estrutura variável | ❌ | ✅ |
| Dados aninhados | ❌ | ✅ |
| Extensível sem migration | ❌ | ✅ |
| Busca full-text | ❌ | ✅ (GIN) |

---

**Status**: ✅ Schema atual está 95% correto. Apenas adicionar campo `metadata` JSONB.

