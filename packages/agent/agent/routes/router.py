"""Agent API router factory."""

from fastapi import APIRouter

from .health import router as health_router
from .stream import router as stream_router
from .threads import router as threads_router
from .history import router as history_router


def create_agent_router() -> APIRouter:
    """Create the agent API router with all sub-routes.

    Returns:
        A FastAPI APIRouter with all agent endpoints mounted.
    """
    router = APIRouter()
    router.include_router(health_router, tags=["agent"])
    router.include_router(stream_router, tags=["agent"])
    router.include_router(threads_router, tags=["agent"])
    router.include_router(history_router, tags=["agent"])
    return router
