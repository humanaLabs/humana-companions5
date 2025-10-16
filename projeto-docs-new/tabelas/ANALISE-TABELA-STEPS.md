# 📊 ANÁLISE DE MODELAGEM - TABELA STEPS (WorkflowSteps)

**Data**: 08/01/2025  
**Objetivo**: Definir quais dados devem ser colunas fixas e quais devem estar em atributos JSON

---

## 🎯 CONTEXTO DA FUNCIONALIDADE

A tabela **WorkflowSteps** armazena os passos individuais de workflows agênticos, compatível com AI SDK 5.0.

### **Onde é consumida:**
1. **Workflow Designer** (`components/flow/core/skills-flow-canvas.tsx`)
   - Visualiza steps no canvas
   - Drag and drop para organizar ordem
   - Edição de propriedades (nome, descrição, skill vinculada)
   - Conexões entre steps (dependencies)

2. **Workflow Visualizer** (`components/v5/workflows/workflow-visualizer.tsx`)
   - Exibe steps durante execução
   - Status visual (pending, running, completed, failed)
   - Linha do tempo de execução
   - Duração de cada step

3. **Workflow Execution Layout** (`components/v5/workflows/workflow-execution-layout.tsx`)
   - Progresso geral do workflow
   - Step atual destacado
   - Navegação entre steps
   - Detalhes de execução

4. **Workflow Templates** (`components/v5/workflows/workflow-templates.tsx`)
   - Lista steps de templates
   - Ordem, categoria (think/execute)
   - Dependências entre steps
   - Paralelização

5. **Properties Panel** (`components/flow/core/properties-panel.tsx`)
   - Edição de step selecionado
   - Configuração de skill vinculada
   - Custom prompt
   - Configurações de execução (timeout, retry)

### **APIs que consomem:**
- `GET /api/workflows/step` - Detalhes de step específico
- `GET /api/workflows` - Steps de workflow com joins
- `POST /api/workflows/step` - Controlar step (pause, resume, retry, skip)

---

## 📋 ANÁLISE DE CAMPOS

### ✅ **COLUNAS FIXAS (Headers)**
Campos usados em:
- Queries de join com workflows
- Ordenação de steps
- Filtragem por tipo/status
- Relacionamentos com skills/MCP

| Campo | Tipo | Justificativa |
|-------|------|---------------|
| **step_id** | UUID | ✅ PK, referenciado em WorkflowStepExecutions |
| **wkfl_id** | UUID | ✅ **FK crítica**, JOIN frequente, índice |
| **step_step_id** | VARCHAR(100) | ✅ **Identificador lógico**, único por workflow, usado em lógica |
| **step_title** | VARCHAR(255) | ✅ **Exibido na UI** (cards, canvas), busca |
| **step_description** | TEXT | ✅ **Tooltip, detalhes na UI** - pode ser TEXT puro |
| **step_order** | INTEGER | ✅ **ORDER BY crítico**, índice, sequência de execução |
| **step_type** | VARCHAR(50) | ✅ **Filtro frequente**, índice, lógica de execução |
| **skill_id** | UUID | ✅ **FK para Skills**, JOIN, SET NULL on delete |
| **mcp_mapping_id** | UUID | ✅ **FK para SkillMcpMapping**, JOIN, SET NULL |
| **step_skill_name** | VARCHAR(100) | ⚠️ **Redundante mas útil** - busca dinâmica sem JOIN |
| **step_tool_name** | VARCHAR(100) | ⚠️ **Redundante mas útil** - execução sem JOIN |
| **step_custom_prompt** | TEXT | ✅ **Usado em execução**, pode ser NULL se usa skill |
| **step_attributes** | JSONB | ✅ **Atributos JSONB** - ai_config, dependencies, conditions, loop_config, output_schema, metadata |
| **step_is_parallel** | BOOLEAN | ✅ **Lógica de execução**, queries de paralelização |
| **step_timeout_ms** | INTEGER | ✅ **Config de execução**, lógica de timeout |
| **step_retry_count** | INTEGER | ✅ **Config de execução**, lógica de retry |
| **step_retry_backoff_ms** | INTEGER | ✅ **Config de execução**, cálculo de delay |
| **step_expected_output_type** | VARCHAR(50) | ✅ **Validação de output**, lógica de processamento |
| **step_input_transform** | TEXT | ⚠️ **JavaScript code**, poderia ser JSON mas TEXT é mais direto |
| **step_output_transform** | TEXT | ⚠️ **JavaScript code**, poderia ser JSON mas TEXT é mais direto |
| **step_created_at** | TIMESTAMP | ✅ **Auditoria**, ORDER BY |
| **step_updated_at** | TIMESTAMP | ✅ **Auditoria**, trigger automático |

---

### 🗂️ **ATRIBUTOS JSON**
Campos que devem estar em JSONB por serem:
- Estruturas complexas/aninhadas
- Arrays de dados variáveis
- Configurações específicas por stepType

#### **1. aiConfig (JSONB)** ✅ Já está JSON
```json
{
  "model": "gpt-4o",
  "temperature": 0.7,
  "maxTokens": 2000,
  "topP": 1,
  "frequencyPenalty": 0,
  "presencePenalty": 0,
  "systemPrompt": "Você é um assistente especializado...",
  "stopSequences": ["\n\n", "---"],
  "tools": ["search", "calculator"],
  "toolChoice": "auto"
}
```
**Justificativa**: Configuração específica do AI SDK 5.0, varia por step, não usado em WHERE

#### **2. dependencies (JSONB)** ✅ Já está JSON
```json
["step-validacao", "step-busca-dados", "step-enriquecimento"]
```
**Justificativa**: Array de stepIds, tamanho variável, queries JSON (contains)

#### **3. conditions (JSONB)** ✅ Já está JSON
```json
{
  "type": "expression",
  "expression": "previousStep.output.status === 'success'",
  "operator": "AND",
  "rules": [
    {
      "field": "userData.role",
      "operator": "in",
      "value": ["admin", "manager"]
    },
    {
      "field": "context.budget",
      "operator": ">=",
      "value": 1000
    }
  ]
}
```
**Justificativa**: Condições complexas para executar step, lógica variável

#### **4. loopConfig (JSONB)** ✅ Já está JSON
```json
{
  "enabled": true,
  "type": "forEach",
  "iterableSource": "previousStep.output.items",
  "maxIterations": 100,
  "breakCondition": "item.processed === true",
  "timeoutMs": 300000,
  "parallelExecution": false,
  "batchSize": 10
}
```
**Justificativa**: Configuração de loops, varia por tipo de iteração

#### **5. outputSchema (JSONB)** ✅ Já está JSON
```json
{
  "type": "object",
  "properties": {
    "status": { "type": "string", "enum": ["success", "error"] },
    "data": { "type": "array" },
    "metadata": { "type": "object" }
  },
  "required": ["status"]
}
```
**Justificativa**: Schema Zod para validação, varia por step

#### **6. metadata (JSONB)** - **⚠️ ADICIONAR SE NÃO EXISTE**
```json
{
  "displaySettings": {
    "icon": "CheckCircle",
    "color": "#22c55e",
    "x": 100,
    "y": 200,
    "width": 200,
    "height": 80
  },
  "uiHints": {
    "collapsible": true,
    "showOutputPreview": true,
    "highlightOnError": true
  },
  "tags": ["validation", "critical"],
  "notes": "Step crítico: não pode falhar",
  "analytics": {
    "trackPerformance": true,
    "sendMetrics": true
  },
  "errorHandling": {
    "onFailure": "stop", // stop, continue, retry, fallback
    "fallbackStepId": "step-fallback-validation",
    "notifyOnError": ["admin@example.com"]
  }
}
```
**Justificativa**:
- Posicionamento no canvas (x, y, width, height)
- Configurações de UI (ícone, cor, colapsável)
- Tags para organização
- Notas do usuário
- Configurações de analytics
- Estratégias de erro não estruturais

---

## 🔄 MIGRAÇÃO RECOMENDADA

### **Schema Atual (95% correto)**
```typescript
export const workflowSteps = pgTable("WorkflowSteps", {
  // ✅ Identificação - Colunas corretas
  id: uuid("id").primaryKey().defaultRandom(),
  workflowId: uuid("workflowId").notNull().references(() => companionWorkflow.id),
  stepId: varchar("stepId", { length: 100 }).notNull(),
  title: varchar("title", { length: 255 }).notNull(),
  description: text("description"),
  stepOrder: integer("stepOrder").notNull(),
  
  // ✅ Configuração AI SDK 5.0 - Colunas corretas
  stepType: varchar("stepType", { 
    length: 50,
    enum: ["ai_generation", "tool_execution", "skill_execution", "mcp_call", 
           "condition_check", "loop_control", "parallel_execution", "data_transform"]
  }).notNull().default("ai_generation"),
  
  // ✅ Referências - Colunas corretas
  skillId: uuid("skillId").references(() => newSkill.id, { onDelete: "set null" }),
  mcpMappingId: uuid("mcpMappingId").references(() => skillMcpMapping.id),
  skillName: varchar("skillName", { length: 100 }),
  toolName: varchar("toolName", { length: 100 }),
  customPrompt: text("customPrompt"),
  
  // ✅ JSON - Correto
  aiConfig: jsonb("aiConfig").default({}),
  dependencies: jsonb("dependencies").default([]),
  conditions: jsonb("conditions").default({}),
  loopConfig: jsonb("loopConfig").default({}),
  outputSchema: jsonb("outputSchema").default({}),
  
  // ✅ Controle de Fluxo - Colunas corretas
  isParallel: boolean("isParallel").default(false),
  timeoutMs: integer("timeoutMs").default(30000),
  retryCount: integer("retryCount").default(0),
  retryBackoffMs: integer("retryBackoffMs").default(1000),
  
  // ✅ Transformações - TEXT correto
  inputTransform: text("inputTransform"),
  outputTransform: text("outputTransform"),
  expectedOutputType: varchar("expectedOutputType", { length: 50 }).default("text"),
  
  // ✅ Auditoria - Colunas corretas
  createdAt: timestamp("createdAt").defaultNow(),
  updatedAt: timestamp("updatedAt").defaultNow(),
});
```

### **⚠️ AJUSTE RECOMENDADO**
**Adicionar campo `metadata` JSONB** para dados extensíveis:

```sql
ALTER TABLE "WorkflowSteps" 
ADD COLUMN metadata JSONB DEFAULT '{}';

COMMENT ON COLUMN "WorkflowSteps".metadata IS 
'Metadados extensíveis: posição canvas, configurações UI, error handling, analytics';
```

```typescript
export const workflowSteps = pgTable("WorkflowSteps", {
  // ... campos existentes ...
  
  // ✨ NOVO: Metadados extensíveis
  metadata: jsonb("metadata").default({}),
});
```

---

## 📊 ÍNDICES RECOMENDADOS

```sql
-- ✅ Já existentes
CREATE INDEX idx_workflowsteps_wkfl ON workflow_steps(wkfl_id);
CREATE INDEX idx_workflowsteps_skill ON workflow_steps(skill_id);
CREATE INDEX idx_workflowsteps_mcp ON workflow_steps(mcp_mapping_id);
CREATE INDEX idx_workflowsteps_type ON workflow_steps(step_type);
CREATE INDEX idx_workflowsteps_order ON workflow_steps(wkfl_id, step_order);
CREATE UNIQUE INDEX unique_step_id_per_workflow ON workflow_steps(wkfl_id, step_step_id);
CREATE UNIQUE INDEX unique_step_order_per_workflow ON workflow_steps(wkfl_id, step_order);

-- ✅ Adicionar se não existir
CREATE INDEX idx_workflowsteps_parallel ON workflow_steps(step_is_parallel) 
  WHERE step_is_parallel = true;

-- 🔍 Índice GIN geral para step_attributes
CREATE INDEX idx_workflowsteps_attributes_gin ON workflow_steps 
  USING GIN (step_attributes);

-- 🔍 Índices GIN para consultas específicas em step_attributes
CREATE INDEX idx_workflowsteps_dependencies ON workflow_steps 
  USING GIN ((step_attributes->'dependencies') jsonb_path_ops);

CREATE INDEX idx_workflowsteps_metadata ON workflow_steps 
  USING GIN ((step_attributes->'metadata'));
```

---

## ✅ CONCLUSÃO

### **✅ Manter como COLUNAS:**
- Campos de identificação (id, workflowId, stepId, title)
- Foreign keys (skillId, mcpMappingId)
- Ordem de execução (stepOrder)
- Tipo de step (stepType)
- Configurações simples (timeoutMs, retryCount, isParallel)
- Transformações de código (inputTransform, outputTransform como TEXT)
- Timestamps (createdAt, updatedAt)

### **✅ Manter como JSON:**
- aiConfig (configuração do AI SDK)
- dependencies (array de stepIds)
- conditions (regras de execução)
- loopConfig (configuração de iteração)
- outputSchema (validação de saída)

### **✅ ADICIONAR como JSON:**
- **metadata** (posição canvas, UI settings, error handling, analytics)
  - Permite extensibilidade sem migrations
  - Dados de UI não usados em queries SQL diretas
  - Configurações variáveis por tipo de step

---

## 🎯 REGRAS DE DECISÃO

| Critério | Coluna Fixa | JSON |
|----------|-------------|------|
| Usado em ORDER BY | ✅ | ❌ |
| Foreign Key | ✅ | ❌ |
| Tipo de step (enum) | ✅ | ❌ |
| Array variável | ❌ | ✅ |
| Estrutura aninhada | ❌ | ✅ |
| Posição no canvas | ❌ | ✅ (metadata) |
| Config de erro | ❌ | ✅ (metadata) |
| JavaScript code | ✅ TEXT | ❌ |

---

## 💡 OBSERVAÇÕES IMPORTANTES

### **skillName e toolName redundantes?**
✅ **Mantidos como colunas** por performance:
- Evita JOIN com NewSkills em queries de execução
- Permite busca rápida sem JOIN
- Útil quando skillId é NULL (custom prompts)
- Overhead mínimo (VARCHAR 100)

### **inputTransform e outputTransform: TEXT ou JSON?**
✅ **Mantidos como TEXT**:
- Armazenam código JavaScript executável
- Não são queries JSON estruturadas
- TEXT é mais direto para strings de código
- Evita overhead de parsing JSON desnecessário

---

**Status**: ✅ Schema atual está 95% correto. Apenas adicionar campo `metadata` JSONB.

---

## 📜 SCRIPT SQL DE CRIAÇÃO COMPLETO

```sql
-- ============================================
-- TABELA: WorkflowSteps
-- Descrição: Passos individuais de workflows agênticos
-- Compatível com: AI SDK 5.0
-- ============================================

-- Criar ENUMs
CREATE TYPE step_type_enum AS ENUM (
  'ai_generation',
  'tool_execution', 
  'skill_execution',
  'mcp_call',
  'condition_check',
  'loop_control',
  'parallel_execution',
  'data_transform'
);

CREATE TYPE expected_output_type_enum AS ENUM (
  'text',
  'json',
  'markdown',
  'html',
  'code',
  'binary'
);

-- Criar tabela
CREATE TABLE workflow_steps (
  -- ============================================
  -- IDENTIFICAÇÃO E HIERARQUIA
  -- ============================================
  step_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  wkfl_id UUID NOT NULL REFERENCES companion_workflow(wkfl_id) ON DELETE CASCADE,
  step_step_id VARCHAR(100) NOT NULL,
  step_title VARCHAR(255) NOT NULL,
  step_description TEXT,
  step_order INTEGER NOT NULL,
  
  -- ============================================
  -- TIPO E CLASSIFICAÇÃO
  -- ============================================
  step_type step_type_enum NOT NULL DEFAULT 'ai_generation',
  
  -- ============================================
  -- REFERÊNCIAS
  -- ============================================
  skill_id UUID REFERENCES new_skills(skill_id) ON DELETE SET NULL,
  mcp_mapping_id UUID REFERENCES skill_mcp_mapping(mapping_id) ON DELETE SET NULL,
  step_skill_name VARCHAR(100),
  step_tool_name VARCHAR(100),
  step_custom_prompt TEXT,
  
  -- ============================================
  -- ATRIBUTOS JSONB
  -- ============================================
  step_attributes JSONB NOT NULL DEFAULT '{}'::jsonb,
  
  -- ============================================
  -- CONTROLE DE FLUXO
  -- ============================================
  step_is_parallel BOOLEAN NOT NULL DEFAULT false,
  step_timeout_ms INTEGER NOT NULL DEFAULT 30000,
  step_retry_count INTEGER NOT NULL DEFAULT 0,
  step_retry_backoff_ms INTEGER NOT NULL DEFAULT 1000,
  
  -- ============================================
  -- TRANSFORMAÇÕES
  -- ============================================
  step_input_transform TEXT,
  step_output_transform TEXT,
  step_expected_output_type expected_output_type_enum NOT NULL DEFAULT 'text',
  
  -- ============================================
  -- AUDITORIA
  -- ============================================
  step_created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  step_updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
  
  -- ============================================
  -- CONSTRAINTS
  -- ============================================
  CONSTRAINT unique_step_id_per_workflow UNIQUE (wkfl_id, step_step_id),
  CONSTRAINT unique_step_order_per_workflow UNIQUE (wkfl_id, step_order),
  CONSTRAINT check_timeout_positive CHECK (step_timeout_ms > 0),
  CONSTRAINT check_retry_count_positive CHECK (step_retry_count >= 0),
  CONSTRAINT check_retry_backoff_positive CHECK (step_retry_backoff_ms >= 0)
);

-- ============================================
-- ÍNDICES
-- ============================================

-- Índices para relacionamentos
CREATE INDEX idx_workflowsteps_wkfl ON workflow_steps(wkfl_id);
CREATE INDEX idx_workflowsteps_skill ON workflow_steps(skill_id);
CREATE INDEX idx_workflowsteps_mcp ON workflow_steps(mcp_mapping_id);

-- Índices para tipo e ordem
CREATE INDEX idx_workflowsteps_type ON workflow_steps(step_type);
CREATE INDEX idx_workflowsteps_order ON workflow_steps(wkfl_id, step_order);

-- Índice para steps paralelos
CREATE INDEX idx_workflowsteps_parallel ON workflow_steps(step_is_parallel) 
  WHERE step_is_parallel = true;

-- Índice GIN geral para attributes
CREATE INDEX idx_workflowsteps_attributes_gin ON workflow_steps 
  USING GIN (step_attributes);

-- Índices GIN para consultas específicas em step_attributes
CREATE INDEX idx_workflowsteps_dependencies ON workflow_steps 
  USING GIN ((step_attributes->'dependencies') jsonb_path_ops);
CREATE INDEX idx_workflowsteps_metadata ON workflow_steps 
  USING GIN ((step_attributes->'metadata'));
CREATE INDEX idx_workflowsteps_ai_config ON workflow_steps 
  USING GIN ((step_attributes->'ai_config'));

-- Índice para busca full-text no título
CREATE INDEX idx_workflowsteps_title_fts ON workflow_steps 
  USING GIN (to_tsvector('portuguese', step_title));

-- ============================================
-- COMENTÁRIOS
-- ============================================
COMMENT ON TABLE workflow_steps IS 
  'Passos individuais de workflows agênticos compatíveis com AI SDK 5.0';

COMMENT ON COLUMN workflow_steps.step_id IS 
  'Identificador lógico único por workflow, usado em referências de dependencies';

COMMENT ON COLUMN workflow_steps.ai_config IS 
  'Configuração do AI SDK 5.0: model, temperature, maxTokens, systemPrompt, tools, etc.';

COMMENT ON COLUMN workflow_steps.dependencies IS 
  'Array de step_ids que devem ser concluídos antes deste step';

COMMENT ON COLUMN workflow_steps.conditions IS 
  'Condições complexas para executar o step: expressions, rules, operators';

COMMENT ON COLUMN workflow_steps.loop_config IS 
  'Configuração de loops: type (forEach, while), iterableSource, maxIterations, breakCondition';

COMMENT ON COLUMN workflow_steps.output_schema IS 
  'JSON Schema (Zod) para validação do output do step';

COMMENT ON COLUMN workflow_steps.metadata IS 
  'Metadados extensíveis: posição canvas (x,y), configurações UI, error handling, analytics';

-- ============================================
-- TRIGGER PARA UPDATED_AT
-- ============================================
CREATE OR REPLACE FUNCTION update_workflow_steps_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_workflow_steps_updated_at
  BEFORE UPDATE ON workflow_steps
  FOR EACH ROW
  EXECUTE FUNCTION update_workflow_steps_updated_at();

-- ============================================
-- RLS (Row Level Security)
-- ============================================
ALTER TABLE workflow_steps ENABLE ROW LEVEL SECURITY;

-- Policy: Users can only see steps from workflows they own
CREATE POLICY workflow_steps_select_policy ON workflow_steps
  FOR SELECT
  USING (
    wkfl_id IN (
      SELECT id FROM companion_workflow 
      WHERE organization_id = current_setting('app.current_organization_id')::uuid
    )
  );

-- Policy: Users can only insert steps into workflows they own
CREATE POLICY workflow_steps_insert_policy ON workflow_steps
  FOR INSERT
  WITH CHECK (
    wkfl_id IN (
      SELECT id FROM companion_workflow 
      WHERE organization_id = current_setting('app.current_organization_id')::uuid
    )
  );

-- Policy: Users can only update steps from workflows they own
CREATE POLICY workflow_steps_update_policy ON workflow_steps
  FOR UPDATE
  USING (
    wkfl_id IN (
      SELECT id FROM companion_workflow 
      WHERE organization_id = current_setting('app.current_organization_id')::uuid
    )
  );

-- Policy: Users can only delete steps from workflows they own
CREATE POLICY workflow_steps_delete_policy ON workflow_steps
  FOR DELETE
  USING (
    wkfl_id IN (
      SELECT id FROM companion_workflow 
      WHERE organization_id = current_setting('app.current_organization_id')::uuid
    )
  );
```

---

**Documento gerado em**: 2025-01-15  
**Versão**: 2.0  
**Status**: ✅ Completo com SQL

