from fastapi import FastAPI, Query
import pandas as pd
import asyncio
import os

app = FastAPI(title="Local Country API")

# Load CSV once when server starts
csv_path = os.path.join(os.path.dirname(os.path.dirname(__file__)), "data", "countries.csv")
df_countries = pd.read_csv(csv_path)

@app.get("/")
async def get_countries(
    column: str | None = Query(None, description="Column name to filter"),
    value: str | None = Query(None, description="Value to filter by")
):
    """
    Returns all countries, or filtered by column=value.
    Example: /?column=country_code&value=US
    Example: /?column=country_name&value=India
    """
    await asyncio.sleep(0)  # async placeholder, non-blocking
    
    if column and value:
        if column not in df_countries.columns:
            return {"error": f"Column '{column}' does not exist"}
        filtered = df_countries[df_countries[column] == value]
        return filtered.to_dict(orient="records")
    
    return df_countries.to_dict(orient="records")


# ============================================
# Tool to interact with the Countries API
# ============================================

import requests

class CountriesTool:
    """
    Tool to query country data from the local FastAPI endpoint.
    """
    def __init__(self, base_url="http://127.0.0.1:5002"):
        """
        Initialize the CountriesTool with the API endpoint URL.
        
        Args:
            base_url (str): Base URL of the country API endpoint.
        """
        self.base_url = base_url
    
    def _fetch_countries(self, query_params=None):
        """
        Fetch countries from the API.
        
        Args:
            query_params (dict): Query parameters for filtering (optional).
        
        Returns:
            list: List of dictionaries containing country data or error dict.
        """
        try:
            params = query_params or {}
            response = requests.get(f"{self.base_url}/", params=params)
            response.raise_for_status()
            data = response.json()
            
            # Handle error responses
            if isinstance(data, dict) and 'error' in data:
                print(f"API Error: {data['error']}")
                return []
            
            return data
        except requests.exceptions.ConnectionError:
            print(f"Error: Could not connect to API at {self.base_url}")
            print("Make sure the API is running: python -m uvicorn api.countries:app --reload --port 5002")
            return []
        except Exception as e:
            print(f"Error fetching countries: {e}")
            return []
    
    def get_all_countries(self):
        """
        Get all countries.
        
        Returns:
            list: List of all country records.
        """
        return self._fetch_countries()
    
    def get_country_by_column(self, column, value):
        """
        Get countries filtered by a specific column value.
        
        Args:
            column (str): Column name to filter by (e.g., 'country_code', 'country_name').
            value (str): Value to filter by.
        
        Returns:
            list: List of matching countries.
        """
        return self._fetch_countries(query_params={"column": column, "value": value})
    
    def get_country_by_code(self, country_code):
        """
        Get country information by country code.
        
        Args:
            country_code (str): The country code (e.g., 'US', 'IN').
        
        Returns:
            list: List containing the country if found.
        """
        return self.get_country_by_column("country_code", country_code)
    
    def get_country_by_name(self, country_name):
        """
        Get country information by country name.
        
        Args:
            country_name (str): The country name (e.g., 'India', 'United States').
        
        Returns:
            list: List containing the country if found.
        """
        return self.get_country_by_column("country_name", country_name)


# To run this API:
# conda activate mahi_venv
# python -m uvicorn api.countries:app --reload --port 5002
# Check on browser: http://127.0.0.1:5002/
# API docs: http://127.0.0.1:5002/docs

# Example usage of the tool:
# from api.countries import CountriesTool
# tool = CountriesTool()
# all_countries = tool.get_all_countries()
# india = tool.get_country_by_name("India")
