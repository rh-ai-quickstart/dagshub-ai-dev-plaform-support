"""Conversation history endpoint."""

from fastapi import APIRouter

router = APIRouter()


@router.get("/history/{thread_id}")
async def get_history(thread_id: str) -> dict:
    """Get conversation history for a thread.

    Args:
        thread_id: The thread ID to retrieve history for.

    Note: Full history requires PostgreSQL checkpoint storage.
    With in-memory storage, history is only available during the session.
    """
    return {"thread_id": thread_id, "messages": []}
