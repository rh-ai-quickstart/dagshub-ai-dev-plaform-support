"""Example: adding tools to the MCP server.

To add a new tool, define it in this directory and register it
in src/mcp.py using the @mcp.tool() decorator. For example:

    # In src/mcp.py
    @mcp.tool()
    def my_tool(param: str) -> str:
        """Description of what the tool does."""
        return f"Result: {param}"

Or define the function here and import + register it in mcp.py.
See the multiply_numbers tool in src/mcp.py for a working example.
"""
