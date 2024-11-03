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
        "reviewerID" AS reviewer_id,
        asin,
        "reviewerName" AS reviewer_name,
        helpful,
        "reviewText" AS review_text,
        overall AS rating,
        summary,
        "unixReviewTime" AS unix_review_time,
        TO_DATE("reviewTime", 'MM DD, YYYY') AS review_date
    FROM source s
)

SELECT * 
FROM renamed
