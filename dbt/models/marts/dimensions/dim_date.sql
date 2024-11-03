{{ config(
    materialized='table',
    schema='marts'
) }}

WITH date_series AS (
    SELECT 
        DATE '2000-01-01' + i AS date
    FROM generate_series(0, (DATE '2050-12-31' - DATE '2000-01-01')) AS i
),

date_dimension AS (
    SELECT
        TO_CHAR(date, 'YYYYMMDD')::INT AS date_key,   
        CAST(date AS DATE) AS date,                                        
        CAST(EXTRACT(YEAR FROM date) AS INTEGER) AS year,
        CAST(EXTRACT(MONTH FROM date) AS INTEGER) AS month,
        CAST(EXTRACT(DAY FROM date) AS INTEGER) AS day,
        CAST(EXTRACT(DOW FROM date) + 1 AS INTEGER) AS day_of_week
    FROM date_series
)

SELECT *
FROM date_dimension
