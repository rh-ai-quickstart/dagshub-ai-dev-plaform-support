"""MCP Server configuration settings."""

from pydantic_settings import BaseSettings


class MCPSettings(BaseSettings):
    """Settings for the MCP server."""

    MCP_HOST: str = "0.0.0.0"
    MCP_PORT: int = 3001
    MCP_TRANSPORT_PROTOCOL: str = "sse"

    model_config = {
        "env_file": ".env",
        "extra": "ignore",
    }


settings = MCPSettings()
