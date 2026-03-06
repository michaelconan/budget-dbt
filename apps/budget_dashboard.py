import streamlit as st
import pandas as pd
import duckdb
import altair as alt

# --- Database Connection ---
@st.cache_resource
def get_db_connection(db_path):
    """Returns a connection to the DuckDB database."""
    return duckdb.connect(database=db_path, read_only=True)

@st.cache_data
def load_transactions(_conn):
    """Loads transactions from the database."""
    return _conn.execute("SELECT * FROM transactions").fetchdf()

# --- App Layout ---
st.set_page_config(layout="wide")
st.title("Budget Review Dashboard")

# --- Load Data ---
# Allow dynamic DB path via query param, e.g., ?db=etl
db_name = st.query_params.get('db', 'etl')
db_path = f'db/{db_name}.duckdb'
try:
    conn = get_db_connection(db_path)
    transactions_df = load_transactions(conn)
except Exception as e:
    st.error(f"Failed to connect or load data from database at '{db_path}'. Please ensure the path is correct and the database file exists. Error: {e}")
    st.stop()

if transactions_df.empty:
    st.warning("No transactions found in the database.")
    st.stop()

# Convert date column to datetime
transactions_df['transaction_date'] = pd.to_datetime(transactions_df['transaction_date'])

# --- Sidebar Slicers ---
st.sidebar.header("Filters")

# Month slicer
transactions_df['month_year'] = transactions_df['transaction_date'].dt.to_period('M').astype(str)
all_months = sorted(transactions_df['month_year'].unique(), reverse=True)
m1, m2 = st.sidebar.columns(2)
with m1:
    if st.button("Select all", key="months_select_all"):
        st.session_state["filter_months"] = list(all_months)
with m2:
    if st.button("Deselect all", key="months_deselect_all"):
        st.session_state["filter_months"] = []
selected_months = st.sidebar.multiselect(
    "Select Months to Include",
    options=all_months,
    default=st.session_state.get("filter_months", all_months[:3]),
)
st.session_state["filter_months"] = selected_months

# Account slicer (mart uses account_name)
all_accounts = sorted(transactions_df['account_name'].dropna().unique())
a1, a2 = st.sidebar.columns(2)
with a1:
    if st.button("Select all", key="accounts_select_all"):
        st.session_state["filter_accounts"] = list(all_accounts)
with a2:
    if st.button("Deselect all", key="accounts_deselect_all"):
        st.session_state["filter_accounts"] = []
selected_accounts = st.sidebar.multiselect(
    "Select Accounts",
    options=all_accounts,
    default=st.session_state.get("filter_accounts", all_accounts),
)
st.session_state["filter_accounts"] = selected_accounts

# Category slicer
all_categories = sorted(transactions_df['category'].dropna().unique())
c1, c2 = st.sidebar.columns(2)
with c1:
    if st.button("Select all", key="categories_select_all"):
        st.session_state["filter_categories"] = list(all_categories)
with c2:
    if st.button("Deselect all", key="categories_deselect_all"):
        st.session_state["filter_categories"] = []
selected_categories = st.sidebar.multiselect(
    "Select Categories",
    options=all_categories,
    default=st.session_state.get("filter_categories", all_categories),
)
st.session_state["filter_categories"] = selected_categories

# --- Filter Data ---
if not selected_months:
    st.warning("Please select at least one month.")
    st.stop()

filtered_df = transactions_df[
    (transactions_df['month_year'].isin(selected_months)) &
    (transactions_df['account_name'].isin(selected_accounts)) &
    (transactions_df['category'].isin(selected_categories))
]

if filtered_df.empty:
    st.warning("No data available for the selected filters.")
    st.stop()

# --- Main Page Visuals ---

# Inflows vs Outflows
st.header("Inflows vs. Outflows")
inflows = filtered_df[filtered_df['amount_usd'] > 0]['amount_usd'].sum()
outflows = filtered_df[filtered_df['amount_usd'] < 0]['amount_usd'].sum()

col1, col2, col3 = st.columns(3)
col1.metric("Total Inflows", f"${inflows:,.2f}")
col2.metric("Total Outflows", f"${outflows:,.2f}")
col3.metric("Net Flow", f"${inflows + outflows:,.2f}")

# Summary by Category (sorted by total amount, largest first)
st.header("Summary by Category")
category_summary = (
    filtered_df.groupby('category', as_index=False)['amount_usd']
    .sum()
    .sort_values('amount_usd', ascending=False)
)
chart = (
    alt.Chart(category_summary)
    .mark_bar()
    .encode(
        x="amount_usd:Q",
        y=alt.Y("category:N", sort="-x"),  # sort by amount descending
    )
)
st.altair_chart(chart, use_container_width=True)

# Period Comparison
st.header("Period Comparison")
period_type = st.selectbox("Compare by", ["Month", "Quarter", "Year"])

# Ensure dataframe is sorted by date for correct period calculation
df_for_comparison = filtered_df.sort_values('transaction_date').copy()

if period_type == 'Month':
    df_for_comparison['period'] = df_for_comparison['transaction_date'].dt.to_period('M')
elif period_type == 'Quarter':
    df_for_comparison['period'] = df_for_comparison['transaction_date'].dt.to_period('Q')
else:  # Year
    df_for_comparison['period'] = df_for_comparison['transaction_date'].dt.to_period('Y')

# Get the latest period with data from the *filtered* df
latest_period = df_for_comparison['period'].max()
previous_period = latest_period - 1

# Calculate amounts for current and previous periods
current_period_amount = df_for_comparison[df_for_comparison['period'] == latest_period]['amount_usd'].sum()
previous_period_amount = df_for_comparison[df_for_comparison['period'] == previous_period]['amount_usd'].sum()

# Calculate delta
delta = "N/A"
if previous_period_amount != 0:
    delta_val = ((current_period_amount - previous_period_amount) / abs(previous_period_amount)) * 100
    delta = f"{delta_val:.2f}%"
elif current_period_amount != 0:
    delta = "New" # If there's current data but no previous

col1, col2 = st.columns(2)
col1.metric(f"Total for {latest_period}", f"${current_period_amount:,.2f}", delta=delta)
col2.metric(f"Total for {previous_period}", f"${previous_period_amount:,.2f}")

# Display Raw Data
st.header("Raw Data")
st.dataframe(filtered_df)
