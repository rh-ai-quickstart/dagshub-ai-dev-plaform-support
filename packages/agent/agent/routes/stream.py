"""Streaming endpoint for agent interaction."""

from fastapi import APIRouter
from fastapi.responses import StreamingResponse

from ..schema import StreamRequest
from ..core.manager import stream_agent_response

router = APIRouter()


@router.post("/stream")
async def stream(request: StreamRequest) -> StreamingResponse:
    """Stream agent response as Server-Sent Events.

    Args:
        request: The stream request containing the user message.

    Returns:
        A streaming response with SSE events.
    """
    return StreamingResponse(
        stream_agent_response(
            message=request.message,
            thread_id=request.thread_id,
        ),
        media_type="text/event-stream",
        headers={
            "Cache-Control": "no-cache",
            "Connection": "keep-alive",
            "X-Accel-Buffering": "no",
        },
    )
