# 📖 Definições do Sistema

Esta pasta contém as definições gerais, regras de negócio e especificações fundamentais do sistema Humana AI Companions.

## 📋 Arquivos

### Definicoes_banco_de_dados.txt
**Especificações do Banco de Dados**

Contém:
- Estrutura de tabelas
- Relacionamentos
- Índices e otimizações
- Uso de pgvector
- RLS (Row Level Security)
- Sistema de organizações, workspaces e usuários
- Hierarquia de companions, skills e steps
- Sistema de conhecimento e RAG
- Ferramentas MCP
- Permissões ACL
- Exemplos de schemas JSONB

### Definicoes_estrutura_codigo_atual.txt
**Estrutura REAL do Código (Como está hoje)**

Contém:
- Estrutura de pastas atual do projeto
- Componentes existentes em /components/v1/shared (18 componentes)
- Estrutura real de v5 (chat, workers, workflows, skill-engineering)
- Organização atual com v1, v2, v5
- 50+ componentes soltos na raiz de /components
- Pastas experimentais e descontinuadas
- Dependências entre versões (v5 → v1/shared)

### Definicoes_estrutura_codigo.txt
**Estrutura IDEAL do Código (Alvo da migração)**

Contém:
- Estrutura de pastas ideal pós-migração
- v5 → nova v0 (versão única de chat)
- v1 descontinuada e removida
- Chat modular e organizado em /components/chat/
- Backend reconstruído do zero
- Limpeza de componentes obsoletos
- Padrões de código e convenções
- Organização modular (core, ai-elements, headers, skills, multimodal, context, ui, utils)

### COMPARACAO-ATUAL-VS-IDEAL.md
**Análise Comparativa: Estrutura Atual vs Ideal**

Contém:
- Comparação detalhada entre estrutura atual e ideal
- Problemas críticos identificados (dependências v5 → v1/shared)
- Lista completa de componentes a migrar
- Checklist de migração (5 fases)
- Estrutura final de /components/chat/
- Métricas de redução de complexidade
- Roadmap de migração
- Benefícios esperados

## 🎯 Conceitos Principais

### Hierarquia do Sistema
```
Organizações
  └── Workspaces (MyWorkspace + OrgWorkspace)
      ├── Usuários (Profiles)
      │   └── Chats
      │       └── Artefatos
      └── Companions
          └── Skills
              └── Steps
                  └── Executions
```

### Sistema de Roles

#### MasterSys
- Cria organizações
- Dá acesso aos OrgAdmins
- Configura ferramentas MCP

#### OrgAdmin
- Cria workspaces da organização
- Dá acesso aos WspManagers
- Gerencia conhecimento organizacional

#### WspManager
- Cria companions funcionais
- Dá acesso aos usuários
- Gerencia conhecimento do workspace

#### User
- Usa SuperCompanion (pessoal)
- Usa companions funcionais (com permissão)
- Gera e compartilha artefatos

### Sistema de Conhecimento

#### Níveis de Conhecimento
1. **Organização**: Conhecimento corporativo
2. **Workspace**: Conhecimento funcional
3. **Profile (Usuário)**: Conhecimento pessoal
4. **Companion**: Conhecimento específico do agente
5. **Skill**: Conhecimento da sub-tarefa
6. **Step**: Conhecimento da fase

#### AutoRAG
- Indexação automática com pgvector
- Busca semântica (1536 dimensões)
- Classificação por níveis de acesso
- Restrições: PII, FIN, COF

### Fluxo de Permissões

```
GUC (Global User Context)
  ↓
RLS (Row Level Security)
  ↓
ACL (Access Control List)
  ↓
RAG (Retrieval Augmented Generation)
```

### Enums do Sistema

#### ROLES
- `MS`: MasterSys
- `OA`: OrgAdmin
- `WM`: WspManager
- `UR`: User

#### RESOURCES
- `ORG`: Organization
- `WSP`: Workspace
- `CMP`: Companion
- `PRL`: Profile
- `CHT`: Chat
- `KNW`: Knowledge
- `TOL`: Tool

#### ACTIONS
- `REA`: Read
- `WRI`: Write
- `UPD`: Update
- `MNG`: Manage

#### CLASS_INFO
- `PUB`: Público
- `ORG`: Organizacional
- `WSP`: Workspace
- `PVT`: Privado

#### RESTRICTS_STAMPS
- `PII`: Dados Pessoais
- `FIN`: Financeiro
- `COF`: Confidencial

## 🔧 Ferramentas MCP

### Configuração
1. Master configura e dá acesso ao OrgAdmin
2. OrgAdmin gerencia permissões
3. Usuários configuram com Bearer ou OAuth

### Tipos de Integração
- APIs REST
- Bancos de dados
- Drives (Google, Dropbox, SharePoint)
- Webhooks
- FTP/SFTP

## 📄 Artefatos

### Geração
- Markdown + SVG (padrão)
- Exportação para PDF
- Salvamento automático na workspace
- Compartilhamento entre workspaces

### Indexação
- AutoRAG indexa automaticamente
- Busca semântica
- Controle de acesso por workspace

## 🚀 Workspaces

### MyWorkspace (Pessoal)
- Criada automaticamente para cada usuário
- Privada
- SuperCompanion incluído
- Artefatos pessoais

### OrgWorkspace (Funcional)
- Criada para a organização
- Pública dentro da org
- Companions funcionais
- Compartilhamento de artefatos

### Workspaces Customizadas
- Criadas por OrgAdmin
- Para equipes ou projetos
- Companions específicos
- Permissões customizadas

## 📊 Modelagem de Dados

### Estrutura de Tabelas
- Campos chave (id, name)
- JSONB para atributos variáveis
- Enums para listas fixas
- Foreign keys com cascade

### Exemplo de Schema JSONB (Skill)
```json
{
  "name": "criar_perfil_funcionario",
  "goal": "Criar perfil completo de funcionário",
  "data": {
    "organizacao": "Estruturas organizacionais",
    "candidato": "Dados do processo seletivo",
    "sistemas": "Odoo, SAP, Email"
  },
  "steps": [
    "1) Estruture dados organizacionais",
    "2) Aplique códigos e classificações",
    "3) Configure acessos iniciais",
    "4) Valide integrações"
  ],
  "rules": [
    "Seguir estrutura organizacional",
    "Aplicar políticas de acesso",
    "Validar dados",
    "Manter auditoria"
  ],
  "tools": [
    "odoo_create_employee",
    "sap_sync_data",
    "email_send_welcome"
  ],
  "metadata": {
    "schema_name": "atributos_skills",
    "schema_version": "1.0"
  }
}
```

## 🔮 Futuro

- Memória dinâmica
- Flows multi-agentes
- Tabela AuditLog com triggers
- Workflows complexos
- Integrações avançadas
