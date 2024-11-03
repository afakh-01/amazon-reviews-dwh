{{ config(
    materialized='view',
    schema='staging'
) }}

WITH source AS (
    SELECT * 
    FROM {{ source('amazon', 'metadata_category_clothing_shoes_and_jewelry_only') }}
),

renamed AS (
    SELECT
        metadataid AS metadata_id,
        asin,
        salesrank AS sales_rank,
        imurl AS im_url,
        (regexp_matches(categories, E'\\[\\[\'([^\']+)\'', 'g'))[1] AS category,
        title,
        description,
        price,
        brand
    FROM source s
)

SELECT * 
FROM renamed