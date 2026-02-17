# AI Agent Package

## Overview

The agent package (`packages/agent/`) is a **Python library** that provides a LangGraph-based AI agent with configurable LLM providers. It is imported by the API package and its routes are registered under `/agent`.

## Architecture

```
packages/agent/
├── src/
│   ├── __init__.py
│   ├── schema.py           # Pydantic request/response models
│   ├── settings.py         # AgentSettings (LLM provider config)
│   ├── core/
│   │   ├── agent.py        # get_agent() context manager
│   │   ├── manager.py      # Streaming + SSE event formatting
│   │   ├── providers.py    # LLM provider factory (google/openai/anthropic/llamastack)
│   │   ├── prompt.py       # Default system prompt
│   │   └── storage.py      # Checkpoint saver (memory or PostgreSQL)
│   └── routes/
│       ├── router.py       # create_agent_router() factory
│       ├── health.py       # GET /agent/health
│       ├── stream.py       # POST /agent/stream (SSE)
│       ├── threads.py      # GET/DELETE /agent/threads
│       └── history.py      # GET /agent/history/{thread_id}
└── tests/
```

## Key Patterns

### Library Pattern
The agent is a library, not a standalone server. The API imports it:

```python
# In packages/api/src/main.py
from agent.routes.router import create_agent_router
agent_router = create_agent_router()
app.include_router(agent_router, prefix="/agent")
```

### Provider Factory
`core/providers.py` uses a match statement to create the right LLM:

```python
def get_chat_model(settings) -> BaseChatModel:
    match settings.LLM_PROVIDER:
        case "google": ...
        case "openai": ...
        case "anthropic": ...
```

### Configuration
Settings are in `settings.py` using `pydantic-settings`:
- `LLM_PROVIDER`: google, openai, anthropic, llamastack
- `LLM_MODEL`: Model name (e.g., gemini-2.0-flash)
- `LLM_API_KEY`: Provider API key
- `MCP_ENABLED`: Enable MCP tool integration
- `DATABASE_URL`: PostgreSQL for persistent checkpoints

## Development

```bash
# Install agent deps
cd packages/agent && uv sync

# Run tests
pnpm --filter @dagshub-ai-dev-plaform-support/agent test

# Lint
pnpm --filter @dagshub-ai-dev-plaform-support/agent lint
```

## Adding Tools

1. Create tool functions in `src/core/tools.py`
2. Add them to the tools list in `src/core/agent.py`
3. Tools are automatically available to the agent

## Adding a New Provider

1. Add the provider to the match statement in `src/core/providers.py`
2. Add the dependency to `pyproject.toml` optional dependencies
3. Update `src/settings.py` if new config fields are needed
