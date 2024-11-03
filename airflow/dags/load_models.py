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
    dag_id='load_models',
    default_args=default_args,
    start_date=days_ago(1),
    schedule_interval='@daily',
    catchup=False,
) as dag:

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

    load_models = BashOperator(
        task_id="load_models",
        bash_command='dbt deps --project-dir /opt/airflow/dbt --log-path /tmp/dbt.log && dbt run --project-dir /opt/airflow/dbt --profiles-dir /opt/airflow/dbt --log-path /tmp/dbt.log'
    )

    # Define task dependencies
    [load_raw_reviews, load_raw_metadata] >> load_models
