# Data Quality Notes

This document summarizes the main data quality checks implemented in the project and the known issues identified during validation.

## Data quality approach

The project uses dbt tests to validate data quality across the staging, intermediate and mart layers.

Implemented test categories:

- Primary key checks using `unique` and `not_null`.
- Relationship checks between orders, customers, products, sellers, payments and reviews.
- Business rule checks for non-negative prices, freight values and order values.
- Review score validation to ensure scores remain between 1 and 5.
- Customer metric consistency checks.
- Delivery consistency checks.

## Known data quality warning

During validation, one warning was identified:

- 8 orders are marked as `delivered` but do not have an `order_delivered_customer_date`.

This issue was kept as a warning instead of an error because it appears to be a source data quality issue rather than a transformation error.

The raw data was not modified. The anomaly is documented and surfaced through a dbt warning test:

`assert_delivered_orders_have_delivery_date`

## Final test result

Final dbt test execution:

- 92 total tests
- 91 passed
- 1 warning
- 0 errors

This means the pipeline is valid, while still transparently reporting the known source data anomaly.
