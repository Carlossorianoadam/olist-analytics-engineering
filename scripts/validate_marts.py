import duckdb

DB_PATH = "olist_analytics.duckdb"


def print_section(title: str) -> None:
    print("\n" + "=" * 100)
    print(title)
    print("=" * 100)


def main() -> None:
    con = duckdb.connect(DB_PATH)

    print_section("1. Final mart row counts")
    tables = [
        "mart_order_items",
        "mart_orders",
        "mart_product_performance",
        "mart_customer_metrics",
        "mart_seller_performance",
    ]

    for table in tables:
        count = con.execute(f"select count(*) from {table}").fetchone()[0]
        print(f"{table}: {count:,} rows")

    print_section("2. Main business KPIs")
    print(
        con.execute(
            """
            select
                count(*) as total_orders,
                sum(case when is_delivered_order then 1 else 0 end) as delivered_orders,
                sum(case when is_canceled_order then 1 else 0 end) as canceled_orders,
                round(sum(total_item_revenue), 2) as total_item_revenue,
                round(sum(total_freight_value), 2) as total_freight_value,
                round(sum(total_order_value), 2) as total_order_value,
                round(avg(total_order_value), 2) as average_order_value,
                round(avg(delivery_days), 2) as average_delivery_days,
                round(avg(average_review_score), 2) as average_review_score
            from mart_orders
            """
        ).fetchdf()
    )

    print_section("3. Revenue by month")
    print(
        con.execute(
            """
            select
                order_purchase_month,
                count(*) as orders,
                round(sum(total_item_revenue), 2) as total_item_revenue,
                round(sum(total_order_value), 2) as total_order_value
            from mart_orders
            where order_purchase_month is not null
            group by order_purchase_month
            order by order_purchase_month
            limit 20
            """
        ).fetchdf()
    )

    print_section("4. Top 10 product categories by revenue")
    print(
        con.execute(
            """
            select
                product_category,
                count(distinct order_id) as orders,
                round(sum(item_price), 2) as total_item_revenue,
                round(avg(average_review_score), 2) as average_review_score
            from mart_order_items
            group by product_category
            order by total_item_revenue desc
            limit 10
            """
        ).fetchdf()
    )

    print_section("5. Top 10 sellers by revenue")
    print(
        con.execute(
            """
            select
                seller_id,
                seller_city,
                seller_state,
                number_of_orders,
                round(total_item_revenue, 2) as total_item_revenue,
                average_review_score,
                late_delivery_rate_pct
            from mart_seller_performance
            order by total_item_revenue desc
            limit 10
            """
        ).fetchdf()
    )

    print_section("6. Delivery performance")
    print(
        con.execute(
            """
            select
                count(*) as delivered_orders_with_delivery_date,
                round(avg(delivery_days), 2) as average_delivery_days,
                round(avg(delivery_delay_days), 2) as average_delivery_delay_days,
                round(
                    sum(case when is_late_delivery then 1 else 0 end) * 100.0 / count(*),
                    2
                ) as late_delivery_rate_pct
            from mart_orders
            where order_delivered_customer_date is not null
            """
        ).fetchdf()
    )

    print_section("7. Sample mart_orders")
    print(
        con.execute(
            """
            select *
            from mart_orders
            limit 5
            """
        ).fetchdf()
    )

    con.close()


if __name__ == "__main__":
    main()
