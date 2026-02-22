"""
MCP Server with Claude AI integration and all tools.
This server provides country, currency, and exchange rate tools via MCP protocol.
"""

import os
import sys
import json
from typing import Any, Dict
from anthropic import Anthropic
from dotenv import load_dotenv
from mcp.server import Server
from mcp.server.stdio import stdio_server
from mcp.types import Tool, TextContent

# Add parent directory to path to import tools
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

# Only import the tools we need (limited to 3 tools)
from tools.country_currency_tool import CountryCurrencyTool
from tools.currency_rates_tool import CurrencyRatesTool

# Load environment variables
base_dir = os.path.dirname(__file__)
private_env_dir = os.path.abspath(os.path.join(base_dir, "..", "..", "donotcheckin-personalkeyinfo"))
dotenv_path = os.path.join(private_env_dir, ".env")
if os.path.exists(dotenv_path):
    load_dotenv(dotenv_path)
    print(f"✓ Loaded environment from: {dotenv_path}")
else:
    load_dotenv()
    print("Loaded environment from default locations")

LLM_API_KEY = os.environ.get("LLM_API_KEY")
if not LLM_API_KEY:
    raise ValueError("LLM_API_KEY environment variable is not set. Please add it to your .env file.")
MODEL = os.environ.get("LLM_MODEL", "claude-sonnet-4-20250514")

# Initialize Anthropic client
anthropic_client = Anthropic(api_key=LLM_API_KEY)

# Initialize tool instances (2 tool classes for 2 tools)
country_currency_tool = CountryCurrencyTool()
currency_rates_tool = CurrencyRatesTool()

# Initialize MCP Server
mcp_server = Server("mcp-country-currency-server")

# Define only 2 essential MCP tools (no live data conversion)
TOOLS = [
    {
        "name": "get_currency_by_country",
        "description": "Get the official currency used by a specific country. Provide the country name to get currency details.",
        "input_schema": {
            "type": "object",
            "properties": {
                "country_name": {
                    "type": "string",
                    "description": "The country name (e.g., 'India', 'United States', 'Japan')"
                }
            },
            "required": ["country_name"]
        }
    },
    {
        "name": "get_exchange_rate",
        "description": "Get the current exchange rate for a specific currency relative to USD.",
        "input_schema": {
            "type": "object",
            "properties": {
                "currency_code": {
                    "type": "string",
                    "description": "The target currency code (e.g., 'EUR', 'INR', 'GBP', 'JPY')"
                }
            },
            "required": ["currency_code"]
        }
    }
]


def handle_tool_call(tool_name: str, arguments: Dict[str, Any]) -> Dict[str, Any]:
    """
    Route tool calls to appropriate handlers (Limited to 2 tools only).
    
    Args:
        tool_name: Name of the tool to execute
        arguments: Arguments for the tool
        
    Returns:
        Result from the tool execution
    """
    try:
        # Tool 1: Get Currency by Country
        if tool_name == "get_currency_by_country":
            country = arguments.get("country_name", "")
            result = country_currency_tool.get_by_country_name(country)
            if result:
                return {"success": True, "data": result}
            else:
                return {"success": False, "error": f"No currency data found for '{country}'"}
        
        # Tool 2: Get Exchange Rate
        elif tool_name == "get_exchange_rate":
            code = arguments.get("currency_code", "")
            result = currency_rates_tool.get_rate(code)
            if result:
                return {"success": True, "data": result}
            else:
                return {"success": False, "error": f"Exchange rate for '{code}' not found"}
        
        else:
            return {"success": False, "error": f"Unknown tool: {tool_name}. Only 2 tools are available."}
            
    except Exception as e:
        return {"success": False, "error": f"Error executing {tool_name}: {str(e)}"}


@mcp_server.list_tools()
async def list_tools() -> list[Tool]:
    """List available tools for the MCP server."""
    return [
        Tool(
            name=tool["name"],
            description=tool["description"],
            inputSchema=tool["input_schema"]
        )
        for tool in TOOLS
    ]


@mcp_server.call_tool()
async def call_tool(name: str, arguments: Any) -> list[TextContent]:
    """Handle tool calls from the MCP client."""
    try:
        result = handle_tool_call(name, arguments)
        return [TextContent(type="text", text=json.dumps(result, indent=2))]
    except Exception as e:
        error_result = {"success": False, "error": str(e)}
        return [TextContent(type="text", text=json.dumps(error_result, indent=2))]


async def main():
    """Main entry point for the MCP server."""
    print("=" * 70)
    print("🚀 MCP Country & Currency Server")
    print("=" * 70)
    print(f"Model: {MODEL}")
    print(f"Available Tools: {len(TOOLS)}")
    for tool in TOOLS:
        print(f"  • {tool['name']}")
    print("=" * 70)
    print("Server ready and waiting for connections...\n")
    
    # Run the MCP server using stdio
    async with stdio_server() as (read_stream, write_stream):
        await mcp_server.run(
            read_stream,
            write_stream,
            mcp_server.create_initialization_options()
        )


if __name__ == "__main__":
    import asyncio
    asyncio.run(main())
