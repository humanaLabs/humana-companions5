# 🏗️ DIAGRAMA DE ARQUITETURA - HUMANA AI COMPANIONS

**Documento**: Diagrama de arquitetura do sistema Humana AI Companions  
**Versão**: 1.0  
**Data**: 2025-01-15  
**Fonte**: Rabisco Edu

---

## 📊 DIAGRAMA MERMAID

```mermaid
graph TB
    %% Linha Superior
    ORGS[ORGS]
    WORKSPACES[WORKSPACES]
    USERS[USERS]
    
    %% Coluna Esquerda
    COMPS[COMPS]
    SKILLS[SKILLS]
    STEPS[STEPS]
    
    %% Centro
    KNOWLEDGE_RAG["KNOWLEDGE_RAG<br/>..."]
    TOOLS_MCP["TOOLS_MCP<br/>..."]
    
    %% Coluna Direita
    CHATS[CHATS]
    ARTIFACTS[ARTIFACTS]
    PERM_ACL["PERM_ACL<br/>..."]
    
    %% Conexões Linha Superior
    ORGS <--> WORKSPACES
    WORKSPACES --> USERS
    
    %% Conexões Coluna Esquerda (vertical)
    ORGS --> COMPS
    COMPS --> SKILLS
    SKILLS --> STEPS
    
    %% Conexões para Centro (Knowledge e Tools)
    ORGS -.-> KNOWLEDGE_RAG
    COMPS -.-> KNOWLEDGE_RAG
    KNOWLEDGE_RAG -.-> CHATS
    
    ORGS -.-> TOOLS_MCP
    SKILLS -.-> TOOLS_MCP
    
    %% Conexões Coluna Direita
    USERS --> CHATS
    CHATS --> ARTIFACTS
    
    %% Conexões PERM_ACL
    PERM_ACL -.-> USERS
    PERM_ACL -.-> CHATS
    PERM_ACL -.-> ARTIFACTS
    
    %% Estilos
    style KNOWLEDGE_RAG fill:#fff,stroke:#333,stroke-width:2px
    style TOOLS_MCP fill:#fff,stroke:#333,stroke-width:2px
    style PERM_ACL fill:#f0f0f0,stroke:#333,stroke-width:2px
    
    classDef default fill:#fff,stroke:#333,stroke-width:2px
```

**ENUMs**: Roles, Resources, Actions, Class, Restricts

**Nota**: ENUMs: Roles, Resources, Actions, Class, Restricts

---

## 🎨 RELACIONAMENTOS

### **Hierarquia Principal:**
- **ORGS** → WORKSPACES (1:N)
- **WORKSPACES** → USERS (N:N)
- **ORGS** → COMPS (1:N)
- **COMPS** → SKILLS (1:N)
- **SKILLS** → STEPS (1:N)

### **Funcionalidades:**
- **USERS** → CHATS (1:N)
- **CHATS** → ARTIFACTS (1:N)

### **Sistemas Transversais:**
- **KNOWLEDGE_RAG** → COMPS, CHATS (suporte)
- **TOOLS_MCP** → COMPS, SKILLS (execução)
- **PERM_ACL** → USERS, CHATS, ARTIFACTS (segurança)

---

## 📋 LEGENDA

| Símbolo | Significado |
|---------|-------------|
| `→` | Relacionamento direto (FK) |
| `-.->` | Relacionamento de suporte/referência |
| **Rosa** | Sistemas de infraestrutura (RAG, MCP) |
| **Azul** | Sistema de segurança (ACL) |

---

## 🔑 ENUMs DO SISTEMA

Conforme anotação no diagrama:

- **Roles**: Papéis de usuários no sistema
- **Resources**: Tipos de recursos (ORG, WSP, CMP, PRL, CHT, KNW, TOL)
- **Actions**: Ações possíveis (REA, WRI, UPD, MNG)
- **Class**: Classificação de acesso (PUB, ORG, WSP, PVT)
- **Restricts**: Restrições de sensibilidade (PII, FIN, COF)

---

**Documento gerado em**: 2025-01-15  
**Versão**: 1.0  
**Status**: ✅ Aprovado
