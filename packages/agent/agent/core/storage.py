"""Checkpoint storage for conversation persistence."""

from contextlib import asynccontextmanager
from typing import AsyncGenerator

from langgraph.checkpoint.base import BaseCheckpointSaver
from langgraph.checkpoint.memory import MemorySaver

from ..settings import settings


@asynccontextmanager
async def get_checkpoint_saver() -> AsyncGenerator[BaseCheckpointSaver, None]:
    """Get the appropriate checkpoint saver based on configuration.

    When DATABASE_URL is set, uses PostgreSQL for persistent storage.
    Otherwise, falls back to in-memory storage.

    Yields:
        A configured checkpoint saver instance.
    """
    if settings.DATABASE_URL:
        from langgraph.checkpoint.postgres.aio import AsyncPostgresSaver

        # Convert SQLAlchemy URL to psycopg format
        db_url = settings.DATABASE_URL
        if db_url.startswith("postgresql+asyncpg://"):
            db_url = db_url.replace("postgresql+asyncpg://", "postgresql://")

        async with AsyncPostgresSaver.from_conn_string(db_url) as saver:
            await saver.setup()
            yield saver
    else:
        yield MemorySaver()
