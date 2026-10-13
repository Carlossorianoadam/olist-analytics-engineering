from pathlib import Path
import duckdb


DB_PATH = "olist_analytics.duckdb"
ANALYSES_DIR = Path("analyses/dashboard")
EXPORT_DIR = Path("dashboard/exports")


def main() -> None:
    EXPORT_DIR.mkdir(parents=True, exist_ok=True)

    con = duckdb.connect(DB_PATH)

    sql_files = sorted(ANALYSES_DIR.glob("*.sql"))

    if not sql_files:
        raise FileNotFoundError(f"No SQL files found in {ANALYSES_DIR}")

    print(f"Found {len(sql_files)} dashboard query files.")

    for sql_file in sql_files:
        output_name = sql_file.stem + ".csv"
        output_path = EXPORT_DIR / output_name

        print(f"Running {sql_file.name}...")

        query = sql_file.read_text()

        df = con.execute(query).fetchdf()
        df.to_csv(output_path, index=False)

        print(f"Exported {len(df):,} rows to {output_path}")

    con.close()

    print("\nDashboard query exports completed successfully.")


if __name__ == "__main__":
    main()
