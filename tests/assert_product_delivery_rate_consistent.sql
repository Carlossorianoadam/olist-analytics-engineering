
with expected as (

    select
        product_id,

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

    group by product_id

)

select
    coalesce(p.product_id, e.product_id) as product_id

from expected e

full outer join {{ ref('mart_product_performance') }} p
    on e.product_id = p.product_id

where
    e.product_id is null
    or p.product_id is null
    or p.number_of_order_items is distinct from e.expected_items
    or p.evaluable_delivery_items is distinct from e.expected_evaluable_items
    or p.late_delivery_items is distinct from e.expected_late_items
    or p.late_delivery_rate_pct is distinct from e.expected_rate
