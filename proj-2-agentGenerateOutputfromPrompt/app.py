"""
Streamlit UI for Currency & Country Analysis Agent

Run with: streamlit run app.py
"""

import streamlit as st
import os
from datetime import datetime
from dotenv import load_dotenv
from agent.agent import load_config, create_llm_client, run_agent_conversation
from tools.currency_rates_tool import CurrencyRatesTool
from tools.country_currency_tool import CountryCurrencyTool

# Page configuration
st.set_page_config(
    page_title="Currency & Country Analysis Agent",
    page_icon="🌍",
    layout="wide",
    initial_sidebar_state="expanded"
)

# Custom CSS
st.markdown("""
    <style>
    .main {
        padding: 2rem;
    }
    .stTextInput > div > div > input {
        font-size: 16px;
    }
    .assistant-message {
        background-color: #f0f2f6;
        padding: 1rem;
        border-radius: 0.5rem;
        margin: 1rem 0;
    }
    .user-message {
        background-color: #e3f2fd;
        padding: 1rem;
        border-radius: 0.5rem;
        margin: 1rem 0;
    }
    </style>
""", unsafe_allow_html=True)

# Initialize session state
if 'conversation_history' not in st.session_state:
    st.session_state.conversation_history = []
if 'llm_client' not in st.session_state:
    st.session_state.llm_client = None
if 'model' not in st.session_state:
    st.session_state.model = None


@st.cache_resource
def initialize_agent():
    """Initialize the agent and tools (cached)."""
    try:
        # Load configuration
        api_key, model = load_config()
        
        # Create LLM client
        llm_client = create_llm_client(api_key)
        
        return llm_client, model, None
    except Exception as e:
        return None, None, str(e)


def get_agent_response(user_input, llm_client, model):
    """Get response from the agent."""
    # Initialize tool instances
    currency_rates_tool = CurrencyRatesTool()
    country_currency_tool = CountryCurrencyTool()
    
    # Define tools schema for Claude
    tools = [
        {
            "name": "get_currency_by_country",
            "description": "Get the official currency used by a specific country. Returns currency name and code.",
            "input_schema": {
                "type": "object",
                "properties": {
                    "country": {
                        "type": "string",
                        "description": "The country name (e.g., 'India', 'United States', 'Japan')"
                    }
                },
                "required": ["country"]
            }
        },
        {
            "name": "get_exchange_rate",
            "description": "Get the current live exchange rate for a specific currency relative to USD from the public API.",
            "input_schema": {
                "type": "object",
                "properties": {
                    "currency": {
                        "type": "string",
                        "description": "The currency code (e.g., 'EUR', 'INR', 'GBP', 'JPY')"
                    }
                },
                "required": ["currency"]
            }
        }
    ]
    
    # Define tool handler function
    def tool_handler(tool_name, tool_input):
        """Execute the requested tool and return results."""
        try:
            if tool_name == "get_currency_by_country":
                country = tool_input.get("country", "")
                result = country_currency_tool.get_by_country_name(country)
                if result:
                    return f"The currency of {country} is {result.get('currency_name', 'Unknown')} ({result.get('currency_code', 'N/A')})."
                else:
                    return f"Could not find currency information for '{country}'. Please check the country name."
            
            elif tool_name == "get_exchange_rate":
                currency_code = tool_input.get("currency", "").upper()
                result = currency_rates_tool.get_rate(currency_code)
                if result and 'rate' in result:
                    rate = result['rate']
                    base = result.get('base', 'USD')
                    return f"The current exchange rate for {currency_code} is 1 {base} = {rate} {currency_code}."
                else:
                    return f"Could not fetch exchange rate for '{currency_code}'. Please check the currency code."
            
            else:
                return f"Unknown tool: {tool_name}"
        
        except Exception as e:
            return f"Error executing {tool_name}: {str(e)}"
    
    # Call the agent conversation function with tools and handler
    result = run_agent_conversation(llm_client, model, tools, user_input, tool_handler)
    
    return result


# Main UI
def main():
    # Header
    st.title("🌍 Currency & Country Analysis Agent")
    st.markdown("Ask questions about countries, currencies, and exchange rates!")
    
    # Sidebar
    with st.sidebar:
        st.header("ℹ️ About")
        st.markdown("""
        This AI agent can help you with:
        - Currency information by country
        - Live exchange rates (vs USD)
        - Country and currency details
        
        **Powered by:**
        - Claude (Anthropic)
        - Live Exchange Rates API
        """)
        
        st.divider()
        
        st.header("📝 Example Questions")
        examples = [
            "What is the exchange rate for India?",
            "What currency does Japan use?",
            "EUR to USD rate",
            "Tell me about German currency",
            "Exchange rate for British Pound"
        ]
        
        for example in examples:
            if st.button(example, key=example, use_container_width=True):
                st.session_state.current_input = example
        
        st.divider()
        
        if st.button("🗑️ Clear History", use_container_width=True):
            st.session_state.conversation_history = []
            st.rerun()
    
    # Initialize agent
    with st.spinner("Initializing agent..."):
        llm_client, model, error = initialize_agent()
    
    if error:
        st.error(f"❌ Error initializing agent: {error}")
        st.info("💡 Make sure your .env file is properly configured with LLM_API_KEY")
        return
    
    # Chat interface
    st.divider()
    
    # Display conversation history
    for entry in st.session_state.conversation_history:
        with st.container():
            st.markdown(f"""
            <div class="user-message">
                <strong>🧑 You:</strong> {entry['question']}
            </div>
            """, unsafe_allow_html=True)
            
            st.markdown(f"""
            <div class="assistant-message">
                <strong>🤖 Agent:</strong> {entry['response']}
            </div>
            """, unsafe_allow_html=True)
            
            st.caption(f"⏰ {entry['timestamp']}")
            st.divider()
    
    # Input area
    col1, col2 = st.columns([5, 1])
    
    with col1:
        user_input = st.text_input(
            "Your question:",
            value=st.session_state.get('current_input', ''),
            placeholder="e.g., What is the exchange rate for India?",
            key="user_question",
            label_visibility="collapsed"
        )
    
    with col2:
        submit_button = st.button("🚀 Ask", use_container_width=True, type="primary")
    
    # Process question
    if submit_button and user_input.strip():
        # Clear the current_input from session state
        if 'current_input' in st.session_state:
            del st.session_state.current_input
        
        with st.spinner("🔄 Processing your request..."):
            try:
                # Get agent response
                response = get_agent_response(user_input, llm_client, model)
                
                # Add to conversation history
                st.session_state.conversation_history.append({
                    'question': user_input,
                    'response': response,
                    'timestamp': datetime.now().strftime("%Y-%m-%d %H:%M:%S")
                })
                
                # Rerun to display new message
                st.rerun()
                
            except Exception as e:
                st.error(f"❌ Error: {str(e)}")
    
    # Show instructions if no history
    if not st.session_state.conversation_history:
        st.info("👋 Welcome! Ask a question to get started, or choose an example from the sidebar.")


if __name__ == "__main__":
    main()
