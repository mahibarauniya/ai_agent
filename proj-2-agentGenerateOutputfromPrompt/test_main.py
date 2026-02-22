"""
Test script for main.py
This simulates running main.py with a test question
"""

import os
import json
from datetime import datetime
from agent.agent import load_config, create_llm_client, run_agent_conversation
from main import save_result_to_file

def test_agent():
    """Test the agent with a sample question."""
    
    print("\n" + "="*70)
    print("🧪 Testing AI Agent Application")
    print("="*70)
    
    # Load configuration
    print("\n📋 Step 1: Loading configuration...")
    api_key, model = load_config()
    print(f"✓ Model: {model}")
    
    # Create LLM client
    print("\n📋 Step 2: Creating LLM client...")
    llm_client = create_llm_client(api_key)
    print("✓ LLM client ready")
    
    # Test question
    test_question = "What is the capital of France?"
    print(f"\n📋 Step 3: Processing test question...")
    print(f"Question: {test_question}")
    
    # Run agent (without tools for now)
    tools = []
    result = run_agent_conversation(llm_client, model, tools, test_question)
    
    # Save result
    print(f"\n📋 Step 4: Saving result...")
    output_file = save_result_to_file(test_question, result)
    
    print("\n" + "="*70)
    print("✅ Test completed successfully!")
    print("="*70)
    print(f"\nResult: {result}")
    print(f"Saved to: {output_file}")
    
    return True

if __name__ == "__main__":
    try:
        test_agent()
    except Exception as e:
        print(f"\n❌ Test failed: {str(e)}")
        import traceback
        traceback.print_exc()
