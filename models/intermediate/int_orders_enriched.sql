with orders as (

    select *
    from {{ ref('stg_orders') }}

),

customers as (

    select *
    from {{ ref('stg_customers') }}

),

payments as (

    select *
    from {{ ref('int_payments_aggregated') }}

),

reviews as (

    select *
    from {{ ref('int_reviews_aggregated') }}

)

select
    o.order_id,
    o.customer_id,
    c.customer_unique_id,

    c.customer_city,
    c.customer_state,

    o.order_status,
    o.order_purchase_timestamp,
    cast(date_trunc('month', o.order_purchase_timestamp) as date) as order_purchase_month,
    o.order_approved_at,
    o.order_delivered_carrier_date,
    o.order_delivered_customer_date,
    o.order_estimated_delivery_date,

    case
        when o.order_approved_at is not null
        then date_diff('hour', o.order_purchase_timestamp, o.order_approved_at)
        else null
    end as approval_time_hours,

    case
        when o.order_delivered_customer_date is not null
        then date_diff('day', o.order_purchase_timestamp, o.order_delivered_customer_date)
        else null
    end as delivery_days,

    case
        when o.order_delivered_customer_date is not null
             and o.order_estimated_delivery_date is not null
        then date_diff('day', o.order_estimated_delivery_date, o.order_delivered_customer_date)
        else null
    end as delivery_delay_days,

    case
        when o.order_delivered_customer_date is not null
             and o.order_estimated_delivery_date is not null
             and o.order_delivered_customer_date > o.order_estimated_delivery_date
        then true
        when o.order_delivered_customer_date is not null
             and o.order_estimated_delivery_date is not null
        then false
        else null
    end as is_late_delivery,

    p.payment_records,
    p.payment_types,
    p.total_payment_value,
    p.max_payment_installments,

    r.review_count,
    r.average_review_score,
    r.min_review_score,
    r.max_review_score

from orders o

left join customers c
    on o.customer_id = c.customer_id

left join payments p
    on o.order_id = p.order_id

left join reviews r
    on o.order_id = r.order_id
