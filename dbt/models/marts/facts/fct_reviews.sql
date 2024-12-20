{{ config(
    materialized='incremental',
    schema='marts',
    unique_key='review_key'
) }}

WITH source_data AS (
    SELECT *
    FROM {{ ref('stg_amazon_reviews') }}
),

max_review_date_key AS (
    {% if is_incremental() %}
    SELECT COALESCE(MAX(review_date_key), 0) AS max_review_date_key
    FROM {{ this }}
    {% else %}
    SELECT 0 AS max_review_date_key
    {% endif %}
),

review_with_fk AS (
    SELECT
        CAST({{ dbt_utils.generate_surrogate_key(['r.reviewer_id', 'r.asin', 'r.review_date']) }} AS TEXT) AS review_key,  
        CAST(p.product_key AS TEXT) AS product_key,                         
        CAST(d.date_key AS INTEGER) AS review_date_key,          
        CAST(r.rating AS NUMERIC) AS rating                                
    FROM source_data r
    LEFT JOIN {{ ref('dim_products') }} p ON r.asin = p.product_id
    LEFT JOIN {{ ref('dim_date') }} d ON r.review_date = d.date
)

SELECT
    review_key,
    product_key,
    review_date_key,
    rating
FROM review_with_fk
WHERE review_with_fk.review_date_key > (SELECT max_review_date_key FROM max_review_date_key)
