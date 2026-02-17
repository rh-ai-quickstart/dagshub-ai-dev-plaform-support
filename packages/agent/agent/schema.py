"""Request and response schemas for the agent API."""

from pydantic import BaseModel, Field


class ChatMessage(BaseModel):
    """A single chat message."""

    role: str = Field(..., description="Message role: 'human' or 'ai'")
    content: str = Field(..., description="Message content")
    tool_calls: list[dict] | None = Field(
        default=None, description="Tool calls made by the AI"
    )


class StreamRequest(BaseModel):
    """Request body for streaming chat."""

    message: str = Field(..., description="User message to send to the agent")
    thread_id: str | None = Field(
        default=None, description="Thread ID for conversation continuity"
    )


class FeedbackRequest(BaseModel):
    """Request body for submitting feedback."""

    run_id: str = Field(..., description="Run ID to provide feedback for")
    score: float = Field(..., ge=0, le=1, description="Feedback score between 0 and 1")
    comment: str | None = Field(default=None, description="Optional feedback comment")
