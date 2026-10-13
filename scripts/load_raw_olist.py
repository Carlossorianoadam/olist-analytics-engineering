from pathlib import Path
import duckdb


RAW_DATA_DIR = Path("data/raw")
DB_PATH = "olist_analytics.duckdb"


CSV_TABLES = {
    "olist_customers_dataset.csv": "raw_customers",
    "olist_geolocation_dataset.csv": "raw_geolocation",
    "olist_order_items_dataset.csv": "raw_order_items",
    "olist_order_payments_dataset.csv": "raw_order_payments",
    "olist_order_reviews_dataset.csv": "raw_order_reviews",
    "olist_orders_dataset.csv": "raw_orders",
    "olist_products_dataset.csv": "raw_products",
    "olist_sellers_dataset.csv": "raw_sellers",
    "product_category_name_translation.csv": "raw_product_category_translation",
}


def load_csv_to_duckdb(connection, csv_file: str, table_name: str) -> None:
    csv_path = RAW_DATA_DIR / csv_file

    if not csv_path.exists():
        raise FileNotFoundError(f"Missing file: {csv_path}")

    print(f"Loading {csv_file} into {table_name}...")

    connection.execute(
        f"""
        create or replace table {table_name} as
        select *
        from read_csv_auto(
            '{csv_path}',
            header=true,
            all_varchar=true
        )
        """
    )

    row_count = connection.execute(
        f"select count(*) from {table_name}"
    ).fetchone()[0]

    print(f"Loaded {row_count:,} rows into {table_name}")


def main() -> None:
    print(f"Creating DuckDB database: {DB_PATH}")

    connection = duckdb.connect(DB_PATH)

    for csv_file, table_name in CSV_TABLES.items():
        load_csv_to_duckdb(connection, csv_file, table_name)

    print("\nRaw loading completed successfully.")
    print("\nAvailable tables:")

    tables = connection.execute("show tables").fetchall()
    for table in tables:
        print(f"- {table[0]}")

    connection.close()


if __name__ == "__main__":
    main()
