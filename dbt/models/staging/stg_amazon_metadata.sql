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
        CAST(metadataid AS INTEGER) AS metadata_id,
        CAST(asin AS TEXT) AS asin,                         
        CAST(salesrank AS TEXT) AS sales_rank,           
        CAST(imurl AS TEXT) AS im_url,                     
        (regexp_matches(categories, E'\\[\\[\'([^\']+)\'', 'g'))[1] AS category,  
        CAST(title AS TEXT) AS title,                       
        CAST(description AS TEXT) AS description,           
        CAST(price AS NUMERIC) AS price,                    
        CAST(brand AS TEXT) AS brand                        
    FROM source s
)

SELECT * 
FROM renamed
