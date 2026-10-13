select
    customer_unique_id,

    min(customer_city) as customer_city,
    min(customer_state) as customer_state,

    count(distinct order_id) as number_of_orders,
    sum(case when is_delivered_order = true then 1 else 0 end) as delivered_orders,
    sum(case when is_canceled_order = true then 1 else 0 end) as canceled_orders,

    min(order_purchase_timestamp) as first_order_timestamp,
    max(order_purchase_timestamp) as last_order_timestamp,

    round(sum(total_item_revenue), 2) as total_item_revenue,
    round(sum(total_freight_value), 2) as total_freight_value,
    round(sum(total_order_value), 2) as total_order_value,
    round(avg(total_order_value), 2) as average_order_value,

    round(avg(average_review_score), 2) as average_review_score,
    round(avg(delivery_days), 2) as average_delivery_days

from {{ ref('mart_orders') }}

group by customer_unique_id
