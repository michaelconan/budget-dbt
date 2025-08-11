# Gemini CLI Workflow Integration

This document outlines how to leverage the Gemini CLI for various tasks within the `budget-dbt` project. The project is equipped with several GitHub Actions workflows that integrate with Gemini CLI to provide coding support, automation, code review, and issue triage.

## Coding Support

Developers can request assistance from Gemini CLI for any coding-related task, such as writing code, refactoring, or debugging.

**How to use:**

1.  Create a new issue or comment on an existing issue or pull request.
2.  In the comment, mention `@gemini-cli` followed by your request.

**Example:**

```
@gemini-cli How can I add a new source to the dbt project?
```

The `gemini-cli.yml` workflow will be triggered, and Gemini CLI will respond to your request in a new comment.

## Automation

The project includes automation for categorizing vendors using Gemini CLI.

### Vendor Categorization

The `categorise` command in the `Makefile` automates the process of assigning categories to new vendors.

**How to use:**

1.  Run `make categorise` from the command line.
2.  This command will:
    *   Export the `category_audit` view to `dbt/seeds/vendor_categories.csv`.
    *   Use Gemini CLI to categorize any vendors with the "TBD" category.
    *   Update the `dbt/seeds/vendor_categories.csv` file with the new categories.

## Code Review

Gemini CLI can automatically review pull requests for correctness, efficiency, maintainability, and security.

**How to use:**

1.  When a new pull request is opened, the `gemini-pr-review.yml` workflow is automatically triggered.
2.  To manually trigger a review, comment `@gemini-cli /review` on the pull request.

The review comments will be added directly to the pull request.

## Issue Triage

Gemini CLI can help triage new issues by assigning appropriate labels.

**How to use:**

1.  When a new issue is created, the `gemini-issue-automated-triage.yml` workflow is automatically triggered.
2.  To manually trigger triage for an existing issue, comment `@gemini-cli /triage` on the issue.

Gemini CLI will analyze the issue and apply relevant labels, such as `kind/bug`, `priority/high`, etc.
