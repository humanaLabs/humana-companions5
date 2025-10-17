# 🔐 ANÁLISE DETALHADA - TABELA PERMISSIONS_ACL

**Documento**: Análise de estrutura da tabela PERMISSIONS_ACL para refatoração do backend  
**Versão**: 1.0  
**Data**: 2025-01-15  
**Objetivo**: Definir estrutura otimizada para controle de acesso granular (ACL)

---

## 🎯 TABELA PERMISSIONS_ACL - ANÁLISE COMPLETA

### 📋 **COLUNAS HEADER (Diretas) - ESTRUTURA FINAL**

| Campo | Tipo | Constraints | Justificativa Detalhada |
|-------|------|-------------|-------------------------|
| `perm_id` | UUID | PRIMARY KEY | **Identificador único global** - Usado em todas as operações CRUD, relacionamentos, RLS policies e URLs da aplicação. UUID garante unicidade distribuída e segurança. |
| `orgs_id` | UUID | NOT NULL, FK → organizations(orgs_id) | **Multi-tenancy CRÍTICO** - Isolamento por organização. Usado em 90% das queries para filtrar permissões da org. RLS depende desse campo. Essencial para segurança e performance. |
| `perm_entity_code` | ENUM | NOT NULL | **Tipo de entidade** - `ORG`, `WSP`, `CMP`, `PRL`, `CHT`, `KNW`, `TOL`. Usado para filtragem por tipo de entidade e lógica de negócio. Essencial para RLS e organização. |
| `perm_entity_pk_id` | UUID | NOT NULL | **ID da entidade** - Identificador da entidade específica. Usado para permissões granulares e relacionamento com entidades. Essencial para funcionalidade core. |
| `perm_action` | ENUM | NOT NULL | **Ação permitida** - `REA`, `WRI`, `UPD`, `CRU`, `MNG`. Usado para controle de ações específicas e validação de permissões. Essencial para segurança. |
| `perm_created_by_user_id` | UUID | NOT NULL, FK → users(user_id) | **Quem concedeu** - Usuário que concedeu a permissão. Essencial para auditoria e rastreabilidade. Usado para controle de delegação. |
| `perm_created_for_user_id` | UUID | NOT NULL, FK → users(user_id) | **Para quem** - Usuário que recebeu a permissão. Usado para consultas de permissões do usuário. Essencial para funcionalidade core. |
| `perm_created_at` | TIMESTAMP | NOT NULL DEFAULT NOW() | **Auditoria temporal** - Data de criação da permissão. Usado para ordenação cronológica, analytics, auditoria e como início da validade da permissão. |
| `perm_valid_to` | TIMESTAMP | NULLABLE | **Fim da validade** - Data de fim da validade da permissão. Usado para permissões temporárias e controle de acesso. NULL indica permissão permanente. |
| `perm_revoked_at` | TIMESTAMP | NULLABLE | **Data de revogação** - Data em que a permissão foi revogada. Usado para auditoria e controle de acesso. Quando NULL, permissão está ativa. |

### 🔧 **ENUMs**
```sql
-- Prefixo: perm_ (consistente com nomenclatura v2.0)
CREATE TYPE perm_entity_code_enum AS ENUM ('ORG', 'WSP', 'CMP', 'PRL', 'CHT', 'KNW', 'TOL');
CREATE TYPE perm_action_enum AS ENUM ('REA', 'WRI', 'UPD', 'CRU', 'MNG');
```

**Ações:**
- `REA` = Read (Leitura)
- `WRI` = Write (Escrita/Criação)
- `UPD` = Update (Atualização)
- `CRU` = CRUD (Create, Read, Update, Delete - Acesso completo aos dados)
- `MNG` = Manage (Gerenciamento/Administração)

### 📦 **ATRIBUTOS JSONB - ESTRUTURA DETALHADA**

#### **1. perm_details** - Detalhes da Permissão
```json
{
  "perm_type": "explicit",      // explicit, inherited, delegated
  "inherited_from": null,             // ID da permissão pai (se herdada)
  "delegated_from": "uuid-user-admin", // Usuário que delegou (se delegada)
  "delegation_chain": [               // Cadeia de delegação
    "uuid-user-super-admin",
    "uuid-user-admin",
    "uuid-user-manager"
  ],
  "perm_level": "full",         // full, limited, read_only
  "granted_reason": "Membro do time de vendas", // Motivo da concessão
  "business_justification": "Acesso necessário para relatórios de vendas", // Justificativa de negócio
  "approval_required": false,         // Se requer aprovação
  "approval_status": "approved",      // Status da aprovação
  "approval_notes": "Aprovado pelo gerente de vendas" // Notas da aprovação
}
```
**Justificativa**: Detalhes específicos da permissão. Estrutura complexa que evolui com funcionalidades de delegação e aprovação.

#### **2. access_scope** - Escopo de Acesso
```json
{
  "scope_type": "resource_specific",  // resource_specific, resource_type, global
  "resource_filters": {               // Filtros de recurso
    "workspace_id": "uuid-workspace-1",
    "department": "sales",
    "project_id": "uuid-project-1"
  },
  "field_restrictions": [             // Restrições de campos
    "name",
    "email",
    "phone"
  ],
  "operation_restrictions": [         // Restrições de operações
    "read",
    "list"
  ],
  "data_filters": {                   // Filtros de dados
    "date_range": {
      "start": "2025-01-01",
      "end": "2025-12-31"
    },
    "status": ["active", "pending"]
  },
  "conditional_access": {             // Acesso condicional
    "conditions": [
      {
        "field": "department",
        "operator": "equals",
        "value": "sales"
      }
    ],
    "logic": "AND"
  }
}
```
**Justificativa**: Escopo específico de acesso. Estrutura complexa que permite permissões granulares e condicionais.

#### **3. temporal_constraints** - Restrições Temporais
```json
{
  "time_restrictions": {              // Restrições de horário
    "enabled": true,
    "days_of_week": [1, 2, 3, 4, 5], // Seg-Sex
    "hours": "09:00-18:00",
    "timezone": "America/Sao_Paulo"
  },
  "date_restrictions": {              // Restrições de data
    "enabled": false,
    "start_date": "2025-01-01",
    "end_date": "2025-12-31",
    "recurring": false
  },
  "session_restrictions": {           // Restrições de sessão
    "max_session_duration_hours": 8,
    "max_concurrent_sessions": 3,
    "session_timeout_minutes": 480
  },
  "usage_limits": {                   // Limites de uso
    "max_requests_per_day": 1000,
    "max_requests_per_hour": 100,
    "max_data_access_mb": 1000
  }
}
```
**Justificativa**: Restrições temporais e de uso. Essenciais para controle de acesso granular e podem evoluir com políticas.

#### **4. location_constraints** - Restrições de Localização
```json
{
  "ip_restrictions": {                // Restrições de IP
    "enabled": true,
    "allowed_ips": [                  // IPs permitidos
      "192.168.1.0/24",
      "10.0.0.0/8"
    ],
    "blocked_ips": [                  // IPs bloqueados
      "192.168.100.0/24"
    ],
    "country_restrictions": {         // Restrições de país
      "enabled": true,
      "allowed_countries": ["BR", "US"],
      "blocked_countries": []
    }
  },
  "network_restrictions": {           // Restrições de rede
    "allowed_networks": ["corporate", "vpn"],
    "blocked_networks": ["public_wifi"],
    "require_vpn": true
  },
  "device_restrictions": {            // Restrições de dispositivo
    "allowed_device_types": ["laptop", "desktop"],
    "blocked_device_types": ["mobile", "tablet"],
    "require_device_approval": true
  }
}
```
**Justificativa**: Restrições de localização e dispositivo. Essenciais para segurança e podem evoluir com políticas de BYOD.

#### **5. audit_trail** - Trilha de Auditoria
```json
{
  "access_log": [                     // Log de acessos
    {
      "timestamp": "2025-01-15T10:30:00Z",
      "action": "read",
      "entity_pk_id": "uuid-entity-1",
      "ip_address": "192.168.1.100",
      "user_agent": "Mozilla/5.0...",
      "success": true,
      "details": "Acesso autorizado"
    }
  ],
  "perm_changes": [             // Mudanças na permissão
    {
      "timestamp": "2025-01-15T09:00:00Z",
      "action": "granted",
      "changed_by": "uuid-user-admin",
      "reason": "Nova responsabilidade",
      "old_permission": null,
      "new_permission": "read"
    }
  ],
  "violations": [                     // Violações de acesso
    {
      "timestamp": "2025-01-15T11:00:00Z",
      "violation_type": "unauthorized_access",
      "details": "Tentativa de acesso a recurso não autorizado",
      "severity": "medium",
      "resolved": false
    }
  ],
  "compliance_checks": [              // Verificações de compliance
    {
      "timestamp": "2025-01-15T12:00:00Z",
      "check_type": "perm_review",
      "result": "passed",
      "details": "Todas as permissões estão em conformidade"
    }
  ]
}
```
**Justificativa**: Trilha completa de auditoria. Essencial para compliance e segurança, estrutura complexa que evolui com regulamentações.

#### **6. notification_settings** - Configurações de Notificação
```json
{
  "notifications_enabled": true,      // Notificações habilitadas
  "notification_types": [             // Tipos de notificação
    "perm_granted",
    "perm_revoked",
    "access_denied",
    "perm_expiring"
  ],
  "notification_channels": [          // Canais de notificação
    {
      "type": "email",
      "address": "user@empresa.com",
      "enabled": true
    },
    {
      "type": "slack",
      "channel": "#security-alerts",
      "enabled": true
    }
  ],
  "notification_frequency": "immediate", // Frequência das notificações
  "escalation_rules": [               // Regras de escalação
    {
      "condition": "access_denied_count > 5",
      "escalate_to": "uuid-user-admin",
      "time_window_hours": 1
    }
  ]
}
```
**Justificativa**: Configurações de notificação para segurança. Podem variar por usuário e evoluir com sistemas de notificação.

#### **7. compliance_requirements** - Requisitos de Compliance
```json
{
  "compliance_standards": [           // Padrões de compliance
    "GDPR",
    "LGPD",
    "SOX",
    "HIPAA"
  ],
  "data_protection": {                // Proteção de dados
    "data_classification": "internal",
    "encryption_required": true,
    "anonymization_required": false,
    "retention_policy": "7_years"
  },
  "access_governance": {              // Governança de acesso
    "review_frequency": "quarterly",
    "approval_workflow": "manager_approval",
    "segregation_of_duties": true,
    "least_privilege": true
  },
  "regulatory_requirements": {        // Requisitos regulatórios
    "audit_trail_required": true,
    "immutable_logs": true,
    "data_residency": "BR",
    "cross_border_transfer": false
  }
}
```
**Justificativa**: Requisitos de compliance específicos. Podem variar por organização e evoluir com regulamentações.

#### **8. risk_assessment** - Avaliação de Risco
```json
{
  "risk_level": "medium",             // Nível de risco
  "risk_factors": [                   // Fatores de risco
    "high_privilege_access",
    "external_user",
    "sensitive_data"
  ],
  "risk_score": 6.5,                  // Score de risco (0-10)
  "mitigation_measures": [            // Medidas de mitigação
    "multi_factor_authentication",
    "time_restricted_access",
    "enhanced_monitoring"
  ],
  "risk_review_date": "2025-04-15",   // Data da próxima revisão
  "risk_owner": "uuid-user-risk-manager", // Responsável pelo risco
  "risk_acceptance": {                // Aceitação de risco
    "accepted": true,
    "accepted_by": "uuid-user-ciso",
    "accepted_date": "2025-01-15T10:00:00Z",
    "justification": "Risco aceito com medidas de mitigação"
  }
}
```
**Justificativa**: Avaliação de risco para permissões. Essencial para governança de segurança e pode evoluir com metodologias.

#### **9. integration_metadata** - Metadados de Integração
```json
{
  "source_systems": [                 // Sistemas de origem
    {
      "system": "active_directory",
      "sync_enabled": true,
      "last_sync": "2025-01-15T10:00:00Z",
      "sync_frequency": "hourly"
    }
  ],
  "external_integrations": [          // Integrações externas
    {
      "provider": "okta",
      "integration_type": "sso",
      "enabled": true,
      "configuration": {
        "saml_enabled": true,
        "mfa_required": true
      }
    }
  ],
  "api_endpoints": [                  // Endpoints da API
    {
      "name": "check_permission",
      "method": "POST",
      "path": "/api/permissions/check",
      "description": "Verifica permissão do usuário"
    }
  ],
  "webhook_endpoints": [              // Endpoints de webhook
    {
      "url": "https://api.empresa.com/webhooks/permissions",
      "events": ["perm_granted", "perm_revoked"],
      "secret": "webhook-secret",
      "enabled": true
    }
  ]
}
```
**Justificativa**: Metadados de integração com sistemas externos. Específicos por implementação e podem variar.

#### **10. performance_metrics** - Métricas de Performance
```json
{
  "perm_check_latency_ms": 15,  // Latência de verificação
  "cache_hit_rate": 0.95,             // Taxa de hit do cache
  "query_performance": {              // Performance de consultas
    "avg_query_time_ms": 25,
    "slow_queries_count": 2,
    "optimization_suggestions": [
      "Adicionar índice em resource_kind, resource_id"
    ]
  },
  "usage_statistics": {               // Estatísticas de uso
    "total_checks_per_day": 10000,
    "peak_checks_per_hour": 1000,
    "unique_users_per_day": 150
  },
  "error_rates": {                    // Taxas de erro
    "perm_check_errors": 0.01,
    "timeout_errors": 0.005,
    "cache_errors": 0.001
  }
}
```
**Justificativa**: Métricas de performance para otimização. Essenciais para operações e podem evoluir com monitoramento.

#### **11. security_controls** - Controles de Segurança
```json
{
  "authentication_required": true,    // Autenticação obrigatória
  "multi_factor_required": true,      // MFA obrigatório
  "session_validation": {             // Validação de sessão
    "enabled": true,
    "validation_frequency_minutes": 15,
    "invalidate_on_suspicion": true
  },
  "encryption_requirements": {        // Requisitos de criptografia
    "data_at_rest": true,
    "data_in_transit": true,
    "encryption_algorithm": "AES-256"
  },
  "monitoring_controls": {            // Controles de monitoramento
    "real_time_monitoring": true,
    "anomaly_detection": true,
    "threat_detection": true
  },
  "incident_response": {              // Resposta a incidentes
    "auto_revoke_on_breach": true,
    "notification_immediate": true,
    "escalation_procedures": [
      "notify_security_team",
      "revoke_all_permissions",
      "initiate_investigation"
    ]
  }
}
```
**Justificativa**: Controles de segurança específicos. Essenciais para proteção e podem evoluir com ameaças.

#### **12. lifecycle_management** - Gerenciamento de Ciclo de Vida
```json
{
  "lifecycle_stage": "active",        // Estágio do ciclo de vida
  "auto_renewal": false,              // Renovação automática
  "renewal_frequency": "annually",    // Frequência de renovação
  "expiration_warnings": [            // Avisos de expiração
    {
      "days_before": 30,
      "notification_sent": true,
      "sent_at": "2025-01-15T10:00:00Z"
    }
  ],
  "deprovisioning": {                 // Desprovisionamento
    "auto_deprovision": false,
    "deprovision_after_days": 90,
    "deprovision_reason": "inactive_user"
  },
  "archival": {                       // Arquivamento
    "archive_after_days": 2555,       // 7 anos
    "archive_location": "cold_storage",
    "retention_policy": "permanent"
  }
}
```
**Justificativa**: Gerenciamento de ciclo de vida das permissões. Essencial para governança e pode evoluir com políticas.

### 📊 **ÍNDICES RECOMENDADOS**

```sql
-- Índices principais
CREATE INDEX idx_permissions_org ON permissions_acl(orgs_id);
CREATE INDEX idx_permissions_entity ON permissions_acl(perm_entity_code, perm_entity_pk_id);
CREATE INDEX idx_permissions_user ON permissions_acl(perm_created_for_user_id);
CREATE INDEX idx_permissions_action ON permissions_acl(perm_action);
CREATE INDEX idx_permissions_active_valid ON permissions_acl(perm_created_at, perm_valid_to, perm_revoked_at) 
  WHERE perm_revoked_at IS NULL;
CREATE INDEX idx_permissions_validity ON permissions_acl(perm_created_at, perm_valid_to);

-- Índices para auditoria
CREATE INDEX idx_permissions_created_by ON permissions_acl(perm_created_by_user_id);
CREATE INDEX idx_permissions_created_at ON permissions_acl(perm_created_at DESC);
CREATE INDEX idx_permissions_revoked_at ON permissions_acl(perm_revoked_at) WHERE perm_revoked_at IS NOT NULL;

-- Índices compostos para consultas frequentes (multi-tenancy + permissões)
CREATE INDEX idx_permissions_org_user ON permissions_acl(orgs_id, perm_created_for_user_id);
CREATE INDEX idx_permissions_org_entity ON permissions_acl(orgs_id, perm_entity_code, perm_entity_pk_id);
CREATE INDEX idx_permissions_user_entity ON permissions_acl(perm_created_for_user_id, perm_entity_code, perm_entity_pk_id);
CREATE INDEX idx_permissions_user_action ON permissions_acl(perm_created_for_user_id, perm_action);
CREATE INDEX idx_permissions_entity_action ON permissions_acl(perm_entity_code, perm_entity_pk_id, perm_action);
CREATE INDEX idx_permissions_org_active ON permissions_acl(orgs_id, perm_revoked_at, perm_created_at, perm_valid_to);

-- Índices JSONB para consultas específicas
CREATE INDEX idx_permissions_type ON permissions_acl USING GIN ((attributes->'perm_details'->>'perm_type'));
CREATE INDEX idx_permissions_level ON permissions_acl USING GIN ((attributes->'perm_details'->>'perm_level'));
CREATE INDEX idx_permissions_scope ON permissions_acl USING GIN ((attributes->'access_scope'->>'scope_type'));
CREATE INDEX idx_permissions_compliance ON permissions_acl USING GIN ((attributes->'compliance_requirements'->'compliance_standards'));
CREATE INDEX idx_permissions_risk ON permissions_acl USING GIN ((attributes->'risk_assessment'->>'risk_level'));
CREATE INDEX idx_permissions_lifecycle ON permissions_acl USING GIN ((attributes->'lifecycle_management'->>'lifecycle_stage'));

-- Índice para busca full-text no motivo
CREATE INDEX idx_permissions_reason_fts ON permissions_acl USING GIN (to_tsvector('portuguese', attributes->'perm_details'->>'granted_reason'));
```

---

## 🎯 **RESUMO EXECUTIVO - TABELA PERMISSIONS_ACL**

### **COLUNAS HEADER (10 campos):**
- **Identificadores**: `perm_id`, `orgs_id`, `perm_entity_code`, `perm_entity_pk_id`, `perm_action`
- **Usuários**: `perm_created_by_user_id`, `perm_created_for_user_id`
- **Temporais**: `perm_created_at`, `perm_valid_to`, `perm_revoked_at`

### **ATRIBUTOS JSONB (12 seções):**
- Detalhes da permissão, escopo de acesso, restrições temporais, restrições de localização, auditoria, notificações, compliance, avaliação de risco, integração, performance, controles de segurança, gerenciamento de ciclo de vida

### **BENEFÍCIOS DESTA ESTRUTURA**

1. **Performance**: Colunas diretas para consultas frequentes e RLS
2. **Flexibilidade**: JSONB para evolução sem migrações
3. **Escalabilidade**: Índices otimizados para crescimento
4. **Funcionalidades Avançadas**: Suporte completo a ACL granular
5. **Segurança**: Controles de segurança e compliance robustos

### **CASOS DE USO PRINCIPAIS**

1. **Controle de Acesso Granular**: Permissões específicas por recurso e ação
2. **Compliance**: Auditoria e conformidade regulatória
3. **Segurança**: Controles de segurança e monitoramento
4. **Governança**: Gerenciamento de ciclo de vida das permissões
5. **Integração**: Integração com sistemas externos de identidade

---

**Documento gerado em**: 2025-01-15  
**Versão**: 1.0  
**Status**: ✅ Pronto para implementação
