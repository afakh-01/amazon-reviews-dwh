{{ config(
    materialized='table',
    schema='marts'
) }}

WITH source AS (
    SELECT
        CAST({{ dbt_utils.generate_surrogate_key(['asin']) }} AS TEXT) AS product_key,  
        CAST(asin AS TEXT) AS product_id,                                                  
        CAST(sales_rank AS TEXT) AS category_sales_rank,
        CAST(category AS TEXT) AS primary_category,
        CAST(title AS TEXT) AS product_name,
        CAST(description AS TEXT) AS product_description,
        CAST(price AS NUMERIC) AS list_price,
        CAST(brand AS TEXT) AS brand_name
    FROM {{ ref('stg_amazon_metadata') }}
)

SELECT *
FROM source
