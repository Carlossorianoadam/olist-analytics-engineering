
with product_order_reviews as (

    -- One review score per product and order
    select distinct
        product_id,
        order_id,
        average_review_score

    from {{ ref('mart_order_items') }}

),

product_review_metrics as (

    select
        product_id,
        round(avg(average_review_score), 2) as average_review_score

    from product_order_reviews

    group by product_id

)

select
    oi.product_id,
    oi.product_category,

    count(distinct oi.order_id) as number_of_orders,
    count(*) as number_of_order_items,

    round(sum(oi.item_price), 2) as total_item_revenue,
    round(sum(oi.freight_value), 2) as total_freight_value,
    round(sum(oi.item_total_value), 2) as total_revenue_with_freight,

    round(sum(oi.delivered_item_revenue), 2) as delivered_item_revenue,
    round(sum(oi.delivered_item_total_value), 2) as delivered_revenue_with_freight,

    round(avg(oi.item_price), 2) as average_item_price,

    -- Each product-order pair contributes once
    pr.average_review_score,

    sum(
        case when oi.is_late_delivery = true then 1 else 0 end
    ) as late_delivery_items,

    count(oi.is_late_delivery) as evaluable_delivery_items,

    round(
        sum(
            case when oi.is_late_delivery = true then 1 else 0 end
        ) * 100.0
        / nullif(count(oi.is_late_delivery), 0),
        2
    ) as late_delivery_rate_pct

from {{ ref('mart_order_items') }} oi

left join product_review_metrics pr
    on oi.product_id = pr.product_id

group by
    oi.product_id,
    oi.product_category,
    pr.average_review_score
