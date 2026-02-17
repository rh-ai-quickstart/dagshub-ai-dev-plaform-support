"""Agent configuration settings."""

from pydantic_settings import BaseSettings


class AgentSettings(BaseSettings):
    """Settings for the AI agent."""

    # LLM Provider
    LLM_PROVIDER: str = "llamastack"
    LLM_MODEL: str = "meta-llama/Llama-3.2-3B-Instruct"
    LLM_API_KEY: str = ""

    # MCP Configuration
    MCP_ENABLED: bool = True
    MCP_SSE_URL: str = "http://localhost:3001/sse"

    # LlamaStack Configuration
    LLAMASTACK_URL: str = "http://localhost:8321/v1"

    # Database URL for checkpoint persistence (optional)
    # When set, enables PostgreSQL-backed conversation history
    DATABASE_URL: str = ""

    model_config = {
        "env_file": ".env",
        "extra": "ignore",
    }


settings = AgentSettings()
