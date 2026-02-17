"""Agent manager for streaming and event formatting."""

import json
import uuid
from typing import AsyncGenerator

from langchain_core.messages import AIMessageChunk, HumanMessage

from .agent import get_agent


async def stream_agent_response(
    message: str,
    thread_id: str | None = None,
) -> AsyncGenerator[str, None]:
    """Stream agent response as Server-Sent Events.

    Args:
        message: The user message to process.
        thread_id: Optional thread ID for conversation continuity.

    Yields:
        SSE-formatted strings with agent events.
    """
    if thread_id is None:
        thread_id = str(uuid.uuid4())

    config = {"configurable": {"thread_id": thread_id}}

    async with get_agent() as agent:
        # Send metadata event with thread info
        yield format_sse_event(
            "metadata",
            {"thread_id": thread_id, "run_id": str(uuid.uuid4())},
        )

        async for event in agent.astream_events(
            {"messages": [HumanMessage(content=message)]},
            config=config,
            version="v2",
        ):
            kind = event["event"]

            if kind == "on_chat_model_stream":
                chunk = event["data"]["chunk"]
                if isinstance(chunk, AIMessageChunk) and chunk.content:
                    yield format_sse_event(
                        "token",
                        {"content": chunk.content},
                    )

                # Stream tool call chunks
                if isinstance(chunk, AIMessageChunk) and chunk.tool_call_chunks:
                    for tool_chunk in chunk.tool_call_chunks:
                        yield format_sse_event(
                            "tool_call_chunk",
                            {
                                "id": tool_chunk.get("id", ""),
                                "name": tool_chunk.get("name", ""),
                                "args": tool_chunk.get("args", ""),
                            },
                        )

            elif kind == "on_tool_start":
                yield format_sse_event(
                    "tool_start",
                    {
                        "name": event["name"],
                        "run_id": str(event.get("run_id", "")),
                    },
                )

            elif kind == "on_tool_end":
                yield format_sse_event(
                    "tool_end",
                    {
                        "name": event["name"],
                        "output": str(event["data"].get("output", "")),
                    },
                )

        # End event
        yield format_sse_event("end", {})


def format_sse_event(event_type: str, data: dict) -> str:
    """Format a Server-Sent Event string.

    Args:
        event_type: The event type.
        data: The event data to serialize.

    Returns:
        SSE-formatted string.
    """
    return f"event: {event_type}\ndata: {json.dumps(data)}\n\n"
