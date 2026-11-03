# Data Quality Notes

This document summarizes the data quality checks implemented in the project and the source-data issues identified during validation.

## Data quality approach

The project uses dbt tests across the staging, intermediate and mart layers.

Implemented checks include:

- Primary-key checks using `unique` and `not_null`.
- Relationship checks between orders, customers, products, sellers, payments and reviews.
- Business-rule checks for non-negative prices, freight values and order values.
- Review-score validation to ensure scores remain between 1 and 5.
- Customer metric consistency checks.
- Delivery consistency checks.

## Known data quality warning

The latest recorded dbt test run reported one warning:

- 8 orders are marked as `delivered` but do not have an `order_delivered_customer_date`.

This is treated as a source-data quality issue rather than a transformation error. The raw data is not modified to hide the anomaly.

The warning is surfaced through the dbt test:

`assert_delivered_orders_have_delivery_date`

## Latest recorded test result

- 97 total tests
- 96 passed
- 1 warning
- 0 errors

The warning is documented and visible rather than silently ignored. The test results describe the recorded project run; they may change if the source data or models are updated.
