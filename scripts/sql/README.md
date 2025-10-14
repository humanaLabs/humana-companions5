# SQL Scripts para Criação do Banco de Dados

Este diretório contém scripts SQL para criar todas as tabelas do schema do projeto.

## 📋 Ordem de Execução

Execute os scripts na seguinte ordem para respeitar as dependências de chaves estrangeiras:

```bash
# 1. Configurar o banco de dados (extensões)
psql -d your_database -f 00_setup_database.sql

# 2. Criar tabela User (sem dependências)
psql -d your_database -f 01_create_user_table.sql

# 3. Criar tabela Chat (depende de User)
psql -d your_database -f 02_create_chat_table.sql

# 4. Criar tabelas Message e Message_v2 (dependem de Chat)
psql -d your_database -f 03_create_message_tables.sql

# 5. Criar tabelas Vote e Vote_v2 (dependem de Chat e Message)
psql -d your_database -f 04_create_vote_tables.sql

# 6. Criar tabela Document (depende de User)
psql -d your_database -f 05_create_document_table.sql

# 7. Criar tabela Suggestion (depende de Document e User)
psql -d your_database -f 06_create_suggestion_table.sql

# 8. Criar tabela Stream (depende de Chat)
psql -d your_database -f 07_create_stream_table.sql
```

## 🚀 Executar Todos os Scripts de Uma Vez

Para executar todos os scripts na ordem correta:

```bash
for file in scripts/sql/*.sql; do
  echo "Executando: $file"
  psql -d your_database -f "$file"
done
```

Ou no Windows PowerShell:

```powershell
Get-ChildItem scripts/sql/*.sql | Sort-Object Name | ForEach-Object {
  Write-Host "Executando: $($_.Name)"
  psql -d your_database -f $_.FullName
}
```

## 📊 Estrutura das Tabelas

### Tabelas Principais

1. **User** - Autenticação de usuários
2. **Chat** - Conversas de chat
3. **Message_v2** - Mensagens (formato atual)
4. **Vote_v2** - Votos em mensagens
5. **Document** - Documentos/artifacts criados
6. **Suggestion** - Sugestões de edição de documentos
7. **Stream** - Sessões de streaming

### Tabelas Deprecated (Manter por Compatibilidade)

- **Message** - Formato antigo de mensagens
- **Vote** - Formato antigo de votos

## 🔗 Relacionamentos

```
User
 ├── Chat (1:N)
 │   ├── Message_v2 (1:N)
 │   │   └── Vote_v2 (N:M)
 │   └── Stream (1:N)
 └── Document (1:N)
     └── Suggestion (1:N)
```

## ⚠️ Notas Importantes

1. **Extensão pgcrypto**: Necessária para gerar UUIDs automaticamente
2. **Chaves Estrangeiras**: Todas as FKs têm `ON DELETE CASCADE` para limpeza automática
3. **Índices**: Criados para otimizar consultas comuns
4. **Tabelas Deprecated**: Mantidas para compatibilidade, mas marcadas para remoção futura

## 🗑️ Remover Todas as Tabelas

Se precisar limpar o banco de dados:

```sql
-- CUIDADO: Isso remove TODAS as tabelas!
DROP TABLE IF EXISTS "Stream" CASCADE;
DROP TABLE IF EXISTS "Suggestion" CASCADE;
DROP TABLE IF EXISTS "Document" CASCADE;
DROP TABLE IF EXISTS "Vote_v2" CASCADE;
DROP TABLE IF EXISTS "Vote" CASCADE;
DROP TABLE IF EXISTS "Message_v2" CASCADE;
DROP TABLE IF EXISTS "Message" CASCADE;
DROP TABLE IF EXISTS "Chat" CASCADE;
DROP TABLE IF EXISTS "User" CASCADE;
```

## 📝 Migrações Drizzle

Este projeto usa Drizzle ORM. Os scripts SQL aqui servem como referência e para deployment manual. Para desenvolvimento, use as migrações do Drizzle:

```bash
# Gerar migrações a partir do schema
pnpm drizzle-kit generate

# Aplicar migrações
pnpm drizzle-kit push
```

