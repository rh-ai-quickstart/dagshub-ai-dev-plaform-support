# MCP Server Development

## Overview

The MCP (Model Context Protocol) server at `packages/mcp/` provides tools to the AI agent via the MCP protocol. It uses FastMCP with FastAPI for SSE transport.

## Architecture

```
packages/mcp/
├── src/
│   ├── __init__.py
│   ├── main.py          # Uvicorn entry point
│   ├── api.py           # FastAPI app + FastMCP mount + /health
│   ├── mcp.py           # FastMCP server, tool registration
│   ├── settings.py      # Server settings (pydantic-settings)
│   └── tools/
│       ├── __init__.py
│       └── example_tool.py  # Example tool
├── tests/
│   ├── conftest.py
│   ├── test_health.py
│   └── test_settings.py
├── pyproject.toml
├── Containerfile
└── .env.example
```

## Adding New Tools

1. Create a new file in `packages/mcp/src/tools/`:
```python
# packages/mcp/src/tools/my_tool.py
def my_tool(param: str) -> str:
    """Description of what the tool does.

    Args:
        param: Description of the parameter.

    Returns:
        Description of the return value.
    """
    return f"Result: {param}"
```

2. Register it in `packages/mcp/src/mcp.py`:
```python
from .tools.my_tool import my_tool
mcp.add_tool(my_tool)
```

3. Add tests in `packages/mcp/tests/`

## Key Patterns

- Tools are plain Python functions with type hints and docstrings
- FastMCP auto-generates tool schemas from function signatures
- The agent connects via SSE at `http://localhost:3001/sse`
- Health check at `GET /health`

## Commands

```bash
cd packages/mcp
uv run uvicorn src.main:app --host 0.0.0.0 --port 3001 --reload  # Dev server
uv run pytest                                                       # Run tests
uv run ruff check . && uv run ruff format --check .                # Lint
```

## Configuration

Settings via environment variables (see `.env.example`):
- `MCP_HOST` - Server host (default: 0.0.0.0)
- `MCP_PORT` - Server port (default: 3001)
- `MCP_TRANSPORT_PROTOCOL` - Transport protocol (default: sse)

## Integration with Agent

The agent at `packages/agent/` connects to this MCP server when `MCP_ENABLED=true`:
- `MCP_SSE_URL` points to this server's SSE endpoint
- Tools are loaded dynamically via `langchain-mcp-adapters`
- In Kubernetes, the service name is `dagshub-ai-dev-plaform-support-mcp`
