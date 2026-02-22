# Currency & Country Analysis Agent — Complete Project Flow

## Overview

This project is a **Currency and Country Analysis Agent** built using:
- **Python + FastAPI** as the MCP (Model Context Protocol) server
- **OpenAI LLM** as the reasoning/decision layer
- **Two local CSV files** as local data sources
- **One public Exchange Rates API** as the live data source

---

## Project Structure

```
currency-agent/
│
├── .env                              # Config: file paths, API URL, LLM key
├── requirements.txt                  # Python dependencies
│
├── data/
│   ├── countries.csv                 # country_code, country_name
│   └── country_currency.csv          # country_name, currency_name, currency_code
│
├── models/
│   └── schemas.py                    # Pydantic schemas for all 3 tools
│
├── tools/
│   ├── country_tool.py               # Reads countries.csv
│   ├── currency_tool.py              # Reads country_currency.csv
│   └── exchange_rate_tool.py         # Calls Exchange Rates API
│
├── mcp_server/
│   └── server.py                     # FastAPI MCP server — exposes all 3 tools
│
├── agent/
│   ├── prompts.py                    # System prompt for LLM
│   ├── tool_definitions.py           # Tool JSON schemas for LLM
│   └── agent.py                      # LLM agentic loop
│
├── output/                           # Generated reports land here
│
└── main.py                           # Entry point
```

---

## Data Sources

| Source | Type | File / URL |
|---|---|---|
| Country Data | Local CSV | `data/countries.csv` |
| Currency Data | Local CSV | `data/country_currency.csv` |
| Exchange Rates | Public API | `https://open.er-api.com/v6/latest/{currency_code}` |

### How the 3 Sources Interlink

```
countries.csv                    country_currency.csv
─────────────────                ──────────────────────────────
country_code                     country_name  ──→  links to countries.csv
country_name  ──────────────────→country_name
                                 currency_name
                                 currency_code ──→  Exchange Rates API
                                                         ↓
                                               GET /latest?base={currency_code}
                                               returns live exchange rates
```

**Linking Keys:**
- `countries.country_name` → `country_currency.country_name`
- `country_currency.currency_code` → Exchange Rates API base currency

---

## Bird's Eye Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        USER INPUT                               │
│   "Get all Euro countries with live EUR vs USD rate and         │
│    save to ./output/euro_report.json"                           │
└─────────────────────────────┬───────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                        main.py                                  │
│   - Loads .env                                                  │
│   - Takes user input                                            │
│   - Calls run_agent(user_input)                                 │
│   - Receives final result                                       │
│   - Writes result to output path                                │
└─────────────────────────────┬───────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                     agent/agent.py                              │
│   - Builds message: [system_prompt + user_prompt]               │
│   - Sends to LLM with tool_definitions                          │
│   - Runs agentic loop until final answer                        │
└──────────┬──────────────────────────────────────┬───────────────┘
           │                                      │
           ▼                                      ▼
┌──────────────────────┐              ┌───────────────────────────┐
│   agent/prompts.py   │              │  agent/tool_definitions.py│
│   System prompt      │              │  Tool JSON schemas        │
│   Decision rules     │              │  LLM uses these to decide │
│   Output format      │              │  what & how to call tools │
└──────────────────────┘              └───────────────────────────┘
           │
           │  LLM decides which tool to call
           ▼
┌─────────────────────────────────────────────────────────────────┐
│                   mcp_server/server.py                          │
│   POST /tool  { "tool": "get_country_data", "arguments": {} }   │
│   - Receives tool call from agent                               │
│   - Looks up TOOL_REGISTRY                                      │
│   - Routes to correct tool handler                              │
└───────┬─────────────────┬──────────────────────┬───────────────┘
        │                 │                      │
        ▼                 ▼                      ▼
┌──────────────┐  ┌───────────────┐  ┌──────────────────────────┐
│country_tool  │  │currency_tool  │  │  exchange_rate_tool       │
│.py           │  │.py            │  │  .py                      │
│Reads         │  │Reads          │  │  Calls live public API    │
│countries.csv │  │country_       │  │  open.er-api.com/v6/      │
│              │  │currency.csv   │  │  latest/{currency_code}   │
└──────┬───────┘  └───────┬───────┘  └────────────┬─────────────┘
       │                  │                        │
       ▼                  ▼                        ▼
┌──────────────┐  ┌───────────────┐  ┌──────────────────────────┐
│countries.csv │  │country_       │  │  Live Exchange Rate Data  │
│(local file)  │  │currency.csv   │  │  (public internet)        │
│              │  │(local file)   │  │                           │
└──────────────┘  └───────────────┘  └──────────────────────────┘
        │                  │                        │
        └─────���────────────┴────────────────────────┘
                           │
                           │  Tool results returned to agent
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│                     agent/agent.py                              │
│   - Appends tool result to messages                             │
│   - Sends updated messages back to LLM                          │
│   - LLM decides: call more tools OR produce final answer        │
└─────────────────────────────┬───────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                        main.py                                  │
│   - Receives final JSON result from agent                       │
│   - Checks for "output_path" in result                          │
│   - Writes report to ./output/euro_report.json                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Step by Step Detailed Flow

### STEP 1 — User Runs `main.py`

```bash
python main.py
```

```
main.py
  │
  ├── load_dotenv()          ← loads .env (API keys, file paths, URLs)
  ├── print welcome message
  ├── input("Your query: ")  ← waits for user to type
  └── calls run_agent(user_input)
```

> Nothing has called the LLM or any API yet. Just environment loaded and input captured.

---

### STEP 2 — Agent Builds the First LLM Message

```
agent/agent.py → run_agent()
  │
  ├── Builds messages list:
  │     [
  │       { role: "system", content: SYSTEM_PROMPT },  ← from prompts.py
  │       { role: "user",   content: user_input }
  │     ]
  │
  └── Sends to LLM with TOOL_DEFINITIONS attached       ← from tool_definitions.py
```

**What goes to LLM:**
- `SYSTEM_PROMPT` — tells LLM what tools exist, decision rules, output format.
- `TOOL_DEFINITIONS` — JSON schemas so LLM knows exact argument names and types.
- User's natural language query.

---

### STEP 3 — LLM Reasons and Decides Which Tool to Call First

The LLM reads the prompt and thinks:

```
User asked about "Euro countries"
  → I need currency data first to find all Euro countries
  → Call get_currency_data with currency_name = "Euro"
  → Then get exchange rates using currency_code = "EUR"
```

LLM responds with a **tool call** (not a text answer yet):

```json
{
  "tool_calls": [
    {
      "id": "call_abc123",
      "function": {
        "name": "get_currency_data",
        "arguments": "{ \"currency_name\": \"Euro\" }"
      }
    }
  ]
}
```

---

### STEP 4 — Agent Forwards Tool Call to MCP Server

```
agent/agent.py
  │
  └── sees message.tool_calls is not empty
        │
        ├── tool_name = "get_currency_data"
        ├── tool_args = { "currency_name": "Euro" }
        │
        └── calls call_mcp_tool("get_currency_data", { "currency_name": "Euro" })
              │
              └── POST http://localhost:8000/tool
                    body: {
                      "tool": "get_currency_data",
                      "arguments": { "currency_name": "Euro" }
                    }
```

---

### STEP 5 — MCP Server Routes to Correct Tool Handler

```
mcp_server/server.py → call_tool()
  │
  ├── receives request.tool = "get_currency_data"
  ├── looks up TOOL_REGISTRY["get_currency_data"]
  └── calls currency_tool.get_currency_data({ "currency_name": "Euro" })
```

```
tools/currency_tool.py → get_currency_data()
  │
  ├── reads country_currency.csv via pandas
  ├── filters rows where currency_name contains "Euro"
  └── returns:
        {
          "currencies": [
            { "country_name": "Germany",  "currency_name": "Euro", "currency_code": "EUR" },
            { "country_name": "France",   "currency_name": "Euro", "currency_code": "EUR" }
          ]
        }
```

---

### STEP 6 — Tool Result Sent Back to Agent → Agent Sends to LLM

```
agent/agent.py
  │
  ├── receives tool result from MCP
  ├── appends to messages:
  │     {
  │       role: "tool",
  │       tool_call_id: "call_abc123",
  │       content: "{ currencies: [...] }"
  │     }
  │
  └── sends updated messages back to LLM
        (now LLM has: system + user + tool_call + tool_result)
```

---

### STEP 7 — LLM Decides Next Tool Call

LLM now knows:
- Euro countries are: Germany, France (etc.)
- Currency code is: `EUR`

LLM decides next step:

```json
{
  "tool_calls": [
    {
      "id": "call_def456",
      "function": {
        "name": "get_exchange_rates",
        "arguments": "{\"base_currency_code\": \"EUR\", \"target_currency_codes\": [\"USD\"]}"
      }
    }
  ]
}
```

---

### STEP 8 — MCP Routes to Exchange Rate Tool

```
mcp_server/server.py
  │
  └── TOOL_REGISTRY["get_exchange_rates"]
        │
        └── tools/exchange_rate_tool.py → get_exchange_rates()
              │
              ├── calls GET https://open.er-api.com/v6/latest/EUR
              ├── filters to only USD rate
              └── returns:
                    {
                      "base_code": "EUR",
                      "rates": { "USD": 1.08 }
                    }
```

---

### STEP 9 — LLM Gets All Data and Produces Final Answer

Agent appends exchange rate result to messages and calls LLM one last time.

LLM now has everything:
- Euro countries list (from currency tool)
- Live EUR → USD rate (from exchange rate tool)

LLM produces **final JSON answer**:

```json
{
  "output_path": "./output/euro_report.json",
  "report": {
    "base_currency": "EUR",
    "exchange_rate_vs_USD": 1.08,
    "euro_countries": [
      {
        "country_name": "Germany",
        "currency_name": "Euro",
        "currency_code": "EUR",
        "exchange_rate_to_USD": 1.08
      },
      {
        "country_name": "France",
        "currency_name": "Euro",
        "currency_code": "EUR",
        "exchange_rate_to_USD": 1.08
      }
    ],
    "summary": "There are 2 Euro countries in the dataset. Current EUR to USD rate is 1.08."
  }
}
```

---

### STEP 10 — `main.py` Writes Output to File

```
main.py
  │
  ├── receives final result dict from run_agent()
  ├── reads result["output_path"] = "./output/euro_report.json"
  ├── creates ./output/ folder if not exists
  ├── writes result["report"] to ./output/euro_report.json
  └── prints ✅ Output written to: /your/project/output/euro_report.json
```

---

## Full Message Timeline Inside the Agent Loop

```
Round 1:
  SEND  →  [system, user]
  RECV  ←  tool_call: get_currency_data({ currency_name: "Euro" })

Round 2:
  SEND  →  [system, user, assistant(tool_call), tool(currency result)]
  RECV  ←  tool_call: get_exchange_rates({ base: "EUR", targets: ["USD"] })

Round 3:
  SEND  →  [system, user, assistant(tool_call), tool(currency),
            assistant(tool_call), tool(exchange rate result)]
  RECV  ←  Final JSON answer  ← NO more tool_calls, loop ends
```

---

## Data Linking Flow

```
countries.csv                    country_currency.csv
──────────────────               ──────────────────────────────────
country_code: "DE"               country_name: "Germany"
country_name: "Germany"  ──────→ currency_name: "Euro"
                                 currency_code: "EUR"  ──────────→ Exchange Rates API
                                                                   GET /latest/EUR
                                                                   returns: { USD: 1.08 }
```

---

## What Each File Does

| File | Role |
|---|---|
| `.env` | Stores all URLs, keys, paths (never hardcoded) |
| `requirements.txt` | All pip packages needed |
| `data/countries.csv` | Master list of countries + codes |
| `data/country_currency.csv` | Maps country → currency name + code |
| `models/schemas.py` | Pydantic contracts (input/output shapes for all 3 tools) |
| `tools/country_tool.py` | Reads countries.csv, filters, returns country records |
| `tools/currency_tool.py` | Reads country_currency.csv, filters, returns currency records |
| `tools/exchange_rate_tool.py` | Calls live API, returns exchange rates |
| `mcp_server/server.py` | FastAPI app, single /tool endpoint, routes to correct tool |
| `agent/prompts.py` | Tells LLM what tools exist + decision rules + output format |
| `agent/tool_definitions.py` | JSON schemas so LLM knows exact argument names + types |
| `agent/agent.py` | LLM loop: sends messages, handles tool calls, gets final answer |
| `main.py` | Entry point: takes input, runs agent, writes output file |
| `output/` | All generated reports land here |

---

## Common Flow Patterns by Query Type

| User Query | Tools Called (in order) |
|---|---|
| `What currency does Japan use?` | `get_currency_data` |
| `What is the country code for India?` | `get_country_data` |
| `What is the INR to USD rate?` | `get_exchange_rates` |
| `What currency does Germany use and what is its USD rate?` | `get_currency_data` → `get_exchange_rates` |
| `List all Euro countries with live USD rate` | `get_currency_data` → `get_exchange_rates` |
| `Full report: all countries, currencies, and USD rates` | `get_country_data` → `get_currency_data` → `get_exchange_rates` |

---

## Example Prompts to Test

| Complexity | Prompt |
|---|---|
| **Simple** | `What is the currency of Japan?` |
| **Simple** | `Give me the country code for Germany.` |
| **Medium** | `What is the exchange rate of INR against USD?` |
| **Medium** | `Compare the currencies of India, Japan and UK.` |
| **Complex** | `Get all countries that use Euro, fetch live exchange rates for EUR vs USD, GBP and INR, and save the report to ./output/euro_report.json` |
| **Complex** | `Generate a full currency and exchange rate report for all countries in my dataset using USD as base currency and save to ./output/full_report.json` |

---

## How to Run

```bash
# Step 1 — Install dependencies
pip install -r requirements.txt

# Step 2 — Add your OpenAI key to .env
OPENAI_API_KEY=sk-your-key-here

# Step 3 — Terminal 1: Start MCP Server
uvicorn mcp_server.server:app --host 0.0.0.0 --port 8000 --reload

# Step 4 — Terminal 2: Run the Agent
python main.py
```

---

## How to Convert This File to PDF

| Tool | Steps |
|---|---|
| **VS Code** | Open file → Right click → Open Preview → Ctrl+P → Save as PDF |
| **md2pdf.com** | Go to md2pdf.com → Paste content → Download PDF |
| **Pandoc** | Run: `pandoc PROJECT_FLOW.md -o project.pdf` |
| **Google Docs** | Paste content → File → Download → PDF |
| **Notion** | Paste content → Export as PDF |

---

*Generated by GitHub Copilot — Currency & Country Analysis Agent Project*