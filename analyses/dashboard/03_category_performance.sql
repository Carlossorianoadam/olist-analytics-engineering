select
    product_category,

    count(distinct order_id) as total_orders,
    count(*) as total_order_items,

    round(sum(item_price), 2) as total_item_revenue,
    round(sum(freight_value), 2) as total_freight_value,
    round(sum(item_total_value), 2) as total_revenue_with_freight,

    round(sum(delivered_item_revenue), 2) as delivered_item_revenue,
    round(sum(delivered_item_total_value), 2) as delivered_revenue_with_freight,

    round(avg(item_price), 2) as average_item_price,
    round(avg(average_review_score), 2) as average_review_score,
    round(avg(delivery_days), 2) as average_delivery_days,

    round(
        sum(case when is_late_delivery then 1 else 0 end) * 100.0 /
        nullif(sum(case when delivery_days is not null then 1 else 0 end), 0),
        2
    ) as late_delivery_rate_pct

from mart_order_items

group by product_category

order by delivered_item_revenue desc
