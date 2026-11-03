from datetime import timedelta

import pendulum

from airflow.sdk import DAG
from airflow.providers.standard.operators.bash import BashOperator


PROJECT_DIR = "/opt/olist_analytics"
DBT_PROFILES_DIR = f"{PROJECT_DIR}/airflow/dbt"

DBT_FLAGS = (
    f"--profiles-dir {DBT_PROFILES_DIR} "
    "--target dev"
)


with DAG(
    dag_id="olist_analytics_pipeline",
    description=(
        "Load Olist raw data, build dbt models, test data quality "
        "and validate Power BI exports."
    ),
    start_date=pendulum.datetime(2026, 1, 1, tz="UTC"),
    schedule=None,
    catchup=False,
    max_active_runs=1,
    default_args={
        "owner": "data-engineering-portfolio",
        "retries": 1,
        "retry_delay": timedelta(minutes=2),
    },
    tags=["olist", "duckdb", "dbt", "power-bi"],
) as dag:

    load_raw = BashOperator(
        task_id="load_raw_data",
        cwd=PROJECT_DIR,
        bash_command=(
            "set -euo pipefail\n"
            "python scripts/load_raw_olist.py"
        ),
    )

    dbt_run = BashOperator(
        task_id="dbt_run",
        cwd=PROJECT_DIR,
        bash_command=f"set -euo pipefail\ndbt run {DBT_FLAGS}",
    )

    dbt_test = BashOperator(
        task_id="dbt_test",
        cwd=PROJECT_DIR,
        bash_command=f"set -euo pipefail\ndbt test {DBT_FLAGS}",
    )

    export_csv = BashOperator(
        task_id="export_dashboard_csv",
        cwd=PROJECT_DIR,
        bash_command=(
            "set -euo pipefail\n"
            "python scripts/export_dashboard_queries.py"
        ),
    )

    validate_exports = BashOperator(
        task_id="validate_dashboard_exports",
        cwd=PROJECT_DIR,
        bash_command=(
            "set -euo pipefail\n"
            "python scripts/validate_dashboard_exports.py"
        ),
    )

    load_raw >> dbt_run >> dbt_test >> export_csv >> validate_exports
