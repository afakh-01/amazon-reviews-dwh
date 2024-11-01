# Use the official Airflow image as the base
FROM apache/airflow:2.5.0-python3.9

# Install dbt-core and required dependencies
RUN pip install \
    "dbt-core==1.8.8" \
    "dbt-postgres==1.8.0" \
    "protobuf==4.21.0" \
    "sqlparse==0.5.1" \
    "Jinja2==3.1.4"

# Set up necessary permissions for the dbt folder in /opt/airflow
RUN mkdir -p /opt/airflow/dbt/logs && \
    chmod -R 777 /opt/airflow/dbt

# Set the working directory
WORKDIR /opt/airflow
