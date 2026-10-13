select
    order_id,

    count(*) as review_count,
    round(avg(review_score), 2) as average_review_score,
    min(review_score) as min_review_score,
    max(review_score) as max_review_score,

    max(review_creation_date) as latest_review_creation_date,
    max(review_answer_timestamp) as latest_review_answer_timestamp

from {{ ref('stg_reviews') }}

group by order_id
