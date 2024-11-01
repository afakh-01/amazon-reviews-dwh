# dbt Dockerfile
FROM python:3.9-slim

# Set working directory
WORKDIR /dbt

# Copy local dbt project files into the container
COPY . /dbt

# Install dbt and any other dependencies
RUN pip install dbt-postgres

# Default command
CMD ["dbt", "run"]
