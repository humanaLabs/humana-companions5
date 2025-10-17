# 📊 ANÁLISE DE MODELAGEM - TABELA EXECUTIONS (SkillExecutions + WorkflowExecutions)

**Data**: 08/01/2025  
**Objetivo**: Definir quais dados devem ser colunas fixas e quais devem estar em atributos JSON

---

## 🎯 CONTEXTO DA FUNCIONALIDADE

Duas tabelas de execução no sistema:
1. **SkillExecutions** - Rastreamento de execuções individuais de skills
2. **WorkflowExecutions** - Rastreamento de execuções completas de workflows

---

## 📋 TABELA 1: SkillExecutions

### **Onde é consumida:**
1. **Skill Executor** (`components/v1/chat/modules/skills/core/skill-executor.ts`)
   - Cria registro ao iniciar execução
   - Atualiza status (pending → running → completed/failed)
   - Armazena input/output/error

2. **AI SDK Elements** (`components/v5/chat/ai-sdk-elements.tsx`)
   - Exibe execuções de skills no chat
   - Status visual (loading, success, error)
   - Tempo de execução

3. **Chat V5** - Histórico de execuções
   - Lista execuções por sessão
   - Métricas de performance
   - Debug de erros

### **APIs que consomem:**
- `GET /api/workers/execute` - Status de execução
- Queries internas de auditoria e analytics

---

### ✅ **COLUNAS FIXAS (Headers) - SkillExecutions**

| Campo | Tipo | Justificativa |
|-------|------|---------------|
| **exec_id** | UUID | ✅ PK, referência em logs |
| **skill_id** | UUID | ✅ **FK crítica**, JOIN com Skills, índice |
| **companion_id** | UUID | ✅ **FK crítica**, filtro por companion, índice |
| **user_id** | UUID | ✅ **FK crítica**, auditoria, filtro por usuário |
| **exec_status** | VARCHAR(20) | ✅ **Filtro frequente**, índice, dashboard (pending/running/completed/failed/timeout) |
| **exec_started_at** | TIMESTAMP | ✅ **ORDER BY crítico**, índice, queries temporais |
| **exec_completed_at** | TIMESTAMP | ✅ **Cálculo de duração**, queries temporais |
| **exec_duration_ms** | INTEGER | ✅ **Métricas de performance**, ORDER BY, agregações |
| **exec_session_id** | VARCHAR(100) | ✅ **Filtro por sessão**, índice, rastreamento |
| **exec_conversation_id** | VARCHAR(100) | ✅ **Filtro por conversa**, JOIN com chats |
| **exec_step_number** | INTEGER | ✅ **Ordem em workflow**, ORDER BY |
| **exec_error_message** | TEXT | ⚠️ **Mensagem simples de erro** - pode ser TEXT direto |
| **exec_attributes** | JSONB | ✅ **Atributos JSONB** - input_data, output_data, metadata |
| **exec_created_at** | TIMESTAMP | ✅ **Auditoria**, ORDER BY |

---

### 🗂️ **ATRIBUTOS JSON - SkillExecutions**

#### **1. inputData (JSONB)** ✅ Já está JSON
```json
{
  "query": "Buscar fornecedores ativos",
  "filters": {
    "status": "active",
    "region": "southeast"
  },
  "context": {
    "userId": "user-123",
    "organizationId": "org-456"
  }
}
```
**Justificativa**: Estrutura variável por skill, não usado em WHERE direto

#### **2. outputData (JSONB)** ✅ Já está JSON
```json
{
  "results": [
    {
      "id": "supplier-1",
      "name": "Fornecedor A",
      "status": "active"
    }
  ],
  "totalFound": 15,
  "processingTime": 1234,
  "source": "database"
}
```
**Justificativa**: Estrutura variável, análise posterior com queries JSON

#### **3. metadata (JSONB)** ✅ Já está JSON
```json
{
  "environment": "production",
  "clientVersion": "5.0.1",
  "ipAddress": "192.168.1.100",
  "userAgent": "Mozilla/5.0...",
  "performance": {
    "dbQueryTime": 45,
    "apiCallTime": 123,
    "transformTime": 12
  },
  "retry": {
    "attemptNumber": 2,
    "maxRetries": 3,
    "previousErrors": ["Timeout", "Connection refused"]
  },
  "cost": {
    "tokensUsed": 0,
    "estimatedCost": 0.0
  }
}
```
**Justificativa**: Metadados extensíveis, não usados em filtros principais

---

### **⚠️ AJUSTES RECOMENDADOS - SkillExecutions**

**Nenhum ajuste necessário** - Schema atual está correto:
```typescript
export const skillExecution = pgTable("SkillExecutions", {
  id: uuid("id").primaryKey().defaultRandom(),
  skillId: uuid("skillId").notNull().references(() => newSkill.id),
  companionId: uuid("companionId").notNull().references(() => newCompanion.id),
  userId: uuid("userId").notNull().references(() => user.id),
  
  // ✅ Dados de execução - JSON correto
  inputData: jsonb("inputData").notNull().default({}),
  outputData: jsonb("outputData").default({}),
  errorMessage: text("errorMessage"),
  
  // ✅ Status e timing - Colunas corretas
  status: varchar("status", { 
    length: 20,
    enum: ["pending", "running", "completed", "failed", "timeout"]
  }).notNull().default("pending"),
  startedAt: timestamp("startedAt").defaultNow(),
  completedAt: timestamp("completedAt"),
  durationMs: integer("durationMs"),
  
  // ✅ Contexto - Colunas corretas
  sessionId: varchar("sessionId", { length: 100 }),
  conversationId: varchar("conversationId", { length: 100 }),
  stepNumber: integer("stepNumber").default(1),
  
  // ✅ Metadata - JSON correto
  metadata: jsonb("metadata").default({}),
  createdAt: timestamp("createdAt").defaultNow(),
});
```

---

## 📋 TABELA 2: WorkflowExecutions

### **Onde é consumida:**
1. **Workflow Executor** (`lib/services/workflow-executor.ts`)
   - Cria execução ao iniciar workflow
   - Atualiza status de cada step
   - Armazena resultados intermediários

2. **Workflow Visualizer** (`components/v5/workflows/workflow-visualizer.tsx`)
   - Exibe progresso em tempo real
   - Status de cada step
   - Resultados intermediários

3. **Workflow Execution Layout** (`components/v5/workflows/workflow-execution-layout.tsx`)
   - Barra de progresso geral
   - Navegação entre steps
   - Controles (pause, resume, cancel)

4. **Workflow Status API** (`app/api/workflows/status/route.ts`)
   - Busca status completo
   - Join com steps
   - Histórico de execuções

### **APIs que consomem:**
- `GET /api/workflows/execute` - Status de execução
- `POST /api/workflows/execute` - Iniciar execução
- `GET /api/workflows/status` - Status detalhado

---

### ✅ **COLUNAS FIXAS (Headers) - WorkflowExecutions**

| Campo | Tipo | Justificativa |
|-------|------|---------------|
| **wkex_id** | UUID | ✅ PK, referência em WorkflowStepExecutions |
| **wkex_execution_id** | VARCHAR(100) | ✅ **Identificador único**, índice UNIQUE, busca rápida |
| **wkfl_id** | UUID | ✅ **FK crítica**, JOIN com CompanionWorkflows, índice |
| **companion_id** | UUID | ✅ **FK crítica**, filtro por companion |
| **user_id** | UUID | ✅ **FK crítica**, auditoria, filtro |
| **organization_id** | UUID | ✅ **FK crítica**, tenancy, índice |
| **wkex_session_id** | VARCHAR(100) | ✅ **Filtro por sessão**, índice |
| **wkex_conversation_id** | VARCHAR(100) | ✅ **Filtro por conversa** |
| **wkex_status** | VARCHAR(20) | ✅ **Filtro frequente**, índice (pending/running/completed/failed/cancelled/paused) |
| **wkex_current_step_id** | VARCHAR(100) | ✅ **Estado atual**, queries de progresso |
| **wkex_current_step_order** | INTEGER | ✅ **Posição atual**, ORDER BY, progresso |
| **wkex_total_steps** | INTEGER | ✅ **Cálculo de % progresso** |
| **wkex_completed_steps** | INTEGER | ✅ **Contador de progresso** |
| **wkex_started_at** | TIMESTAMP | ✅ **ORDER BY crítico**, índice, queries temporais |
| **wkex_completed_at** | TIMESTAMP | ✅ **Cálculo de duração** |
| **wkex_total_duration_ms** | INTEGER | ✅ **Métricas de performance**, agregações |
| **wkex_avg_step_duration_ms** | REAL | ✅ **Métricas de performance**, análise |
| **wkex_error_message** | TEXT | ⚠️ **Erro geral do workflow** - TEXT direto |
| **wkex_error_step** | VARCHAR(100) | ✅ **Step que falhou**, debug |
| **wkex_debug_mode** | BOOLEAN | ✅ **Filtro de debug** |
| **wkex_log_level** | VARCHAR(20) | ✅ **Filtro de logs** (info/debug/error) |
| **wkex_attributes** | JSONB | ✅ **Atributos JSONB** - initial_input, final_output, step_results, execution_config, metadata |
| **wkex_created_at** | TIMESTAMP | ✅ **Auditoria**, ORDER BY |
| **wkex_updated_at** | TIMESTAMP | ✅ **Auditoria**, trigger automático |

---

### 🗂️ **ATRIBUTOS JSON - WorkflowExecutions**

#### **1. initialInput (JSONB)** ✅ Já está JSON
```json
{
  "userRequest": "Criar relatório de vendas Q4 2024",
  "context": {
    "organizationId": "org-123",
    "userId": "user-456",
    "timezone": "America/Sao_Paulo"
  },
  "parameters": {
    "year": 2024,
    "quarter": 4,
    "format": "pdf"
  }
}
```
**Justificativa**: Estrutura variável por workflow

#### **2. finalOutput (JSONB)** ✅ Já está JSON
```json
{
  "status": "success",
  "reportUrl": "https://storage.example.com/reports/q4-2024.pdf",
  "summary": {
    "totalSales": 1500000,
    "growth": 15.3
  },
  "executionSummary": {
    "stepsCompleted": 8,
    "totalDuration": 45000,
    "warnings": []
  }
}
```
**Justificativa**: Resultado final estruturado

#### **3. intermediateResults (JSONB)** ✅ Já está JSON
```json
{
  "step-validation": {
    "validated": true,
    "timestamp": "2025-01-08T10:30:00Z"
  },
  "step-fetch-data": {
    "recordsFetched": 1500,
    "duration": 2340
  },
  "step-generate-report": {
    "pages": 12,
    "size": "2.3MB"
  }
}
```
**Justificativa**: Resultados por step, estrutura dinâmica

#### **4. aiSdkMessages (JSONB)** ✅ Já está JSON
```json
[
  {
    "role": "system",
    "content": "Você é um assistente de relatórios..."
  },
  {
    "role": "user",
    "content": "Criar relatório Q4 2024"
  },
  {
    "role": "assistant",
    "content": "Iniciando geração do relatório...",
    "toolCalls": [...]
  }
]
```
**Justificativa**: Array de mensagens AI SDK 5.0, replay de conversa

#### **5. aiSdkSteps (JSONB)** ✅ Já está JSON
```json
[
  {
    "stepId": "step-1",
    "toolName": "fetch_sales_data",
    "input": {...},
    "output": {...},
    "tokens": 250,
    "duration": 1234
  },
  {
    "stepId": "step-2",
    "toolName": "generate_chart",
    "input": {...},
    "output": {...},
    "tokens": 180,
    "duration": 2100
  }
]
```
**Justificativa**: Steps do AI SDK para debug e replay

#### **6. aiSdkCallbacks (JSONB)** ✅ Já está JSON
```json
{
  "onStepStart": [
    {"timestamp": "2025-01-08T10:30:00Z", "stepId": "step-1"}
  ],
  "onStepFinish": [
    {"timestamp": "2025-01-08T10:30:05Z", "stepId": "step-1", "result": "success"}
  ],
  "onError": [
    {"timestamp": "2025-01-08T10:35:00Z", "error": "Timeout on step-3"}
  ]
}
```
**Justificativa**: Callbacks do AI SDK, auditoria detalhada

#### **7. executionConfig (JSONB)** ✅ Já está JSON
```json
{
  "maxSteps": 50,
  "timeout": 300000,
  "retryStrategy": {
    "maxRetries": 3,
    "backoffMs": 1000
  },
  "parallelExecution": {
    "enabled": true,
    "maxConcurrent": 5
  },
  "notifications": {
    "onComplete": ["admin@example.com"],
    "onError": ["ops@example.com"]
  }
}
```
**Justificativa**: Configuração complexa, varia por workflow

#### **8. metadata (JSONB)** ✅ Já está JSON
```json
{
  "trigger": "manual", // manual, scheduled, webhook, event
  "source": "chat-ui",
  "clientVersion": "5.0.1",
  "environment": "production",
  "cost": {
    "totalTokens": 2500,
    "estimatedCost": 0.15,
    "currency": "USD"
  },
  "performance": {
    "dbQueries": 45,
    "apiCalls": 8,
    "cacheHits": 12
  },
  "analytics": {
    "trackingId": "analytics-123",
    "experimentGroup": "A"
  }
}
```
**Justificativa**: Metadados extensíveis, não usados em filtros principais

---

### **⚠️ AJUSTES RECOMENDADOS - WorkflowExecutions**

**Schema atual está correto**, mas verificar se tem campo `executionConfig`:

```typescript
export const workflowExecutions = pgTable("WorkflowExecutions", {
  id: uuid("id").primaryKey().defaultRandom(),
  executionId: varchar("executionId", { length: 100 }).notNull().unique(),
  workflowId: uuid("workflowId").notNull().references(() => companionWorkflow.id),
  companionId: uuid("companionId").notNull().references(() => newCompanion.id),
  
  // ✅ Contexto - Colunas corretas
  userId: uuid("userId").notNull().references(() => user.id),
  organizationId: uuid("organizationId").notNull().references(() => organization.id),
  sessionId: varchar("sessionId", { length: 100 }),
  conversationId: varchar("conversationId", { length: 100 }),
  
  // ✅ Estado - Colunas corretas
  status: varchar("status", { 
    length: 20,
    enum: ["pending", "running", "completed", "failed", "cancelled", "paused"]
  }).notNull().default("pending"),
  currentStepId: varchar("currentStepId", { length: 100 }),
  currentStepOrder: integer("currentStepOrder").default(0),
  totalSteps: integer("totalSteps").default(0),
  completedSteps: integer("completedSteps").default(0),
  
  // ✅ Dados - JSON correto
  initialInput: jsonb("initialInput").notNull().default({}),
  finalOutput: jsonb("finalOutput").default({}),
  intermediateResults: jsonb("intermediateResults").default({}),
  errorMessage: text("errorMessage"),
  errorStep: varchar("errorStep", { length: 100 }),
  
  // ✅ AI SDK 5.0 - JSON correto
  aiSdkMessages: jsonb("aiSdkMessages").default([]),
  aiSdkSteps: jsonb("aiSdkSteps").default([]),
  aiSdkCallbacks: jsonb("aiSdkCallbacks").default({}),
  
  // ✅ Timing - Colunas corretas
  startedAt: timestamp("startedAt").defaultNow(),
  completedAt: timestamp("completedAt"),
  totalDurationMs: integer("totalDurationMs"),
  avgStepDurationMs: real("avgStepDurationMs"),
  
  // ✅ Configuração - JSON
  executionConfig: jsonb("executionConfig").default({}), // ⚠️ VERIFICAR SE EXISTE
  debugMode: boolean("debugMode").default(false),
  logLevel: varchar("logLevel", { length: 20 }).default("info"),
  
  // ✅ Metadata - JSON
  metadata: jsonb("metadata").default({}),
  
  // ✅ Auditoria
  createdAt: timestamp("createdAt").defaultNow(),
  updatedAt: timestamp("updatedAt").defaultNow(),
});
```

---

## 📊 ÍNDICES RECOMENDADOS

### **SkillExecutions**
```sql
-- ✅ Já existentes
CREATE INDEX idx_skillexecutions_skill ON "SkillExecutions"(skillId);
CREATE INDEX idx_skillexecutions_companion ON "SkillExecutions"(companionId);
CREATE INDEX idx_skillexecutions_user ON "SkillExecutions"(userId);
CREATE INDEX idx_skillexecutions_status ON "SkillExecutions"(status);
CREATE INDEX idx_skillexecutions_session ON "SkillExecutions"(sessionId);
CREATE INDEX idx_skillexecutions_created ON "SkillExecutions"(createdAt DESC);

-- ✅ Adicionar
CREATE INDEX idx_skillexecutions_status_created ON "SkillExecutions"(status, createdAt DESC);
CREATE INDEX idx_skillexecutions_duration ON "SkillExecutions"(durationMs DESC);
```

### **WorkflowExecutions**
```sql
-- ✅ Já existentes
CREATE INDEX idx_workflowexecutions_workflow ON "WorkflowExecutions"(workflowId);
CREATE INDEX idx_workflowexecutions_companion ON "WorkflowExecutions"(companionId);
CREATE INDEX idx_workflowexecutions_user ON "WorkflowExecutions"(userId);
CREATE INDEX idx_workflowexecutions_org ON "WorkflowExecutions"(organizationId);
CREATE INDEX idx_workflowexecutions_status ON "WorkflowExecutions"(status);
CREATE INDEX idx_workflowexecutions_session ON "WorkflowExecutions"(sessionId);
CREATE INDEX idx_workflowexecutions_started ON "WorkflowExecutions"(startedAt DESC);
CREATE INDEX idx_workflowexecutions_status_started ON "WorkflowExecutions"(status, startedAt DESC);

-- ✅ Adicionar
CREATE INDEX idx_workflowexecutions_current_step ON "WorkflowExecutions"(currentStepOrder) 
  WHERE status IN ('running', 'paused');
  
CREATE INDEX idx_workflowexecutions_failed ON "WorkflowExecutions"(errorStep, errorMessage) 
  WHERE status = 'failed';
```

---

## ✅ CONCLUSÃO

### **SkillExecutions - Status: ✅ CORRETO**
- Todas as colunas necessárias já estão implementadas
- JSON usado corretamente para inputData, outputData, metadata
- Índices adequados para queries de performance

### **WorkflowExecutions - Status: ✅ 98% CORRETO**
- Schema muito bem estruturado
- Verificar se campo `executionConfig` existe (deveria estar como JSONB)
- Índices adequados para queries complexas
- AI SDK 5.0 integration completa (aiSdkMessages, aiSdkSteps, aiSdkCallbacks)

---

## 🎯 REGRAS DE DECISÃO - EXECUTIONS

| Critério | Coluna Fixa | JSON |
|----------|-------------|------|
| Status de execução | ✅ | ❌ |
| Timestamps | ✅ | ❌ |
| Foreign Keys | ✅ | ❌ |
| Métricas numéricas | ✅ | ❌ |
| Input/Output variável | ❌ | ✅ |
| Resultados intermediários | ❌ | ✅ |
| Mensagens AI SDK | ❌ | ✅ |
| Configuração complexa | ❌ | ✅ |
| Metadados extensíveis | ❌ | ✅ |

---

**Status Final**: 
- ✅ **SkillExecutions**: 100% correto
- ✅ **WorkflowExecutions**: 98% correto (verificar `executionConfig`)

