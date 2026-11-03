from pathlib import Path
import math

import duckdb
import pandas as pd


PROJECT_DIR = Path(__file__).resolve().parents[1]
EXPORT_DIR = PROJECT_DIR / "dashboard" / "exports"
DB_PATH = PROJECT_DIR / "olist_analytics.duckdb"

EXPECTED_ROWS = {
    "01_executive_kpis.csv": 1,
    "02_monthly_revenue.csv": 25,
    "03_category_performance.csv": 74,
    "04_seller_performance.csv": 3095,
    "05_delivery_performance_by_state.csv": 27,
    "06_payment_method_performance.csv": 5,
    "07_review_delivery_relationship.csv": 4,
}


def main() -> None:
    exported = {}

    print("=== CHECK EXPORTED FILES ===")

    for filename, expected_rows in EXPECTED_ROWS.items():
        path = EXPORT_DIR / filename

        if not path.is_file():
            raise FileNotFoundError(f"Missing export: {path}")

        df = pd.read_csv(path)

        if len(df) != expected_rows:
            raise ValueError(
                f"{filename}: expected {expected_rows} rows, "
                f"got {len(df)}"
            )

        exported[filename] = df
        print(f"PASS {filename}: {len(df)} rows")

    print("\n=== RECONCILE DELIVERED ITEM REVENUE ===")

    kpis = exported["01_executive_kpis.csv"]

    expected_revenue = float(
        kpis["delivered_item_revenue"].iloc[0]
    )

    revenue_sources = {
        "monthly": exported["02_monthly_revenue.csv"],
        "categories": exported["03_category_performance.csv"],
        "sellers": exported["04_seller_performance.csv"],
    }

    for name, df in revenue_sources.items():
        actual_revenue = float(df["delivered_item_revenue"].sum())

        print(f"{name}: {actual_revenue:.2f}")

        if not math.isclose(
            actual_revenue,
            expected_revenue,
            abs_tol=0.01,
        ):
            raise ValueError(
                f"Revenue mismatch in {name}: "
                f"{actual_revenue:.2f} vs {expected_revenue:.2f}"
            )

    print("\n=== VALIDATE CATEGORY REVIEWS ===")

    con = duckdb.connect(str(DB_PATH), read_only=True)

    try:
        expected_reviews = con.execute("""
            select
                product_category,
                round(avg(average_review_score), 2)
                    as expected_review_score
            from (
                select distinct
                    product_category,
                    order_id,
                    average_review_score
                from mart_order_items
            )
            group by product_category
        """).fetchdf()
    finally:
        con.close()

    actual_reviews = exported["03_category_performance.csv"][
        ["product_category", "average_review_score"]
    ]

    comparison = actual_reviews.merge(
        expected_reviews,
        on="product_category",
        how="outer",
        validate="one_to_one",
        indicator=True,
    )

    if not (comparison["_merge"] == "both").all():
        raise ValueError("Category sets do not match the database")

    for row in comparison.itertuples(index=False):
        actual = row.average_review_score
        expected = row.expected_review_score

        if pd.isna(actual) and pd.isna(expected):
            continue

        if (
            pd.isna(actual)
            or pd.isna(expected)
            or not math.isclose(
                float(actual),
                float(expected),
                abs_tol=0.001,
            )
        ):
            raise ValueError(
                f"Review mismatch for {row.product_category}: "
                f"{actual} vs {expected}"
            )

    print(f"PASS: {len(comparison)} category reviews")
    print(f"PASS: revenue reconciled to {expected_revenue:.2f}")
    print("\nALL EXPORT VALIDATIONS PASSED")


if __name__ == "__main__":
    main()
