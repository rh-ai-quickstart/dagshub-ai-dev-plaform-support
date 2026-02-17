"""Health check endpoint for the agent."""

from fastapi import APIRouter

router = APIRouter()


@router.get("/health")
async def health() -> dict:
    """Check agent health status."""
    return {
        "status": "healthy",
        "service": "agent",
    }
