# Agent Guidelines

## Project Overview

**dagshub-ai-dev-plaform-support** - A Turborepo monorepo with React frontend, FastAPI backend, and PostgreSQL database.

## Tech Stack

- **Build**: Turborepo (monorepo orchestration)
- **Frontend**: React 19, Vite, TanStack Router/Query, Tailwind CSS
- **Backend**: FastAPI, Pydantic v2, uvicorn
- **Database**: PostgreSQL, SQLAlchemy 2.0 (async), Alembic
- **Agent**: LangGraph, LangChain, configurable LLM providers
- **MCP Server**: FastMCP, FastAPI, SSE transport
- **LlamaStack**: LLM model serving platform (Helm subchart)
- **Chat**: assistant-ui components, LangGraph SDK
- **Infrastructure**: Docker Compose, Helm charts

## Architecture

```
dagshub-ai-dev-plaform-support/
├── packages/
│   ├── ui/ (React + Vite)
│   ├── api/ (FastAPI + Python)
│   ├── db/ (PostgreSQL + SQLAlchemy)
│   ├── agent/ (LangGraph + LLM providers)
│   ├── mcp/ (FastMCP server)
│   ├── llamastack/ (LlamaStack deployment)
│   ├── chat/ (assistant-ui components)
│   └── configs/          # Shared ESLint, Prettier, Ruff configs
├── deploy/helm/          # Kubernetes Helm charts
├── compose.yml           # Local development containers
├── turbo.json            # Turborepo configuration
└── Makefile              # Development commands
```

## Commands

**Never run dev servers or production builds.** Assume dev servers are running. Use these for validation:

```bash
make lint           # Run all linters
make test           # Run all tests
pnpm type-check     # TypeScript type checking
make lint:api       # Python linting (ruff + mypy)
make test:api       # Python tests (pytest)
make lint:ui        # TypeScript/React linting
make test:ui        # React tests (Vitest)
```

## Package Managers

- **Node.js packages**: `pnpm`
- **Python packages**: `uv`
- **Root commands**: `make` or `pnpm` (delegates to Turbo)

## Conventions

### Frontend (packages/ui/)
- React Function Components with TypeScript
- TanStack Router for file-based routing
- TanStack Query for server state
- Tailwind CSS + shadcn/ui components

### Backend (packages/api/)
- FastAPI with async/await patterns
- Pydantic v2 for validation
- Type hints on all functions
- Ruff for linting/formatting, mypy for type checking

### Database (packages/db/)
- SQLAlchemy 2.0 async ORM
- Alembic for migrations
- Models in `src/models/`, schemas in `src/schemas/`

### Agent (packages/agent/)
- LangGraph ReAct agent with configurable LLM providers
- Library pattern: imported by API, not a standalone server
- Provider factory: google, openai, anthropic, llamastack
- Optional MCP tool integration and PostgreSQL checkpoints

### MCP Server (packages/mcp/)
- FastMCP server with FastAPI and SSE transport
- Tools are plain Python functions with type hints
- Agent connects via `MCP_SSE_URL` when `MCP_ENABLED=true`

### LlamaStack (packages/llamastack/)
- Deployed via Helm subchart — no Python source code
- Agent connects via `LLAMASTACK_URL` with `LLM_PROVIDER=llamastack`

### Chat (packages/chat/)
- assistant-ui React components exported as workspace package
- `useLangGraphRuntime` for streaming, threads, tool calls

### Git
- Conventional commits (feat:, fix:, refactor:, test:, docs:, chore:)
- Small, focused PRs

## Detailed Rules

See `.claude/rules/` and `.cursor/rules/` for comprehensive guides.
