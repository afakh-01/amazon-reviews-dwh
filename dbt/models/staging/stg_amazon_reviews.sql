{{ config(
    materialized='view',
    schema='staging'
) }}

WITH source AS (
    SELECT * 
    FROM {{ source('amazon', 'reviews_clothing_shoes_and_jewelry_5') }}
),

renamed AS (
    SELECT
        CAST("reviewerID" AS TEXT) AS reviewer_id,                 
        CAST(asin AS TEXT) AS asin,                                
        CAST("reviewerName" AS TEXT) AS reviewer_name,             
        CAST(helpful AS JSONB) AS helpful,                         
        CAST("reviewText" AS TEXT) AS review_text,                 
        CAST(overall AS NUMERIC) AS rating,                        
        CAST(summary AS TEXT) AS summary,                          
        CAST("unixReviewTime" AS INTEGER) AS unix_review_time,     
        TO_DATE("reviewTime", 'MM DD, YYYY') AS review_date        
    FROM source s
)

SELECT * 
FROM renamed
