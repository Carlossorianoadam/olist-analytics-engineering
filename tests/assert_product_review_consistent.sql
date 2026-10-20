
with expected as (

    select
        product_id,
        round(avg(average_review_score), 2) as expected_review

    from (
        select distinct
            product_id,
            order_id,
            average_review_score
        from {{ ref('mart_order_items') }}
    )

    group by product_id

)

select
    coalesce(p.product_id, e.product_id) as product_id,
    p.average_review_score as actual_review,
    e.expected_review

from expected e

full outer join {{ ref('mart_product_performance') }} p
    on e.product_id = p.product_id

where
    p.product_id is null
    or e.product_id is null
    or p.average_review_score is distinct from e.expected_review
