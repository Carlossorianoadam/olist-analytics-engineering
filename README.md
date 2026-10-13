# End-to-End E-commerce Analytics Engineering Project

This project is an end-to-end Analytics Engineering pipeline built with real e-commerce data from the Olist Brazilian E-Commerce dataset.

The goal of the project is to simulate a modern data workflow: raw data ingestion, analytical modeling, data quality testing, documentation and dashboard-ready outputs.

## Project Objective

The objective is to build a professional portfolio project for Data Engineering, Analytics Engineering, BI Engineering and technical Data Analyst roles.

The pipeline transforms raw e-commerce data into clean, tested and business-ready analytical models that can support reporting and dashboarding in Power BI.

## Tech Stack

- Python
- DuckDB
- dbt
- SQL
- Power BI
- Git / GitHub
- WSL / Ubuntu

## Data Source

The project uses the Brazilian E-Commerce Public Dataset by Olist.

The dataset includes real anonymized e-commerce data such as:

- Orders
- Customers
- Products
- Sellers
- Payments
- Reviews
- Geolocation data

Raw data files are not included in this repository because they can be downloaded from Kaggle.

## Project Architecture

Raw CSV files  
-> Python raw loading script  
-> DuckDB raw tables  
-> dbt staging models  
-> dbt intermediate models  
-> dbt mart models  
-> dbt data quality tests  
-> Dashboard-ready CSV exports  
-> Power BI dashboard

## Project Structure

olist_analytics/
- analyses/
  - dashboard/
- assets/
- dashboard/
  - exports/
- data/
  - raw/
  - processed/
- docs/
- models/
  - staging/
  - intermediate/
  - marts/
- scripts/
- tests/
- dbt_project.yml
- requirements.txt
- README.md

## Data Pipeline

### 1. Raw Data Loading

The raw CSV files are loaded into a local DuckDB database using Python.

Script:

scripts/load_raw_olist.py

This creates raw tables such as:

- raw_orders
- raw_order_items
- raw_customers
- raw_products
- raw_sellers
- raw_order_payments
- raw_order_reviews
- raw_geolocation
- raw_product_category_translation

### 2. Staging Layer

The staging layer cleans and standardizes the raw source tables.

It includes:

- Type casting
- Column selection
- Basic renaming
- Category cleaning
- Date parsing

Main staging models:

- stg_orders
- stg_order_items
- stg_customers
- stg_products
- stg_sellers
- stg_payments
- stg_reviews
- stg_category_translation

### 3. Intermediate Layer

The intermediate layer contains business logic and joins between entities.

Main intermediate models:

- int_order_items_enriched
- int_payments_aggregated
- int_reviews_aggregated
- int_orders_enriched

This layer enriches orders with:

- Customer information
- Payment information
- Review information
- Delivery metrics
- Product and seller details

### 4. Mart Layer

The mart layer contains final business-ready analytical tables.

Final marts:

- mart_orders
- mart_order_items
- mart_product_performance
- mart_customer_metrics
- mart_seller_performance

These tables are designed to support reporting and dashboarding in Power BI.

## Data Quality

The project includes 92 dbt tests across staging, intermediate and mart layers.

The tests cover:

- Primary key checks
- Not-null checks
- Relationship checks
- Non-negative item prices
- Non-negative freight values
- Non-negative order values
- Review score validation
- Customer metric consistency
- Delivery consistency checks

Final dbt test result:

PASS=91  
WARN=1  
ERROR=0

The warning corresponds to 8 delivered orders without a customer delivery date. This was documented as a source data quality issue instead of modifying the raw data.

More details are available in:

docs/data_quality_notes.md

## Business Metrics

The project calculates business metrics such as:

- Total orders
- Delivered orders
- Canceled orders
- Total revenue
- Average order value
- Average delivery days
- Average review score
- Late delivery rate
- Revenue by month
- Revenue by product category
- Seller performance
- Customer purchase behavior
- Delivery performance by state

## Dashboard Outputs

The project generates dashboard-ready CSV exports from the final analytical models.

Exports:

- 01_executive_kpis.csv
- 02_monthly_revenue.csv
- 03_category_performance.csv
- 04_seller_performance.csv
- 05_delivery_performance_by_state.csv
- 06_payment_method_performance.csv
- 07_review_delivery_relationship.csv

These files are generated using:

scripts/export_dashboard_queries.py

## How to Run the Project

### 1. Activate the virtual environment

source ../.venv/bin/activate

### 2. Load raw data into DuckDB

python scripts/load_raw_olist.py

### 3. Run dbt models

dbt run

### 4. Run dbt tests

dbt test

### 5. Generate dbt documentation

dbt docs generate

### 6. Serve dbt documentation locally

dbt docs serve --port 8080

### 7. Export dashboard datasets

python scripts/export_dashboard_queries.py

## Current Status

Completed:

- Raw data loading into DuckDB
- dbt staging models
- dbt intermediate models
- dbt mart models
- dbt tests
- Advanced business data quality tests
- dbt documentation
- Dashboard-ready SQL exports
- Data quality documentation

Pending:

- Power BI dashboard
- Airflow orchestration
- GitHub publication
- Final README screenshots
- Architecture diagram

## Portfolio Value

This project demonstrates:

- Building an end-to-end analytics pipeline
- Working with real e-commerce data
- Loading raw data into a local analytical database
- Designing dbt staging, intermediate and mart layers
- Applying data quality tests
- Documenting known data issues
- Creating business-ready datasets for dashboarding
- Connecting technical data modeling with business analysis

