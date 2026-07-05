
{% docs __overview__ %}

# budget-dbt

Welcome to the dbt documentation for the budget tracking project.

## Project Scope
This dbt project processes financial transactions from multiple sources (Bank of America, Revolut) into a unified format for personal budgeting and analysis.

## Core Models
- **`transactions`**: The central mart containing all processed transactions.
- **`category_audit`**: A utility model to help identify and categorize new vendors.

## Useful Links
- [Project Wiki](../index.html)
- [Streamlit Dashboard](http://localhost:8501) (when running locally)

For more detailed information on the loading process and business logic, please refer to the [Wiki](../index.html).

{% enddocs %}
