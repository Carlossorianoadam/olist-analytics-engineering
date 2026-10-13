select
    seller_id,
    seller_city,
    seller_state,

    number_of_orders,
    number_of_order_items,

    total_item_revenue,
    total_freight_value,
    total_revenue_with_freight,
    delivered_item_revenue,

    average_item_price,
    average_review_score,
    average_delivery_days,
    late_delivery_rate_pct

from mart_seller_performance

order by total_item_revenue desc
