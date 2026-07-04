# Manual Review and Cleanup

While much of the categorization is automated, some transactions require manual review to ensure accuracy.

## Category Audit

The `category_audit` model identifies transactions that have not been automatically categorized.

## Categorization Workflow

1.  **Export TBD Vendors**:
    Run `make dump-vendors` to export the list of uncategorized vendors to a CSV seed file.
2.  **Automated Categorization (Gemini)**:
    Run `make categorise` to use the Gemini AI to suggest categories for the TBD entries in the seed file.
3.  **Manual Review**:
    Review the `dbt/seeds/vendor_category_mapping.csv` file and make any necessary manual adjustments.
4.  **Rebuild**:
    Run `make refresh` to reload the seeds and rebuild the dbt models with the new mappings.
