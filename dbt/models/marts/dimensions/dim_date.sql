{{ config(
    materialized='table'
) }}

WITH date_series AS (
    SELECT 
        DATE '2000-01-01' + i AS date
    FROM generate_series(0, (DATE '2050-12-31' - DATE '2000-01-01')) AS i
),

date_dimension AS (
    SELECT
        TO_CHAR(date, 'YYYYMMDD')::INT AS date_key,   
        date,                                         
        EXTRACT(YEAR FROM date) AS year,
        EXTRACT(MONTH FROM date) AS month,
        EXTRACT(DAY FROM date) AS day,
        EXTRACT(DOW FROM date) + 1 AS day_of_week
    FROM date_series
)

SELECT *
FROM date_dimension
