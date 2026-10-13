select
    order_purchase_month,

    count(*) as total_orders,
    sum(case when is_delivered_order then 1 else 0 end) as delivered_orders,
    sum(case when is_canceled_order then 1 else 0 end) as canceled_orders,

    round(sum(total_item_revenue), 2) as total_item_revenue,
    round(sum(total_freight_value), 2) as total_freight_value,
    round(sum(total_order_value), 2) as total_order_value,

    round(avg(total_order_value), 2) as average_order_value,
    round(avg(average_review_score), 2) as average_review_score,

    round(
        sum(case when is_late_delivery then 1 else 0 end) * 100.0 /
        nullif(sum(case when order_delivered_customer_date is not null then 1 else 0 end), 0),
        2
    ) as late_delivery_rate_pct

from mart_orders

where order_purchase_month is not null

group by order_purchase_month

order by order_purchase_month
