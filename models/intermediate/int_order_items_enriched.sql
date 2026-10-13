with order_items as (

    select *
    from {{ ref('stg_order_items') }}

),

products as (

    select *
    from {{ ref('stg_products') }}

),

category_translation as (

    select *
    from {{ ref('stg_category_translation') }}

),

sellers as (

    select *
    from {{ ref('stg_sellers') }}

)

select
    oi.order_item_key,
    oi.order_id,
    oi.order_item_id,
    oi.product_id,
    oi.seller_id,

    coalesce(
        ct.product_category_name_english,
        p.product_category_name,
        'unknown'
    ) as product_category,

    p.product_category_name as product_category_original,
    p.product_weight_g,
    p.product_length_cm,
    p.product_height_cm,
    p.product_width_cm,

    s.seller_city,
    s.seller_state,

    oi.shipping_limit_date,
    oi.price as item_price,
    oi.freight_value,
    oi.price + oi.freight_value as item_total_value

from order_items oi

left join products p
    on oi.product_id = p.product_id

left join category_translation ct
    on p.product_category_name = ct.product_category_name

left join sellers s
    on oi.seller_id = s.seller_id
