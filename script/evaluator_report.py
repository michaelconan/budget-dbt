import sys
import duckdb


def generate_report(db_path="db/local.duckdb"):
    try:
        con = duckdb.connect(db_path, read_only=True)
    except Exception as e:
        print(f"Error connecting to database {db_path}: {e}", file=sys.stderr)
        return ""

    test_cov = None
    doc_cov = None

    try:
        test_cov = con.execute(
            "SELECT total_models, tested_models, test_coverage_pct FROM fct_test_coverage"
        ).fetchone()
    except Exception:
        pass

    try:
        doc_cov = con.execute(
            "SELECT total_models, documented_models, documentation_coverage_pct FROM fct_documentation_coverage"
        ).fetchone()
    except Exception:
        pass

    checks = [
        (
            "Modeling & Naming",
            [
                ("fct_model_naming_conventions", "Model Naming Conventions"),
                ("fct_model_directories", "Model Directories"),
                ("fct_source_directories", "Source Directories"),
                ("fct_test_directories", "Test Directories"),
            ],
        ),
        (
            "DAG & Dependencies",
            [
                ("fct_duplicate_sources", "Duplicate Sources"),
                ("fct_unused_sources", "Unused Sources"),
                ("fct_multiple_sources_joined", "Multiple Sources Joined"),
                ("fct_hard_coded_references", "Hard-coded References"),
                (
                    "fct_staging_dependent_on_staging",
                    "Staging Dependent on Staging",
                ),
                (
                    "fct_staging_dependent_on_marts_or_intermediate",
                    "Staging Dependent on Marts/Intermediate",
                ),
                (
                    "fct_marts_or_intermediate_dependent_on_source",
                    "Marts/Intermediate Dependent on Source",
                ),
                ("fct_direct_join_to_source", "Direct Join to Source"),
                ("fct_chained_views_dependencies", "Chained Views"),
                (
                    "fct_rejoining_of_upstream_concepts",
                    "Rejoining Upstream Concepts",
                ),
            ],
        ),
        (
            "Testing & Documentation",
            [
                ("fct_missing_primary_key_tests", "Missing Primary Key Tests"),
                ("fct_undocumented_models", "Undocumented Models"),
                ("fct_undocumented_sources", "Undocumented Sources"),
                ("fct_undocumented_source_tables", "Undocumented Source Tables"),
            ],
        ),
    ]

    md = []
    md.append("## 📊 dbt Project Evaluator & Coverage Report\n")
    md.append("### 📈 Coverage Overview\n")
    md.append("| Metric | Total Models | Covered Models | Coverage % |")
    md.append("|---|---|---|---|")
    if doc_cov:
        md.append(
            f"| **Documentation** | {doc_cov[0]} | {doc_cov[1]} | **{doc_cov[2]:.1f}%** |"
        )
    if test_cov:
        md.append(
            f"| **Tests** | {test_cov[0]} | {test_cov[1]} | **{test_cov[2]:.1f}%** |"
        )

    md.append("\n### 🔍 Best Practice Checks\n")
    md.append("| Category | Check | Status | Issues |")
    md.append("|---|---|---|---|")

    for category, check_list in checks:
        for table_name, display_name in check_list:
            try:
                count = con.execute(f"SELECT count(*) FROM {table_name}").fetchone()[
                    0
                ]
                if count == 0:
                    status = "✅ Pass"
                    issues = "0"
                else:
                    status = "⚠️ Warning"
                    issues = f"{count}"
            except Exception:
                status = "❓ Skipped"
                issues = "-"
            md.append(f"| {category} | {display_name} | {status} | {issues} |")

    return "\n".join(md)


if __name__ == "__main__":
    print(generate_report())
