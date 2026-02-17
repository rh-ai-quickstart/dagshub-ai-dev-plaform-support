"""Tests for MCP server settings."""

import pytest

from src.settings import MCPSettings


def test_default_settings() -> None:
    """Test default settings values."""
    settings = MCPSettings()
    assert settings.MCP_HOST == "0.0.0.0"
    assert settings.MCP_PORT == 3001
    assert settings.MCP_TRANSPORT_PROTOCOL == "sse"


def test_settings_from_env(monkeypatch: pytest.MonkeyPatch) -> None:
    """Test settings can be overridden via environment variables."""
    monkeypatch.setenv("MCP_PORT", "4000")
    settings = MCPSettings()
    assert settings.MCP_PORT == 4000
