# AI Agent for Currency & Country Information

## 🎯 Project Overview

This project is an **AI-powered agent system** that intelligently answers questions about countries and currencies. It combines local data sources with live internet data, uses Claude AI (LLM) as the reasoning engine, and implements the Model Context Protocol (MCP) to expose tools to the AI agent.

### What Does This Project Do?

The agent can answer questions like:
- "What currency does India use?"
- "What is the current exchange rate for Japanese Yen?"
- "Tell me about the Euro"

Based on the user's question, the AI agent:
1. **Analyzes** the question to understand what information is needed
2. **Decides** which tools to use (local data or internet API)
3. **Fetches** the relevant data
4. **Generates** a natural language answer
5. **Saves** the result in a clean CSV format with only relevant data

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                          USER                                   │
│              "What currency does India use?"                    │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                        main.py                                  │
│  • Gets user input                                              │
│  • Calls the AI Agent                                           │
│  • Saves structured CSV output                                  │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                     agent/agent.py                              │
│  • Claude AI (LLM) - Decision Making & Reasoning                │
│  • Analyzes user question                                       │
│  • Decides which tools to call                                  │
│  • Formulates natural language response                         │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                   mcp_server/server.py                          │
│  • MCP Server - Exposes Tools to AI                            │
│  • Tool 1: get_currency_by_country                             │
│  • Tool 2: get_exchange_rate                                   │
└────────────────────────────┬────────────────────────────────────┘
                             │
                ┌────────────┴────────────┐
                │                         │
                ▼                         ▼
   ┌─────────────────────┐   ┌─────────────────────┐
   │  Local CSV Data     │   │  Internet API       │
   │  (country_currency) │   │  (Exchange Rates)   │
   │                     │   │                     │
   │  Data Source:       │   │  Data Source:       │
   │  CSV file           │   │  open.er-api.com    │
   └─────────────────────┘   └─────────────────────┘
```

---

## 📊 Data Sources

### 1. **Local Data** (CSV Files)
- **File**: `data/country_currency.csv`
- **Contains**: Country names and their official currencies
- **Access**: Via local FastAPI endpoint (requires server running)
- **Example Data**:
  ```csv
  country_name,currency_name,currency_code
  India,Indian Rupee,INR
  United States,US Dollar,USD
  Japan,Japanese Yen,JPY
  ```

### 2. **Live Internet Data** (Exchange Rates API)
- **API**: `https://open.er-api.com/v6/latest/USD`
- **Contains**: Current exchange rates for all currencies
- **Updates**: Real-time data from the internet
- **Example Response**:
  ```json
  {
    "base_code": "USD",
    "rates": {
      "EUR": 0.85,
      "INR": 83.12,
      "JPY": 149.25
    }
  }
  ```

---

## 🛠️ Available Tools (Limited to 2)

The AI agent has access to **only 2 tools**:

### Tool 1: `get_currency_by_country`
- **Purpose**: Find what currency a country uses
- **Data Source**: Local CSV file
- **Example**: "What currency does India use?" → Returns "Indian Rupee (INR)"

### Tool 2: `get_exchange_rate`
- **Purpose**: Get current exchange rate for a currency
- **Data Source**: Live internet API
- **Example**: "What is the EUR exchange rate?" → Returns "0.85 USD"

### ❌ Removed Tool
- **`convert_currency`** was removed to avoid fetching live data for conversions

---

## 🔄 How It Works (Step-by-Step)

### Step 1: User Asks a Question
```
User: "What currency does Japan use?"
```

### Step 2: Agent Receives Question
- The question is sent to Claude AI (LLM)
- Claude analyzes the intent: "User wants to know Japan's currency"

### Step 3: Agent Calls Appropriate Tool
- Claude decides: "I need to use `get_currency_by_country` tool"
- MCP server executes the tool
- Tool queries local CSV data for "Japan"

### Step 4: Tool Returns Data
```json
{
  "country_name": "Japan",
  "currency_name": "Japanese Yen",
  "currency_code": "JPY"
}
```

### Step 5: Agent Generates Response
- Claude formulates a natural language answer:
  "Japan uses the Japanese Yen (JPY)"

### Step 6: Save to CSV
- The response is parsed to extract relevant data
- Saved in structured CSV format:
  ```csv
  timestamp,question,country,currency_code,currency_name,exchange_rate,base_currency
  2026-02-22 10:30:45,What currency does Japan use?,Japan,JPY,Yen,,USD
  ```

---

## 📁 Project Structure

```
proj-2-agentGenerateOutputfromPrompt/
│
├── main.py                          # Entry point - runs the agent
├── problem statement.txt            # Original requirements
├── PROJECT_FLOW.md                  # Detailed architecture docs
├── PROJECT.md                       # This file!
│
├── agent/
│   └── agent.py                     # AI Agent logic (Claude LLM integration)
│
├── mcp_server/
│   └── server.py                    # MCP Server - exposes tools to AI
│
├── tools/
│   ├── country_currency_tool.py     # Tool for country-currency mapping
│   └── currency_rates_tool.py       # Tool for live exchange rates
│
├── api/
│   └── country_currency.py          # FastAPI endpoint for local data
│
├── data/
│   ├── countries.csv                # Country data
│   └── country_currency.csv         # Currency data per country
│
└── output/                          # Generated CSV files stored here
    ├── what_currency_does_india_use_20260222_103045.csv
    └── what_is_exchange_rate_for_eur_20260222_103120.csv
```

---

## 🚀 How to Use

### Prerequisites
1. Python 3.8+
2. API Key for Claude AI (stored in `.env` file)
3. Internet connection (for exchange rate tool)

### Running the Agent

```bash
# Navigate to project directory
cd proj-2-agentGenerateOutputfromPrompt

# Run the agent
python main.py
```

### Example Interaction

```
🤖 AI Agent - Country & Currency Assistant (2 Tools Available)
======================================================================

What would you like to know?
Examples:
  - What currency does India use?
  - What is the exchange rate for EUR?
  - What is the exchange rate for Japanese Yen?

Your question: What currency does India use?

🔄 Processing your request...

🤖 Assistant: India uses the Indian Rupee (INR).

✓ Result saved to: output/what_currency_does_india_use_20260222_103045.csv

✅ Process completed successfully!
```

### Output CSV Format

The generated CSV file contains structured data:

```csv
timestamp,question,country,currency_code,currency_name,exchange_rate,base_currency
2026-02-22 10:30:45,What currency does India use?,India,INR,Rupee,,USD
```

---

## 🎓 Key Technologies Used

| Technology | Purpose |
|------------|---------|
| **Claude AI (Anthropic)** | Large Language Model for reasoning and decision-making |
| **MCP (Model Context Protocol)** | Standard protocol for exposing tools to LLMs |
| **FastAPI** | Local API server for CSV data |
| **Python Requests** | HTTP client for external APIs |
| **CSV** | Data storage and output format |
| **dotenv** | Environment variable management |

---

## 💡 Key Concepts Explained

### What is an AI Agent?
An AI agent is a program that:
1. **Perceives** - Understands user questions
2. **Reasons** - Decides what actions to take
3. **Acts** - Calls tools to fetch data
4. **Responds** - Generates helpful answers

### What is MCP (Model Context Protocol)?
MCP is a standard way to expose tools/functions to AI models. It allows:
- The AI to discover available tools
- The AI to understand what each tool does
- The AI to call tools with proper parameters
- Seamless integration between AI and data sources

### Why Use LLM + MCP Together?
- **LLM (Claude)**: Provides intelligence, reasoning, and natural language understanding
- **MCP**: Provides structured access to data and tools
- **Together**: Creates a powerful system where AI can intelligently fetch and analyze data

---

## 🔧 Current Configuration

- **Number of Tools**: 2 (limited to avoid unnecessary complexity)
- **Output Format**: CSV (structured, concise, easy to analyze)
- **Data Extraction**: Intelligent parsing to extract only relevant facts
- **Error Handling**: Errors also saved in CSV format with same structure

---

## 📝 Sample Use Cases

1. **Country Currency Lookup**
   - Question: "What currency does Germany use?"
   - Tool Used: `get_currency_by_country`
   - Data Source: Local CSV

2. **Exchange Rate Query**
   - Question: "What is the current exchange rate for British Pound?"
   - Tool Used: `get_exchange_rate`
   - Data Source: Internet API

3. **Multiple Questions**
   - Question: "What currency does France use and what's its exchange rate?"
   - Tools Used: Both tools sequentially
   - Data Sources: Local CSV + Internet API

---

## 🎯 Learning Objectives

This project demonstrates:
1. ✅ How to build an AI agent that makes decisions
2. ✅ How to integrate LLM with external data sources
3. ✅ How to use MCP to expose tools to AI
4. ✅ How to combine local and internet data sources
5. ✅ How to parse AI responses and extract structured data
6. ✅ How to generate clean, concise CSV outputs

---

## 🚧 Future Enhancements

Potential improvements:
- [ ] Add database support (instead of CSV)
- [ ] Support batch queries
- [ ] Add data visualization
- [ ] Implement caching for exchange rates
- [ ] Add more sophisticated error handling
- [ ] Create a web interface
- [ ] Add support for historical exchange rates

---

## 📞 Author Notes

This project is designed to be **educational and easy to understand**. It shows how modern AI systems can intelligently combine multiple data sources to answer user questions. The code is well-commented and structured for learning purposes.

**Key Takeaway**: This is not just about getting data—it's about letting AI **decide** what data to fetch and **how** to answer questions intelligently!

---

*Last Updated: February 22, 2026*
