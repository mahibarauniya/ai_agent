import requests

class CustomerAgent:
    """
    Agent to fetch customer data from the local FastAPI endpoint.
    """
    def __init__(self, base_url="http://127.0.0.1:5000"):
        self.base_url = base_url

    def get_customers(self, query_params=None, output_filename=None):
        """
        Fetch customer data using any query parameters.
        Save the result to a file in the output folder if output_filename is provided.
        Supports JSON and CSV output based on file extension.
        Args:
            query_params (dict): Query parameters for filtering (optional).
            output_filename (str): Name of the output file (optional).
        Returns:
            list: List of customer records (dict).
        """
        import os
        import json
        import csv
        params = query_params or {}
        response = requests.get(f"{self.base_url}/", params=params)
        response.raise_for_status()
        data = response.json()
        if output_filename:
            output_dir = os.path.join(os.path.dirname(__file__), "output")
            os.makedirs(output_dir, exist_ok=True)
            output_path = os.path.join(output_dir, output_filename)
            ext = os.path.splitext(output_filename)[1].lower()
            if ext == ".csv":
                if data and isinstance(data, list):
                    with open(output_path, "w", newline="", encoding="utf-8") as f:
                        writer = csv.DictWriter(f, fieldnames=data[0].keys())
                        writer.writeheader()
                        writer.writerows(data)
                print(f"Data saved to {output_path} (CSV)")
            else:
                with open(output_path, "w", encoding="utf-8") as f:
                    json.dump(data, f, ensure_ascii=False, indent=2)
                print(f"Data saved to {output_path} (JSON)")
        return data

if __name__ == "__main__":
    import argparse
    import json
    parser = argparse.ArgumentParser(description="Fetch customer data from FastAPI endpoint.")
    parser.add_argument("--output_filename", type=str, help="Output filename (JSON)", default="all_customers.json")
    parser.add_argument("--params", type=str, help="Query parameters as JSON string, e.g. '{\"country\": \"India\", \"city\": \"Delhi\"}'", default="{}")
    args = parser.parse_args()

    try:
        query_params = json.loads(args.params)
    except Exception as e:
        print("Invalid JSON for --params:", e)
        query_params = {}

    agent = CustomerAgent()
    customers = agent.get_customers(query_params=query_params, output_filename=args.output_filename)
    print(f"Total customers: {len(customers)}")
    print("Sample:", customers[:3])
