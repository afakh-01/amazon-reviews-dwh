{{ config(
    materialized='table',
    schema='marts'
) }}

WITH source AS (
    SELECT
        CAST({{ dbt_utils.generate_surrogate_key(['asin']) }} AS TEXT) AS product_key,  
        CAST(asin AS TEXT) AS asin,                                                
        CAST(sales_rank AS TEXT) AS sales_rank,
        CAST(category AS TEXT) AS category,
        CAST(title AS TEXT) AS title,
        CAST(description AS TEXT) AS description,
        CAST(price AS NUMERIC) AS price,
        CAST(brand AS TEXT) AS brand
    FROM {{ ref('stg_amazon_metadata') }}
)

SELECT *
FROM source
