select
    oi.order_item_key,
    oi.order_id,
    o.customer_id,
    o.customer_unique_id,

    oi.product_id,
    oi.seller_id,
    oi.product_category,

    o.order_status,
    o.order_purchase_timestamp,
    o.order_purchase_month,

    o.customer_city,
    o.customer_state,

    oi.seller_city,
    oi.seller_state,

    oi.item_price,
    oi.freight_value,
    oi.item_total_value,

    o.delivery_days,
    o.delivery_delay_days,
    o.is_late_delivery,
    o.average_review_score,

    case
        when o.order_status = 'delivered' then oi.item_price
        else 0
    end as delivered_item_revenue,

    case
        when o.order_status = 'delivered' then oi.item_total_value
        else 0
    end as delivered_item_total_value

from {{ ref('int_order_items_enriched') }} oi

left join {{ ref('int_orders_enriched') }} o
    on oi.order_id = o.order_id
