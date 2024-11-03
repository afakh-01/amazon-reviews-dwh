from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.operators.bash import BashOperator
from sqlalchemy import create_engine, text
import pandas as pd
from datetime import timedelta
from airflow.utils.dates import days_ago

DB_URI = "postgresql+psycopg2://postgres:postgres@postgres:5432/warehouse"

def create_and_load_raw_table(filename: str, table_name: str):
    """Load raw CSV data into a PostgreSQL table in the 'raw' schema, with cascade drop for dependencies."""
    engine = create_engine(DB_URI)
    df = pd.read_csv(filename)
    
    with engine.connect() as conn:
        conn.execute(text(f"DROP TABLE IF EXISTS raw.{table_name} CASCADE;"))
    
    df.to_sql(table_name, engine, schema='raw', if_exists='replace', index=False)

default_args = {
    'owner': 'airflow',
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

with DAG(
    dag_id='load_and_test_models',
    default_args=default_args,
    start_date=days_ago(1),
    schedule_interval='@daily',
    catchup=False,
) as dag:

    # Load raw data into raw tables
    load_raw_reviews = PythonOperator(
        task_id="load_raw_reviews",
        python_callable=create_and_load_raw_table,
        op_kwargs={
            "filename": "/data/reviews_Clothing_Shoes_and_Jewelry_5.csv",
            "table_name": "reviews_clothing_shoes_and_jewelry_5"
        }
    )

    load_raw_metadata = PythonOperator(
        task_id="load_raw_metadata",
        python_callable=create_and_load_raw_table,
        op_kwargs={
            "filename": "/data/metadata_category_clothing_shoes_and_jewelry_only.csv",
            "table_name": "metadata_category_clothing_shoes_and_jewelry_only"
        }
    )

    # Install dependencies
    dbt_deps = BashOperator(
        task_id="dbt_deps",
        bash_command="dbt deps --project-dir /opt/airflow/dbt --log-path /tmp/dbt.log"
    )

    # Run dbt models for staging layer
    run_staging_models = BashOperator(
        task_id="run_staging_models",
        bash_command="dbt run --models staging --project-dir /opt/airflow/dbt --profiles-dir /opt/airflow/dbt --log-path /tmp/dbt.log"
    )

    # Test dbt models for staging layer
    test_staging_models = BashOperator(
        task_id="test_staging_models",
        bash_command="dbt test --models staging --project-dir /opt/airflow/dbt --profiles-dir /opt/airflow/dbt --log-path /tmp/dbt.log"
    )

    # Run dbt models for marts layer (dimensions and facts)
    run_marts_dimensions = BashOperator(
        task_id="run_marts_dimensions",
        bash_command="dbt run --models marts.dimensions --project-dir /opt/airflow/dbt --profiles-dir /opt/airflow/dbt --log-path /tmp/dbt.log"
    )

    test_marts_dimensions = BashOperator(
        task_id="test_marts_dimensions",
        bash_command="dbt test --models marts.dimensions --project-dir /opt/airflow/dbt --profiles-dir /opt/airflow/dbt --log-path /tmp/dbt.log"
    )

    run_marts_facts = BashOperator(
        task_id="run_marts_facts",
        bash_command="dbt run --models marts.facts --project-dir /opt/airflow/dbt --profiles-dir /opt/airflow/dbt --log-path /tmp/dbt.log"
    )

    test_marts_facts = BashOperator(
        task_id="test_marts_facts",
        bash_command="dbt test --models marts.facts --project-dir /opt/airflow/dbt --profiles-dir /opt/airflow/dbt --log-path /tmp/dbt.log"
    )

    # Task Dependencies
    [load_raw_reviews, load_raw_metadata] >> dbt_deps >> run_staging_models >> test_staging_models
    test_staging_models >> run_marts_dimensions >> test_marts_dimensions
    test_marts_dimensions >> run_marts_facts >> test_marts_facts
