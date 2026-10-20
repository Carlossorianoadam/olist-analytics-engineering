
with seller_order_reviews as (

    -- One review score per seller and order
    select distinct
        seller_id,
        order_id,
        average_review_score

    from {{ ref('mart_order_items') }}

),

seller_review_metrics as (

    select
        seller_id,
        round(avg(average_review_score), 2) as average_review_score

    from seller_order_reviews

    group by seller_id

)

select
    oi.seller_id,

    min(oi.seller_city) as seller_city,
    min(oi.seller_state) as seller_state,

    count(distinct oi.order_id) as number_of_orders,
    count(*) as number_of_order_items,

    round(sum(oi.item_price), 2) as total_item_revenue,
    round(sum(oi.freight_value), 2) as total_freight_value,
    round(sum(oi.item_total_value), 2) as total_revenue_with_freight,

    round(sum(oi.delivered_item_revenue), 2) as delivered_item_revenue,
    round(avg(oi.item_price), 2) as average_item_price,

    -- Each seller-order pair contributes once
    sr.average_review_score,

    round(avg(oi.delivery_days), 2) as average_delivery_days,

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

left join seller_review_metrics sr
    on oi.seller_id = sr.seller_id

group by
    oi.seller_id,
    sr.average_review_score
