"""
Health check endpoints
"""

from fastapi import APIRouter
from ..schemas.health import HealthResponse
from datetime import datetime, timezone
import httpx

# Capture API service startup time
API_START_TIME = datetime.now(timezone.utc)
from fastapi import Depends
from typing import Optional
try:
    from db import DatabaseService, get_db_service  # type: ignore[import-untyped]
except Exception:
    # DB package not available or untyped
    DatabaseService = None  # type: ignore[assignment]
    get_db_service = None  # type: ignore[assignment]

router = APIRouter()


@router.get("/", response_model=list[HealthResponse])
async def health_check(
    db_service: Optional[DatabaseService] = Depends(get_db_service) if get_db_service else None
) -> list[HealthResponse]:
    """Health check endpoint with dependency injection"""
    api_response = HealthResponse(
        name="API",
        status="healthy",
        message="API is running",
        version="0.0.0",
        start_time=API_START_TIME.isoformat()
    )

    # Get database health using dependency injection
    responses = [api_response]
    if db_service:
        db_health = await db_service.health_check()
        db_response = HealthResponse(**db_health)
        responses.append(db_response)



    # Agent health - runs in-process with the API
    agent_response = HealthResponse(
        name="Agent",
        status="healthy",
        message="Agent is available",
        version="0.0.0",
        start_time=API_START_TIME.isoformat()
    )
    responses.append(agent_response)

    # MCP Server health - separate process
    try:
        async with httpx.AsyncClient() as client:
            mcp_resp = await client.get("http://localhost:3001/health", timeout=2.0)
            mcp_status = "healthy" if mcp_resp.status_code == 200 else "degraded"
            mcp_message = "MCP server is running"
    except Exception:
        mcp_status = "down"
        mcp_message = "MCP server is not reachable"
    mcp_response = HealthResponse(
        name="MCP",
        status=mcp_status,
        message=mcp_message,
        version="0.0.0",
        start_time=API_START_TIME.isoformat()
    )
    responses.append(mcp_response)

    # Chat health - build-time component package
    chat_response = HealthResponse(
        name="Chat",
        status="healthy",
        message="Chat package is available",
        version="0.0.0",
        start_time=API_START_TIME.isoformat()
    )
    responses.append(chat_response)

    # LlamaStack health - separate process
    try:
        async with httpx.AsyncClient() as client:
            ls_resp = await client.get("http://localhost:8321/health", timeout=2.0)
            ls_status = "healthy" if ls_resp.status_code == 200 else "degraded"
            ls_message = "LlamaStack is running"
    except Exception:
        ls_status = "down"
        ls_message = "LlamaStack is not reachable"
    llamastack_response = HealthResponse(
        name="LlamaStack",
        status=ls_status,
        message=ls_message,
        version="0.0.0",
        start_time=API_START_TIME.isoformat()
    )
    responses.append(llamastack_response)
    return responses
