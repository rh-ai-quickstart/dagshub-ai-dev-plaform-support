"""Agent creation and configuration."""

from contextlib import asynccontextmanager
from typing import AsyncGenerator

from langgraph.graph.state import CompiledStateGraph
from langgraph.prebuilt import create_react_agent

from ..settings import AgentSettings, settings
from .providers import get_chat_model
from .prompt import SYSTEM_PROMPT
from .storage import get_checkpoint_saver


@asynccontextmanager
async def get_agent(
    agent_settings: AgentSettings | None = None,
) -> AsyncGenerator[CompiledStateGraph, None]:
    """Create and configure the ReAct agent.

    Args:
        agent_settings: Optional settings override. Uses global settings if not provided.

    Yields:
        A compiled LangGraph agent ready for invocation.
    """
    config = agent_settings or settings
    model = get_chat_model(config)
    tools: list = []

    # Load MCP tools if enabled
    if config.MCP_ENABLED:
        try:
            from langchain_mcp_adapters.client import MultiServerMCPClient

            mcp_client = MultiServerMCPClient(
                {
                    "mcp": {
                        "url": config.MCP_SSE_URL,
                        "transport": "sse",
                    }
                }
            )
            mcp_tools = await mcp_client.get_tools()
            tools.extend(mcp_tools)
        except Exception as e:
            import logging

            logging.warning(f"Failed to load MCP tools: {e}")

    async with get_checkpoint_saver() as checkpointer:
        agent = create_react_agent(
            model=model,
            tools=tools,
            prompt=SYSTEM_PROMPT,
            checkpointer=checkpointer,
        )
        yield agent
