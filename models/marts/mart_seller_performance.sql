select
    seller_id,

    min(seller_city) as seller_city,
    min(seller_state) as seller_state,

    count(distinct order_id) as number_of_orders,
    count(*) as number_of_order_items,

    round(sum(item_price), 2) as total_item_revenue,
    round(sum(freight_value), 2) as total_freight_value,
    round(sum(item_total_value), 2) as total_revenue_with_freight,

    round(sum(delivered_item_revenue), 2) as delivered_item_revenue,
    round(avg(item_price), 2) as average_item_price,

    round(avg(average_review_score), 2) as average_review_score,
    round(avg(delivery_days), 2) as average_delivery_days,

    sum(case when is_late_delivery = true then 1 else 0 end) as late_delivery_items,
    round(
        sum(case when is_late_delivery = true then 1 else 0 end) * 100.0 / count(*),
        2
    ) as late_delivery_rate_pct

from {{ ref('mart_order_items') }}

group by seller_id
