# Project Architecture

This is a **Turborepo monorepo** for building AI-powered applications with a React frontend, FastAPI backend, and PostgreSQL database.

## Technology Stack

| Layer | Technology | Purpose |
|-------|------------|---------|
| Build System | Turborepo | Monorepo task orchestration and caching |
| Frontend | React 19 + Vite | Modern UI with fast HMR |
| Routing | TanStack Router | Type-safe file-based routing |
| State | TanStack Query | Server state management and caching |
| Styling | Tailwind CSS + shadcn/ui | Utility-first CSS with accessible components |
| Backend | FastAPI | Async Python API with OpenAPI docs |
| Database | PostgreSQL + SQLAlchemy | Async database with ORM |
| Migrations | Alembic | Database schema versioning |
| Agent | LangGraph + LangChain | AI agent with configurable LLM providers |
| MCP Server | FastMCP + FastAPI | Model Context Protocol tool server |
| LlamaStack | llama-stack subchart | LLM model serving platform |
| Chat UI | assistant-ui | Pre-built AI chat components (shadcn-compatible) |
| Chat Runtime | @assistant-ui/react-langgraph | LangGraph streaming, threads, tool calls |


## Package Structure

```
dagshub-ai-dev-plaform-support/
├── packages/
│   ├── ui/              # React frontend (pnpm)
│   ├── api/             # FastAPI backend (uv/Python)
│   ├── db/              # Database models & migrations (uv/Python)
│   ├── agent/           # LangGraph AI agent (uv/Python)
│   ├── mcp/             # FastMCP server (uv/Python)
│   ├── llamastack/      # LlamaStack deployment (Helm only)
│   ├── chat/            # assistant-ui React components (pnpm)
│   └── configs/         # Shared ESLint, Prettier, Ruff configs
├── deploy/helm/         # Helm charts for OpenShift/Kubernetes
├── compose.yml          # Local development with containers
├── turbo.json           # Turborepo pipeline configuration
└── Makefile             # Common development commands
```

## Package Managers

- **Node.js packages** (ui, chat, configs): Use `pnpm`
- **Python packages** (api, agent, mcp, db): Use `uv` (fast Python package manager)
- **Root commands**: Use `make` or `pnpm` (which delegates to Turbo)

## Key Commands

```bash
# Setup
make setup              # Install all dependencies (Node + Python)

# Development
make dev                # Start all dev servers (UI + API)
make db-start           # Start PostgreSQL container
make db-migrate         # Run database migrations

# Quality
make lint               # Run linters across all packages
make test               # Run tests across all packages
pnpm type-check         # TypeScript type checking

# Containers
make containers-build   # Build all container images
make containers-up      # Start all services via compose
```

## Development URLs

- **Frontend**: http://localhost:3000
- **API**: http://localhost:8000
- **API Docs**: http://localhost:8000/docs (Swagger UI)
- **Database**: postgresql://localhost:5432
- **Agent endpoints**: http://localhost:8000/agent (served by API)
- **MCP Server**: http://localhost:3001
- **LlamaStack**: http://localhost:8321

## Environment Configuration

- `.env` - Local development variables (gitignored)
- `.env.example` - Template for required environment variables
- Secrets in production managed via Helm values and OpenShift secrets
