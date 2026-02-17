"""Tests for agent settings."""

from agent.settings import AgentSettings


class TestAgentSettings:
    """Tests for AgentSettings configuration."""

    def test_default_values(self):
        settings = AgentSettings(LLM_API_KEY="test-key")
        assert settings.LLM_PROVIDER == "llamastack"
        assert settings.LLM_MODEL == "meta-llama/Llama-3.2-3B-Instruct"
        assert settings.MCP_ENABLED is True
        assert settings.DATABASE_URL == ""

    def test_custom_provider(self):
        settings = AgentSettings(
            LLM_PROVIDER="openai",
            LLM_MODEL="gpt-4o",
            LLM_API_KEY="test-key",
        )
        assert settings.LLM_PROVIDER == "openai"
        assert settings.LLM_MODEL == "gpt-4o"


    def test_mcp_configuration(self):
        settings = AgentSettings(
            LLM_API_KEY="test-key",
            MCP_ENABLED=True,
            MCP_SSE_URL="http://mcp-server:3001/sse",
        )
        assert settings.MCP_ENABLED is True
        assert settings.MCP_SSE_URL == "http://mcp-server:3001/sse"

    def test_llamastack_configuration(self):
        settings = AgentSettings(
            LLM_API_KEY="test-key",
            LLAMASTACK_URL="http://llamastack:8321/v1",
        )
        assert settings.LLAMASTACK_URL == "http://llamastack:8321/v1"
    def test_database_url(self):
        settings = AgentSettings(
            LLM_API_KEY="test-key",
            DATABASE_URL="postgresql+asyncpg://user:pass@localhost:5432/mydb",
        )
        assert settings.DATABASE_URL != ""
