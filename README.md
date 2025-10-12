# Humana AI Companions

<p align="center">
  <img src="public/images/icone_branco-Humana.png" alt="Humana AI" width="120" />
</p>

<p align="center">
  Plataforma de chat inteligente com suporte a múltiplas versões isoladas e artifacts interativos.
</p>

<p align="center">
  <a href="#-features"><strong>Features</strong></a> ·
  <a href="#-versões-de-chat"><strong>Versões</strong></a> ·
  <a href="#-começando"><strong>Começando</strong></a> ·
  <a href="#-configuração"><strong>Configuração</strong></a> ·
  <a href="#-deploy"><strong>Deploy</strong></a>
</p>

---

## ✨ Features

### 🎯 Sistema Multi-Versão
- **5 versões isoladas** de chat (v1, v2, v3, v4, v5)
- Cada versão com suas próprias APIs, componentes e configurações
- Controle de versão padrão via variável de ambiente
- Navegação mantém contexto da versão atual
- Rollback instantâneo entre versões

### 💬 Chat Inteligente
- Integração com **xAI Grok** (Vision e Mini) **via Vercel AI Gateway**
- Suporte a múltiplos modelos de IA através de interface unificada
- Autenticação automática via OIDC em deploys Vercel
- Histórico de conversas por usuário
- Sistema de votação (upvote/downvote)
- Modo reasoning para respostas complexas

### 🎨 Artifacts Interativos
- **Editor de Texto**: Criação e edição de documentos
- **Editor de Código**: Python com execução de snippets
- **Planilhas**: Editor de spreadsheets (CSV)
- **Gerador de Imagens**: Integração com Replicate
- Versionamento de artifacts
- Preview em tempo real

### 🎛️ Interface Customizada
- **Design Humana**: Logo e identidade visual personalizada
- **Sidebar Semi-Retrátil**: Modo ícone e modo expandido
- **Tema Adaptativo**: Dark/Light mode
- **Responsivo**: Mobile-first design
- **Acessibilidade**: WCAG 2.1 compliant

### 🔐 Autenticação
- **Auth.js** para gerenciamento de sessões
- Modo Guest para acesso rápido
- Persistência de dados por usuário
- Controle de visibilidade (público/privado)

### 📦 Tecnologias

**Frontend:**
- [Next.js 15](https://nextjs.org) (App Router, Turbopack)
- [React 19](https://react.dev) (Server Components)
- [Tailwind CSS](https://tailwindcss.com) + [shadcn/ui](https://ui.shadcn.com)
- [Framer Motion](https://www.framer.com/motion/) para animações

**Backend:**
- [AI SDK](https://ai-sdk.dev) da Vercel
- [Neon Postgres](https://neon.tech) para dados
- [Vercel Blob](https://vercel.com/storage/blob) para arquivos
- [Drizzle ORM](https://orm.drizzle.team)

**Qualidade:**
- [TypeScript](https://www.typescriptlang.org) strict mode
- [Biome](https://biomejs.dev) para linting e formatting
- [Playwright](https://playwright.dev) para testes E2E

---

## 🔄 Versões de Chat

O sistema suporta **5 versões isoladas** que podem ser executadas simultaneamente:

| Versão | URL | API | Componentes | Configuração |
|--------|-----|-----|-------------|--------------|
| **V1** | `/` | `/api/v1/*` | `components/v1/` | `lib/ai/v1/` |
| **V2** | `/v2` | `/api/v2/*` | `components/v2/` | `lib/ai/v2/` |
| **V3** | `/v3` | `/api/v3/*` | `components/v3/` | `lib/ai/v3/` |
| **V4** | `/v4` | `/api/v4/*` | `components/v4/` | `lib/ai/v4/` |
| **V5** | `/v5` | `/api/v5/*` | `components/v5/` | `lib/ai/v5/` |

### Controle de Versão Padrão

Configure qual versão será a padrão via variável de ambiente:

```env
# .env.local
HUMANA_DEFAULT_CHAT_VERSION=v1
```

- **Valores suportados:** `v1`, `v2`, `v3`, `v4`, `v5`
- **Default:** `v1` se não configurado
- **Override manual:** Usuários podem acessar qualquer versão via URL (`/v2`, `/v3`, etc.)

**Casos de uso:**
- 🚀 **Produção**: `HUMANA_DEFAULT_CHAT_VERSION=v1`
- 🧪 **Testes A/B**: `HUMANA_DEFAULT_CHAT_VERSION=v2`
- ⏮️ **Rollback rápido**: Mude a variável e rebuild

---

## 🚀 Começando

### Pré-requisitos

- Node.js 18+ e pnpm
- Postgres Database (recomendado: [Neon](https://neon.tech))
- Conta Vercel (para AI Gateway)

### Instalação

1. **Clone o repositório:**
```bash
git clone https://github.com/humanaLabs/humana-companions5.git
cd humana-companions5
```

2. **Instale as dependências:**
```bash
pnpm install
```

3. **Configure as variáveis de ambiente:**

Crie um arquivo `.env.local` na raiz do projeto:

```env
# Database (Neon Postgres)
DATABASE_URL="postgresql://user:password@host/database"

# Auth.js
AUTH_SECRET="your-secret-key-here"  # Gere com: openssl rand -base64 32

# AI Gateway (opcional para deploys não-Vercel)
AI_GATEWAY_API_KEY="your-gateway-key"

# Versão padrão do chat
HUMANA_DEFAULT_CHAT_VERSION=v1

# Blob Storage (Vercel)
BLOB_READ_WRITE_TOKEN="your-blob-token"
```

4. **Execute as migrações do banco:**
```bash
pnpm db:migrate
```

5. **Inicie o servidor de desenvolvimento:**
```bash
pnpm dev
```

6. **Acesse a aplicação:**
```
http://localhost:3000
```

---

## ⚙️ Configuração

### Modelos de IA

Edite `lib/ai/v1/providers.ts` para configurar os modelos:

```typescript
export const myProvider = customProvider({
  languageModels: {
    "chat-model": gateway.languageModel("xai/grok-2-vision-1212"),
    "chat-model-reasoning": wrapLanguageModel({
      model: gateway.languageModel("xai/grok-3-mini"),
      middleware: extractReasoningMiddleware({ tagName: "think" }),
    }),
    "title-model": gateway.languageModel("xai/grok-2-1212"),
    "artifact-model": gateway.languageModel("xai/grok-2-1212"),
  },
});
```

### Autenticação

Configure provedores OAuth em `app/(auth)/auth.config.ts`:

```typescript
providers: [
  GitHub({
    clientId: process.env.AUTH_GITHUB_ID,
    clientSecret: process.env.AUTH_GITHUB_SECRET,
  }),
  // Adicione mais provedores aqui
]
```

### Artifacts

Para adicionar novos tipos de artifacts, crie em `artifacts/`:

```
artifacts/
├── your-artifact/
│   ├── client.tsx    # Componente React do artifact
│   └── server.ts     # Lógica de criação/atualização
```

---

## 🚢 Deploy

### Vercel (Recomendado)

1. **Push para GitHub:**
```bash
git push origin main
```

2. **Importe no Vercel:**
   - Acesse [vercel.com](https://vercel.com)
   - Conecte seu repositório
   - Configure as variáveis de ambiente
   - Deploy automático!

3. **Configure as variáveis de ambiente no Vercel:**
   - `DATABASE_URL`
   - `AUTH_SECRET`
   - `HUMANA_DEFAULT_CHAT_VERSION`
   - `BLOB_READ_WRITE_TOKEN` (auto-criado pela Vercel)

### Docker

```dockerfile
# Dockerfile
FROM node:18-alpine

WORKDIR /app

COPY package.json pnpm-lock.yaml ./
RUN npm install -g pnpm && pnpm install

COPY . .

ENV HUMANA_DEFAULT_CHAT_VERSION=v1

RUN pnpm build

EXPOSE 3000

CMD ["pnpm", "start"]
```

```bash
docker build -t humana-ai .
docker run -p 3000:3000 --env-file .env.local humana-ai
```

---

## 📚 Scripts Disponíveis

```bash
# Desenvolvimento
pnpm dev              # Inicia servidor de desenvolvimento (Turbopack)
pnpm build            # Build de produção
pnpm start            # Inicia servidor de produção

# Database
pnpm db:migrate       # Executa migrações
pnpm db:studio        # Abre Drizzle Studio

# Qualidade
pnpm lint             # Executa Biome linter
pnpm format           # Formata código com Biome
pnpm typecheck        # Verifica tipos TypeScript

# Testes
pnpm test:e2e         # Executa testes E2E (Playwright)
```

---

## 📂 Estrutura do Projeto

```
humana-companions5/
├── app/
│   ├── (auth)/              # Autenticação
│   ├── (chat)/              # Chat V1
│   ├── (chatv2)/            # Chat V2
│   ├── (chatv3)/            # Chat V3
│   ├── (chatv4)/            # Chat V4
│   └── (chatv5)/            # Chat V5
├── artifacts/               # Tipos de artifacts
│   ├── code/
│   ├── image/
│   ├── sheet/
│   └── text/
├── components/              # Componentes compartilhados
│   ├── v1/                  # Componentes específicos V1
│   ├── v2/                  # Componentes específicos V2
│   ├── v3/                  # Componentes específicos V3
│   ├── v4/                  # Componentes específicos V4
│   ├── v5/                  # Componentes específicos V5
│   └── ui/                  # shadcn/ui components
├── lib/
│   ├── ai/                  # Configurações de IA
│   │   ├── v1/              # Config V1
│   │   ├── v2/              # Config V2
│   │   ├── v3/              # Config V3
│   │   ├── v4/              # Config V4
│   │   ├── v5/              # Config V5
│   │   ├── prompts.ts       # Prompts compartilhados
│   │   └── providers.ts     # Providers compartilhados
│   ├── db/                  # Database (Drizzle)
│   └── constants.ts         # Constantes globais
├── hooks/                   # React hooks
├── public/                  # Assets estáticos
└── tests/                   # Testes E2E
```

---

## 🤝 Contribuindo

Contribuições são bem-vindas! Por favor:

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

---

## 📝 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

---

## 🆘 Suporte

- **Documentação**: [Vercel AI SDK Docs](https://ai-sdk.dev)
- **Issues**: [GitHub Issues](https://github.com/humanaLabs/humana-companions5/issues)
- **Contato**: Entre em contato com a equipe Humana Labs

---

<p align="center">
  Feito com ❤️ pela equipe Humana Labs
</p>
