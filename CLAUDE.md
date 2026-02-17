# Claude Code Guidelines

## Quick Reference

**Project**: dagshub-ai-dev-plaform-support - Turborepo monorepo with React frontend, FastAPI backend, PostgreSQL database, AI agent, MCP server, LlamaStack, AI chat

**Validation commands** (never run dev servers):
```bash
make lint
make test
pnpm type-check
```

## Architecture

- `packages/` - Monorepo packages (ui, api, db, agent, mcp, llamastack, chat, configs)
- `deploy/helm/` - Kubernetes deployment
- `compose.yml` - Local dev containers
- `Makefile` - Common commands

## Key Patterns

- **Frontend**: React 19 + Vite + TanStack Router/Query + Tailwind
- **Backend**: FastAPI + Pydantic v2 + async/await
- **Database**: SQLAlchemy 2.0 async + Alembic migrations
- **Agent**: LangGraph + configurable LLM providers (library)
- **MCP Server**: FastMCP + FastAPI SSE transport
- **LlamaStack**: LLM model serving (Helm subchart)
- **Chat**: assistant-ui components + LangGraph SDK
- **Commits**: Conventional commits (feat:, fix:, etc.)

## Rules

See `.claude/rules/` for detailed guides on architecture, API, UI, database, and testing.
