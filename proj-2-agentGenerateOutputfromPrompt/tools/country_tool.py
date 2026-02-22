import requests

class CountryTool:
    """
    Tool to query country data from the local FastAPI endpoint.
    """
    def __init__(self, base_url="http://127.0.0.1:5002"):
        """
        Initialize the CountryTool with the API endpoint URL.
        
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
            list: List of dictionaries containing country data.
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
            print("Make sure the API is running: python -m uvicorn create_localendpoint_for_countries:app --reload --port 5002")
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
        return self.countries
    
    def get_country_by_code(self, country_code):
        """
        Get country information by country code.
        
        Args:
            country_code (str): The country code (e.g., 'US', 'IN').
        
        Returns:
            dict or None: Country information if found, None otherwise.
        """
        country_code = country_code.upper()
        for country in self.countries:
            if country.get('country_code', '').upper() == country_code:
                return country
        return None
    
    def get_country_by_name(self, country_name):
        """
        Get country information by country name (case-insensitive partial match).
        
        Args:
            country_name (str): The country name or partial name.
        
        Returns:
            list: List of matching countries.
        """
        country_name = country_name.lower()
        matches = []
        for country in self.countries:
            if country_name in country.get('country_name', '').lower():
                matches.append(country)
        return matches
    
    def get_country_codes(self):
        """
        Get all country codes.
        
        Returns:
            list: List of country codes.
        """
        return [country.get('country_code') for country in self.countries]
    
    def get_country_names(self):
        """
        Get all country names.
        
        Returns:
            list: List of country names.
        """
        return [country.get('country_name') for country in self.countries]


if __name__ == "__main__":
    # Example usage - works with any countries in the CSV file
    tool = CountryTool()
    
    print("\n=== All Countries ===")
    all_countries = tool.get_all_countries()
    for country in all_countries:
        print(f"{country['country_code']}: {country['country_name']}")
    
    # Demo with first country (if available)
    if all_countries:
        first_country = all_countries[0]
        first_code = first_country['country_code']
        first_name = first_country['country_name']
        
        print(f"\n=== Get Country by Code ({first_code}) ===")
        result = tool.get_country_by_code(first_code)
        print(result)
        
        print(f"\n=== Search by Name ({first_name}) ===")
        result = tool.get_country_by_name(first_name)
        print(result)
    
    print("\n=== Get All Country Codes ===")
    codes = tool.get_country_codes()
    print(codes)
    
    print("\n=== Get All Country Names ===")
    names = tool.get_country_names()
    print(names)
