from fastapi import FastAPI, Query
import pandas as pd
import asyncio
import os

app = FastAPI(title="Local Country Currency API")

# Load CSV once when server starts
csv_path = os.path.join(os.path.dirname(os.path.dirname(__file__)), "data", "country_currency.csv")
df_country_currency = pd.read_csv(csv_path)

@app.get("/")
async def get_country_currency(
    column: str | None = Query(None, description="Column name to filter"),
    value: str | None = Query(None, description="Value to filter by")
):
    """
    Returns all country currency data, or filtered by column=value.
    Example: /?column=country_name&value=India
    Example: /?column=currency_code&value=USD
    """
    await asyncio.sleep(0)  # async placeholder, non-blocking
    
    if column and value:
        if column not in df_country_currency.columns:
            return {"error": f"Column '{column}' does not exist"}
        filtered = df_country_currency[df_country_currency[column] == value]
        return filtered.to_dict(orient="records")
    
    return df_country_currency.to_dict(orient="records")


# To run this API:
# conda activate mahi_venv
# python -m uvicorn api.country_currency:app --reload --port 5003
# Check on browser: http://127.0.0.1:5003/
# API docs: http://127.0.0.1:5003/docs

# Tool for this API is available at:
# from tools.country_currency_tool import CountryCurrencyTool
# tool = CountryCurrencyTool()
# all_data = tool.get_all_country_currencies()
# india_currency = tool.get_by_country_name("India")
# usd_countries = tool.get_by_currency_code("USD")
