import streamlit as st
import pandas as pd
import duckdb

# --- Database Connection ---
@st.cache_resource
def get_db_connection():
    """Returns a connection to the DuckDB database."""
    return duckdb.connect(database='db/local.duckdb', read_only=True)

@st.cache_data
def load_transactions(_conn):
    """Loads transactions from the database."""
    return _conn.execute("SELECT * FROM transactions").fetchdf()

# --- App Layout ---
st.set_page_config(layout="wide")
st.title("Budget Review Dashboard")

# --- Load Data ---
conn = get_db_connection()
transactions_df = load_transactions(conn)

# Convert date column to datetime
transactions_df['date'] = pd.to_datetime(transactions_df['date'])

# --- Sidebar Slicers ---
st.sidebar.header("Filters")

# Date range slicer
min_date = transactions_df['date'].min().date()
max_date = transactions_df['date'].max().date()
start_date, end_date = st.sidebar.date_input(
    "Select Date Range",
    value=(min_date, max_date),
    min_value=min_date,
    max_value=max_date,
)

# Account slicer
all_accounts = transactions_df['account'].unique()
selected_accounts = st.sidebar.multiselect(
    "Select Accounts",
    options=all_accounts,
    default=all_accounts,
)

# Category slicer
all_categories = transactions_df['category'].unique()
selected_categories = st.sidebar.multiselect(
    "Select Categories",
    options=all_categories,
    default=all_categories,
)

# --- Filter Data ---
filtered_df = transactions_df[
    (transactions_df['date'].dt.date >= start_date) &
    (transactions_df['date'].dt.date <= end_date) &
    (transactions_df['account'].isin(selected_accounts)) &
    (transactions_df['category'].isin(selected_categories))
]

# --- Main Page Visuals ---

# Inflows vs Outflows
st.header("Inflows vs. Outflows")
inflows = filtered_df[filtered_df['amount_usd'] > 0]['amount_usd'].sum()
outflows = filtered_df[filtered_df['amount_usd'] < 0]['amount_usd'].sum()

col1, col2, col3 = st.columns(3)
col1.metric("Total Inflows", f"${inflows:,.2f}")
col2.metric("Total Outflows", f"${outflows:,.2f}")
col3.metric("Net Flow", f"${inflows + outflows:,.2f}")

# Summary by Category
st.header("Summary by Category")
category_summary = filtered_df.groupby('category')['amount_usd'].sum().sort_values()
st.bar_chart(category_summary)

# Period Comparison (Placeholder - needs more complex logic)
st.header("Period Comparison")
st.write("This section will be implemented in a future version.")

# Display Raw Data
st.header("Raw Data")
st.dataframe(filtered_df)
