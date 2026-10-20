
with expected as (

    select
        seller_id,

        count(*) as expected_items,
        count(is_late_delivery) as expected_evaluable_items,

        count(*) filter (
            where is_late_delivery = true
        ) as expected_late_items,

        round(
            100.0 * count(*) filter (
                where is_late_delivery = true
            ) / nullif(count(is_late_delivery), 0),
            2
        ) as expected_rate

    from {{ ref('mart_order_items') }}

    group by seller_id

)

select
    coalesce(s.seller_id, e.seller_id) as seller_id

from expected e

full outer join {{ ref('mart_seller_performance') }} s
    on e.seller_id = s.seller_id

where
    e.seller_id is null
    or s.seller_id is null
    or s.number_of_order_items is distinct from e.expected_items
    or s.evaluable_delivery_items is distinct from e.expected_evaluable_items
    or s.late_delivery_items is distinct from e.expected_late_items
    or s.late_delivery_rate_pct is distinct from e.expected_rate
