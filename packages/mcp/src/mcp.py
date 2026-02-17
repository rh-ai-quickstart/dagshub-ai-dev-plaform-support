"""FastMCP server configuration and tool registration."""

from fastmcp import FastMCP

mcp = FastMCP("MCP Server")


# Register tools using the @mcp.tool() decorator
@mcp.tool()
def multiply_numbers(a: float, b: float) -> float:
    """Multiply two numbers together.

    Args:
        a: First number.
        b: Second number.

    Returns:
        The product of a and b.
    """
    return a * b
