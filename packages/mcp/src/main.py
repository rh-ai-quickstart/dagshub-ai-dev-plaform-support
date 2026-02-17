"""MCP Server entry point."""

import uvicorn

from .settings import settings


def main() -> None:
    """Start the MCP server."""
    uvicorn.run(
        "src.api:app",
        host=settings.MCP_HOST,
        port=settings.MCP_PORT,
        reload=True,
    )


if __name__ == "__main__":
    main()
