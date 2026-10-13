select
    customer_state,

    count(*) as total_orders,
    sum(case when is_delivered_order then 1 else 0 end) as delivered_orders,

    round(avg(delivery_days), 2) as average_delivery_days,
    round(avg(delivery_delay_days), 2) as average_delivery_delay_days,

    sum(case when is_late_delivery then 1 else 0 end) as late_deliveries,

    round(
        sum(case when is_late_delivery then 1 else 0 end) * 100.0 /
        nullif(sum(case when order_delivered_customer_date is not null then 1 else 0 end), 0),
        2
    ) as late_delivery_rate_pct,

    round(avg(average_review_score), 2) as average_review_score,
    round(sum(total_order_value), 2) as total_order_value

from mart_orders

where customer_state is not null

group by customer_state

order by total_order_value desc
