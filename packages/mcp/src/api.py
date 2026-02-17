"""FastAPI application with FastMCP integration."""

from fastapi import FastAPI

from .mcp import mcp
from .settings import settings

app = FastAPI(
    title="MCP Server",
    description="Model Context Protocol server with FastMCP",
)


@app.get("/health")
async def health_check() -> dict:
    """Health check endpoint."""
    return {"status": "healthy", "service": "mcp-server"}


# Mount FastMCP SSE endpoint
app.mount("/", mcp.http_app(transport=settings.MCP_TRANSPORT_PROTOCOL))
