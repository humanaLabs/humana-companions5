# 🔄 Chat Version Management

Este projeto suporta **5 versões isoladas de chat** (v1, v2, v3, v4, v5) que podem ser executadas simultaneamente.

## 📋 Estrutura

Cada versão possui:
- ✅ **Rota isolada**: `/`, `/v2`, `/v3`, `/v4`, `/v5`
- ✅ **APIs isoladas**: `/api/v1/*`, `/api/v2/*`, `/api/v3/*`, `/api/v4/*`, `/api/v5/*`
- ✅ **Componentes isolados**: `components/v1/`, `components/v2/`, `components/v3/`, `components/v4/`, `components/v5/`
- ✅ **Configurações isoladas**: `lib/ai/v1/`, `lib/ai/v2/`, `lib/ai/v3/`, `lib/ai/v4/`, `lib/ai/v5/`

## 🎯 Configuração da Versão Padrão

### Variável de Ambiente

Defina qual versão será a padrão do sistema usando a variável de ambiente:

```env
# .env.local
HUMANA_DEFAULT_CHAT_VERSION=v1
```

**Valores suportados:** `v1`, `v2`, `v3`, `v4`, `v5`

**Padrão:** Se não configurado, usa `v1`

### Como Funciona

1. **Sem versão na URL** (`/`): Usa a versão definida em `HUMANA_DEFAULT_CHAT_VERSION`
2. **Com versão na URL** (`/v2`, `/v3`, etc.): URL tem prioridade sobre a variável de ambiente

## 🚀 Casos de Uso

### 1. Produção Estável
```env
# Todos os usuários veem V1 por padrão
HUMANA_DEFAULT_CHAT_VERSION=v1
```

### 2. Testando Nova Versão
```env
# Todos os usuários veem V2 por padrão para testes
HUMANA_DEFAULT_CHAT_VERSION=v2
```

### 3. Rollback Rápido
Se V3 tem problemas, simplesmente mude:
```env
# Volta para V2 sem deploy
HUMANA_DEFAULT_CHAT_VERSION=v2
```

### 4. Testes A/B
- Grupo A: Acessa `/` (usa `HUMANA_DEFAULT_CHAT_VERSION`)
- Grupo B: Acessa `/v3` (override manual)

## 🔧 Uso no Desenvolvimento

### Testar Versão Específica

1. **Via Environment Variable:**
   ```bash
   # .env.local
   HUMANA_DEFAULT_CHAT_VERSION=v4
   
   # Reinicie o servidor
   pnpm dev
   ```

2. **Via URL (override):**
   - V1: `http://localhost:3000/`
   - V2: `http://localhost:3000/v2`
   - V3: `http://localhost:3000/v3`
   - V4: `http://localhost:3000/v4`
   - V5: `http://localhost:3000/v5`

### Navegação Entre Versões

A navegação **mantém a versão correta**:
- Enviar mensagem em `/v4` → redireciona para `/v4/chat/:id`
- Clicar em "New Chat" em `/v3` → vai para `/v3/`
- Deletar chat em `/v2` → volta para `/v2/`

## 📊 Exemplo de Deploy

### Vercel

```bash
# No dashboard da Vercel, adicione a variável de ambiente:
HUMANA_DEFAULT_CHAT_VERSION=v2

# Deploy automático usará V2 como padrão
```

### Docker

```dockerfile
# Dockerfile
ENV HUMANA_DEFAULT_CHAT_VERSION=v3
```

### Kubernetes

```yaml
# deployment.yaml
env:
  - name: HUMANA_DEFAULT_CHAT_VERSION
    value: "v4"
```

## 🛡️ Validação

O sistema valida automaticamente a versão:
- Se `HUMANA_DEFAULT_CHAT_VERSION` for inválida → usa `v1`
- Se a URL tiver versão inválida (`/v99`) → usa a versão padrão

## 📝 Notas Importantes

1. **Client-Side Only**: A variável `NEXT_PUBLIC_*` é exposta no client-side
2. **Rebuild Necessário**: Mudanças na variável requerem rebuild do app
3. **Hot Reload**: Durante desenvolvimento, reinicie o servidor após mudar `.env.local`

## 🎨 Customização

Para adicionar uma nova versão (ex: v6):

1. Copie a estrutura de uma versão existente
2. Atualize `middleware.ts` para incluir `/v6`
3. Atualize `hooks/use-api-version.ts` para detectar `/v6`
4. Adicione `"v6"` à lista de versões válidas em `lib/constants.ts`

---

**🚀 Pronto! Agora você pode controlar qual versão do chat é usada via variável de ambiente!**

