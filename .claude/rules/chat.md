---
paths:
  - "packages/chat/**/*"
---

# Chat Package Development

## Overview

Dual package: **Fastify SSE proxy backend** + **assistant-ui React components** for AI chat.

## Technology Stack

### Frontend (exported components)
- **assistant-ui** — Pre-built AI chat UI components (Thread, ThreadList, Composer)
- **@assistant-ui/react-langgraph** — LangGraph runtime integration
- **React 19** with TypeScript

### Backend (Fastify server)
- **Fastify 5** — HTTP server with CORS
- **SSE proxy** — Forwards requests to AGENT_HOST (LangGraph agent)
- **@fastify/static** — Serves UI dist in production
- **@fastify/cors** — Cross-origin request handling

## Project Structure

```
packages/chat/
├── src/
│   ├── index.ts              # Public exports (ChatPage, types)
│   ├── components/
│   │   └── ChatPage.tsx      # Main chat page with assistant-ui runtime
│   ├── types/
│   │   └── chat.ts           # ChatConfig, ToolCall interfaces
│   └── server/
│       ├── server.ts         # Fastify setup (port 8081 dev, 8080 container)
│       └── router/
│           ├── api.router.ts        # Proxy /api/v1/* → AGENT_HOST
│           ├── client.router.ts     # Static file serving (prod)
│           └── controllers/v1/
│               └── agent.ts         # Agent communication helpers
├── tsconfig.json             # Component build (declaration emit)
├── tsconfig.server.json      # Server build (Node target)
├── Containerfile             # Multi-stage: build → Node runtime
└── .env.example
```

## assistant-ui Integration

The ChatPage component uses `useLangGraphRuntime` from `@assistant-ui/react-langgraph`:

```typescript
const runtime = useLangGraphRuntime({
  stream: async (messages, { initialize }) => {
    const { externalId } = await initialize();
    return sendMessage(client, { threadId: externalId, messages, assistantId: 'agent' });
  },
  create: async () => createThread(client),
  load: async (externalId) => getThreadState(client, externalId),
});
```

To customize the chat UI, run in the UI package:
```bash
npx assistant-ui add thread thread-list
```

See https://www.assistant-ui.com/docs for component docs.

## Dual Build

- `build:components` — Compiles components with declaration files for workspace consumption
- `build:server` — Compiles Fastify server for container deployment
- The UI package imports components via `@<project>/chat` workspace dependency

## Port Assignments

| Environment | Port |
|------------|------|
| Dev server | 8081 |
| Container  | 8080 |

In dev, the UI's Vite dev server proxies `/api/v1` → `http://localhost:8081`.

## Commands

```bash
# Development
pnpm --filter chat dev           # Start Fastify dev server (port 8081)

# Build
pnpm --filter chat build         # Build components + server
pnpm --filter chat build:server  # Build server only

# Production
pnpm --filter chat start         # Run built server
```
