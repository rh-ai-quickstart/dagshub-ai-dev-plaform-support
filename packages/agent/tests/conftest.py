"""Test fixtures for agent package."""

import pytest
from fastapi import FastAPI
from fastapi.testclient import TestClient

from agent.routes.router import create_agent_router


@pytest.fixture
def app() -> FastAPI:
    """Create a test FastAPI application with agent routes."""
    app = FastAPI()
    router = create_agent_router()
    app.include_router(router, prefix="/agent")
    return app


@pytest.fixture
def client(app: FastAPI) -> TestClient:
    """Create a test client for the agent API."""
    return TestClient(app)
