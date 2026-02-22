import requests

class CountryCurrencyTool:
    """
    Tool to query country currency data from the local FastAPI endpoint.
    """
    def __init__(self, base_url="http://127.0.0.1:5003"):
        """
        Initialize the CountryCurrencyTool with the API endpoint URL.
        
        Args:
            base_url (str): Base URL of the country currency API endpoint.
        """
        self.base_url = base_url
    
    def _fetch_data(self, query_params=None):
        """
        Fetch country currency data from the API.
        
        Args:
            query_params (dict): Query parameters for filtering (optional).
        
        Returns:
            list: List of dictionaries containing country currency data or error dict.
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
            print("Make sure the API is running: python -m uvicorn api.country_currency:app --reload --port 5003")
            return []
        except Exception as e:
            print(f"Error fetching data: {e}")
            return []
    
    def get_all_country_currencies(self):
        """
        Get all country currency data.
        
        Returns:
            list: List of all country currency records.
        """
        return self._fetch_data()
    
    def get_by_column(self, column, value):
        """
        Get country currency data filtered by a specific column value.
        
        Args:
            column (str): Column name to filter by (e.g., 'country_name', 'currency_code').
            value (str): Value to filter by.
        
        Returns:
            list: List of matching records.
        """
        return self._fetch_data(query_params={"column": column, "value": value})
    
    def get_by_country_name(self, country_name):
        """
        Get currency information by country name.
        
        Args:
            country_name (str): The country name (e.g., 'India', 'United States').
        
        Returns:
            list: List containing the currency data if found.
        """
        return self.get_by_column("country_name", country_name)
    
    def get_by_currency_code(self, currency_code):
        """
        Get country information by currency code.
        
        Args:
            currency_code (str): The currency code (e.g., 'USD', 'INR').
        
        Returns:
            list: List containing countries using this currency.
        """
        return self.get_by_column("currency_code", currency_code)
    
    def get_by_currency_name(self, currency_name):
        """
        Get country information by currency name.
        
        Args:
            currency_name (str): The currency name (e.g., 'US Dollar', 'Indian Rupee').
        
        Returns:
            list: List containing countries using this currency.
        """
        return self.get_by_column("currency_name", currency_name)


if __name__ == "__main__":
    # Example usage - works with country currency data
    tool = CountryCurrencyTool()
    
    print("=== Testing CountryCurrencyTool ===")
    
    print("\n1. Get all country currencies:")
    all_data = tool.get_all_country_currencies()
    print(f"Total records: {len(all_data)}")
    for item in all_data[:3]:
        print(f"  {item.get('country_name')}: {item.get('currency_name')} ({item.get('currency_code')})")
    
    print("\n2. Get currency for India:")
    india = tool.get_by_country_name("India")
    print(india)
    
    print("\n3. Get countries using USD:")
    usd_countries = tool.get_by_currency_code("USD")
    print(usd_countries)
    
    print("\n4. Get countries using Euro:")
    euro_countries = tool.get_by_currency_name("Euro")
    print(euro_countries)
