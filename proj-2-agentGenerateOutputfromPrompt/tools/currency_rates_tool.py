import requests

class CurrencyRatesTool:
    """
    Tool to fetch live currency exchange rates directly from the public API.
    """
    def __init__(self, api_url="https://open.er-api.com/v6/latest/USD"):
        """
        Initialize the CurrencyRatesTool with the public API URL.
        
        Args:
            api_url (str): URL of the currency exchange rates API.
        """
        self.api_url = api_url
    
    def _fetch_data(self):
        """
        Fetch currency rate data from the public API.
        
        Returns:
            dict: Complete API response with rates and metadata, or empty dict on error.
        """
        try:
            response = requests.get(self.api_url, timeout=10)
            response.raise_for_status()
            return response.json()
        except requests.exceptions.Timeout:
            print(f"Error: Request timed out while fetching from {self.api_url}")
            return {}
        except requests.exceptions.ConnectionError:
            print(f"Error: Could not connect to API at {self.api_url}")
            print("Please check your internet connection.")
            return {}
        except requests.exceptions.HTTPError as e:
            print(f"HTTP Error: {e}")
            return {}
        except Exception as e:
            print(f"Error fetching currency rates: {e}")
            return {}
    
    def get_all_rates(self):
        """
        Get all currency exchange rate data including metadata.
        
        Returns:
            dict: Complete response with base currency, rates, timestamp, etc.
                  Example: {'result': 'success', 'base_code': 'USD', 'rates': {...}}
        """
        return self._fetch_data()
    
    def get_rates_only(self):
        """
        Get only the rates dictionary without metadata.
        
        Returns:
            dict: Dictionary of currency codes and their exchange rates relative to base.
                  Example: {'USD': 1.0, 'EUR': 0.85, 'INR': 83.12, ...}
        """
        data = self._fetch_data()
        return data.get("rates", {})
    
    def get_base_currency(self):
        """
        Get the base currency for the exchange rates.
        
        Returns:
            str: Base currency code (e.g., 'USD').
        """
        data = self._fetch_data()
        return data.get("base_code", "Unknown")
    
    def get_rate(self, currency_code):
        """
        Get exchange rate for a specific currency.
        
        Args:
            currency_code (str): The currency code (e.g., 'EUR', 'INR', 'GBP').
        
        Returns:
            dict: Dictionary with currency, rate, and base information.
                  Returns empty dict if currency not found.
        """
        data = self._fetch_data()
        if not data:
            return {}
        
        rates = data.get("rates", {})
        currency_upper = currency_code.upper()
        
        if currency_upper in rates:
            return {
                "currency": currency_upper,
                "rate": rates[currency_upper],
                "base": data.get("base_code", "Unknown"),
                "timestamp": data.get("time_last_update_utc", "Unknown")
            }
        else:
            print(f"Currency '{currency_code}' not found in available rates")
            return {}
    
    def get_multiple_rates(self, currency_codes):
        """
        Get exchange rates for multiple currencies.
        
        Args:
            currency_codes (list): List of currency codes (e.g., ['EUR', 'INR', 'GBP']).
        
        Returns:
            dict: Dictionary mapping currency codes to their rate information.
                  Example: {'EUR': {'currency': 'EUR', 'rate': 0.85, ...}, ...}
        """
        results = {}
        data = self._fetch_data()
        
        if not data:
            return results
        
        rates = data.get("rates", {})
        base = data.get("base_code", "Unknown")
        timestamp = data.get("time_last_update_utc", "Unknown")
        
        for code in currency_codes:
            currency_upper = code.upper()
            if currency_upper in rates:
                results[currency_upper] = {
                    "currency": currency_upper,
                    "rate": rates[currency_upper],
                    "base": base,
                    "timestamp": timestamp
                }
            else:
                print(f"Warning: Currency '{code}' not found")
        
        return results
    
    def get_available_currencies(self):
        """
        Get list of all available currency codes.
        
        Returns:
            list: List of currency codes available in the API.
        """
        rates = self.get_rates_only()
        return list(rates.keys())
    
    def convert(self, amount, from_currency, to_currency):
        """
        Convert amount from one currency to another.
        
        Args:
            amount (float): Amount to convert.
            from_currency (str): Source currency code.
            to_currency (str): Target currency code.
        
        Returns:
            dict: Conversion result with details, or empty dict on error.
        """
        rates = self.get_rates_only()
        
        if not rates:
            return {}
        
        from_curr = from_currency.upper()
        to_curr = to_currency.upper()
        
        if from_curr not in rates or to_curr not in rates:
            print(f"Error: One or both currencies not found ({from_curr}, {to_curr})")
            return {}
        
        # Convert to base currency first, then to target currency
        # Since base is USD, rates are already in USD
        base_amount = amount / rates[from_curr]
        converted_amount = base_amount * rates[to_curr]
        
        return {
            "original_amount": amount,
            "from_currency": from_curr,
            "to_currency": to_curr,
            "converted_amount": round(converted_amount, 2),
            "exchange_rate": round(rates[to_curr] / rates[from_curr], 6),
            "base_currency": self.get_base_currency()
        }


if __name__ == "__main__":
    # Example usage - fetches live currency rates
    tool = CurrencyRatesTool()
    
    print("=== Testing CurrencyRatesTool ===")
    
    print("\n1. Get base currency:")
    base = tool.get_base_currency()
    print(f"Base currency: {base}")
    
    print("\n2. Get all rates (first 5):")
    rates = tool.get_rates_only()
    print(f"Total currencies available: {len(rates)}")
    for i, (code, rate) in enumerate(list(rates.items())[:5]):
        print(f"  {code}: {rate}")
    
    print("\n3. Get specific rate for EUR:")
    eur_rate = tool.get_rate("EUR")
    print(eur_rate)
    
    print("\n4. Get multiple rates:")
    multiple = tool.get_multiple_rates(["INR", "GBP", "JPY"])
    for code, data in multiple.items():
        print(f"  {code}: {data.get('rate')}")
    
    print("\n5. Convert 100 USD to EUR:")
    conversion = tool.convert(100, "USD", "EUR")
    if conversion:
        print(f"  {conversion['original_amount']} {conversion['from_currency']} = {conversion['converted_amount']} {conversion['to_currency']}")
    
    print("\n6. Get available currencies (first 10):")
    currencies = tool.get_available_currencies()
    print(currencies[:10])
