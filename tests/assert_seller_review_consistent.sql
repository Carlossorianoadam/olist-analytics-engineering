
with expected as (

    select
        seller_id,
        round(avg(average_review_score), 2) as expected_review

    from (
        select distinct
            seller_id,
            order_id,
            average_review_score
        from {{ ref('mart_order_items') }}
    )

    group by seller_id

)

select
    coalesce(s.seller_id, e.seller_id) as seller_id,
    s.average_review_score as actual_review,
    e.expected_review

from expected e

full outer join {{ ref('mart_seller_performance') }} s
    on e.seller_id = s.seller_id

where
    s.seller_id is null
    or e.seller_id is null
    or s.average_review_score is distinct from e.expected_review
