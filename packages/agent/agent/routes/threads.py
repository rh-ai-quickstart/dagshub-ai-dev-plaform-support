"""Thread management endpoints."""

from fastapi import APIRouter

router = APIRouter()


@router.get("/threads")
async def list_threads() -> dict:
    """List available conversation threads.

    Note: Full thread listing requires PostgreSQL checkpoint storage.
    With in-memory storage, this returns an empty list.
    """
    return {"threads": []}


@router.delete("/threads/{thread_id}")
async def delete_thread(thread_id: str) -> dict:
    """Delete a conversation thread.

    Args:
        thread_id: The thread ID to delete.

    Note: Full thread deletion requires PostgreSQL checkpoint storage.
    """
    return {"deleted": thread_id}
