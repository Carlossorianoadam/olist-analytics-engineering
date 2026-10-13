import duckdb

DB_PATH = "olist_analytics.duckdb"


def print_section(title: str) -> None:
    print("\n" + "=" * 80)
    print(title)
    print("=" * 80)


def main() -> None:
    con = duckdb.connect(DB_PATH)

    print_section("1. Available tables")
    print(con.execute("show tables").fetchdf())

    print_section("2. Row counts")
    tables = [
        "raw_customers",
        "raw_geolocation",
        "raw_order_items",
        "raw_order_payments",
        "raw_order_reviews",
        "raw_orders",
        "raw_products",
        "raw_sellers",
        "raw_product_category_translation",
    ]

    for table in tables:
        count = con.execute(f"select count(*) from {table}").fetchone()[0]
        print(f"{table}: {count:,} rows")

    print_section("3. Order status distribution")
    print(
        con.execute(
            """
            select
                order_status,
                count(*) as orders
            from raw_orders
            group by order_status
            order by orders desc
            """
        ).fetchdf()
    )

    print_section("4. Order date range")
    print(
        con.execute(
            """
            select
                min(try_cast(order_purchase_timestamp as timestamp)) as first_order_date,
                max(try_cast(order_purchase_timestamp as timestamp)) as last_order_date
            from raw_orders
            """
        ).fetchdf()
    )

    print_section("5. Key null checks")
    null_checks = {
        "raw_orders": ["order_id", "customer_id", "order_status", "order_purchase_timestamp"],
        "raw_order_items": ["order_id", "order_item_id", "product_id", "seller_id", "price", "freight_value"],
        "raw_customers": ["customer_id", "customer_unique_id", "customer_zip_code_prefix"],
        "raw_products": ["product_id", "product_category_name"],
        "raw_sellers": ["seller_id", "seller_zip_code_prefix"],
        "raw_order_payments": ["order_id", "payment_type", "payment_value"],
        "raw_order_reviews": ["review_id", "order_id", "review_score"],
    }

    for table, columns in null_checks.items():
        print(f"\n{table}")
        for column in columns:
            null_count = con.execute(
                f"""
                select count(*)
                from {table}
                where {column} is null or trim({column}) = ''
                """
            ).fetchone()[0]
            print(f"  {column}: {null_count:,} null/empty values")

    print_section("6. Duplicate key checks")
    duplicate_checks = {
        "raw_orders": "order_id",
        "raw_customers": "customer_id",
        "raw_products": "product_id",
        "raw_sellers": "seller_id",
    }

    for table, key in duplicate_checks.items():
        duplicate_count = con.execute(
            f"""
            select count(*)
            from (
                select {key}
                from {table}
                group by {key}
                having count(*) > 1
            )
            """
        ).fetchone()[0]
        print(f"{table}.{key}: {duplicate_count:,} duplicated keys")

    print_section("7. Relationship checks")
    checks = {
        "order_items_without_order": """
            select count(*)
            from raw_order_items oi
            left join raw_orders o on oi.order_id = o.order_id
            where o.order_id is null
        """,
        "payments_without_order": """
            select count(*)
            from raw_order_payments p
            left join raw_orders o on p.order_id = o.order_id
            where o.order_id is null
        """,
        "reviews_without_order": """
            select count(*)
            from raw_order_reviews r
            left join raw_orders o on r.order_id = o.order_id
            where o.order_id is null
        """,
        "orders_without_customer": """
            select count(*)
            from raw_orders o
            left join raw_customers c on o.customer_id = c.customer_id
            where c.customer_id is null
        """,
        "order_items_without_product": """
            select count(*)
            from raw_order_items oi
            left join raw_products p on oi.product_id = p.product_id
            where p.product_id is null
        """,
        "order_items_without_seller": """
            select count(*)
            from raw_order_items oi
            left join raw_sellers s on oi.seller_id = s.seller_id
            where s.seller_id is null
        """,
    }

    for check_name, query in checks.items():
        result = con.execute(query).fetchone()[0]
        print(f"{check_name}: {result:,}")

    print_section("8. Basic business metrics")
    print(
        con.execute(
            """
            select
                count(distinct o.order_id) as total_orders,
                count(distinct oi.product_id) as products_sold,
                round(sum(try_cast(oi.price as double)), 2) as total_item_revenue,
                round(sum(try_cast(oi.freight_value as double)), 2) as total_freight_value
            from raw_orders o
            left join raw_order_items oi on o.order_id = oi.order_id
            """
        ).fetchdf()
    )

    print_section("9. Sample raw_orders")
    print(con.execute("select * from raw_orders limit 5").fetchdf())

    print_section("10. Sample raw_order_items")
    print(con.execute("select * from raw_order_items limit 5").fetchdf())

    con.close()


if __name__ == "__main__":
    main()
