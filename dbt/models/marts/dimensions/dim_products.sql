{{ config(
    materialized='table',
    schema='marts'
) }}

WITH source AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key(['asin']) }} AS product_key,  
        asin,                                                    
        sales_rank,
        category,
        title,
        description,
        price,
        brand
    FROM {{ ref('stg_amazon_metadata') }}
)

SELECT *
FROM source
