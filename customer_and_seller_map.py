import plotly
import plotly.express as px
import pandas as pd
import plotly.graph_objects as go
import requests
from pathlib import Path

geojson_url = "https://raw.githubusercontent.com/giuliano-macedo/geodata-br-states/main/geojson/br_states.json"
response = requests.get(geojson_url)

print("Status:", response.status_code)   # Should be 200
print("Type:", response.headers.get("Content-Type"))  # application/json
brazil_geojson = response.json()
print("First feature properties:", brazil_geojson['features'][0]['properties'])

df_customer = pd.read_csv('data/queried_data/Customer_Location_parallels.csv')
df_seller = pd.read_csv('data/queried_data/Seller_Location_parallels.csv')
customer_state_data = df_customer.groupby('customer_state')['total_unique_customers'].sum().reset_index()
seller_state_data = df_seller.groupby('seller_state')['total_sellers'].sum().reset_index()

fig_customers = px.choropleth(
    customer_state_data, 
    geojson=brazil_geojson,
    locations = 'customer_state',
    featureidkey='properties.SIGLA',
    color = 'total_unique_customers',
    color_continuous_scale='Blues',
    scope='south america',
    labels={'total_unique_customers': 'Total Unique Customers'}
)

fig_sellers = fig = px.choropleth(
    seller_state_data, 
    geojson=brazil_geojson,
    locations = 'seller_state',
    featureidkey='properties.SIGLA',
    color = 'total_sellers',
    color_continuous_scale='Blues',
    scope='south america',
    labels={'total_sellers': 'Total Unique Sellers'}
)
out_dir = Path("img")
out_dir.mkdir(exist_ok=True)

fig_customers.write_html(out_dir / "customers_state.html")
fig_sellers.write_html(out_dir / "sellers_state.html")