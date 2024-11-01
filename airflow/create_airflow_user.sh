# airflow/create_airflow_user.sh
#!/bin/bash

# Wait for the Airflow database to be ready
airflow db check

# Create an admin user if it doesn't exist
airflow users create \
    --username admin \
    --firstname Admin \
    --lastname User \
    --role Admin \
    --email admin@example.com \
    --password admin
