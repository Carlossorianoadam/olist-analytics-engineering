with order_items_aggregated as (

    select
        order_id,
        count(*) as order_item_count,
        count(distinct product_id) as distinct_product_count,
        count(distinct seller_id) as distinct_seller_count,
        sum(item_price) as total_item_revenue,
        sum(freight_value) as total_freight_value,
        sum(item_total_value) as total_order_value
    from {{ ref('int_order_items_enriched') }}
    group by order_id

)

select
    o.order_id,
    o.customer_id,
    o.customer_unique_id,

    o.customer_city,
    o.customer_state,

    o.order_status,
    o.order_purchase_timestamp,
    o.order_purchase_month,

    o.order_approved_at,
    o.order_delivered_carrier_date,
    o.order_delivered_customer_date,
    o.order_estimated_delivery_date,

    o.approval_time_hours,
    o.delivery_days,
    o.delivery_delay_days,
    o.is_late_delivery,

    coalesce(oi.order_item_count, 0) as order_item_count,
    coalesce(oi.distinct_product_count, 0) as distinct_product_count,
    coalesce(oi.distinct_seller_count, 0) as distinct_seller_count,

    coalesce(oi.total_item_revenue, 0) as total_item_revenue,
    coalesce(oi.total_freight_value, 0) as total_freight_value,
    coalesce(oi.total_order_value, 0) as total_order_value,

    o.payment_records,
    o.payment_types,
    o.total_payment_value,
    o.max_payment_installments,

    o.review_count,
    o.average_review_score,
    o.min_review_score,
    o.max_review_score,

    case
        when o.order_status = 'delivered' then true
        else false
    end as is_delivered_order,

    case
        when o.order_status = 'canceled' then true
        else false
    end as is_canceled_order

from {{ ref('int_orders_enriched') }} o

left join order_items_aggregated oi
    on o.order_id = oi.order_id
