
with category_order_reviews as (

    -- One review score per category and order
    select distinct
        product_category,
        order_id,
        average_review_score

    from mart_order_items

),

category_review_metrics as (

    select
        product_category,
        round(avg(average_review_score), 2) as average_review_score

    from category_order_reviews

    group by product_category

)

select
    oi.product_category,

    count(distinct oi.order_id) as total_orders,
    count(*) as total_order_items,

    round(sum(oi.item_price), 2) as total_item_revenue,
    round(sum(oi.freight_value), 2) as total_freight_value,
    round(sum(oi.item_total_value), 2) as total_revenue_with_freight,

    round(sum(oi.delivered_item_revenue), 2) as delivered_item_revenue,
    round(sum(oi.delivered_item_total_value), 2) as delivered_revenue_with_freight,

    round(avg(oi.item_price), 2) as average_item_price,

    -- Each category-order pair contributes once
    cr.average_review_score,

    round(avg(oi.delivery_days), 2) as average_delivery_days,

    round(
        count(*) filter (
            where oi.is_late_delivery = true
        ) * 100.0
        / nullif(count(oi.is_late_delivery), 0),
        2
    ) as late_delivery_rate_pct

from mart_order_items oi

left join category_review_metrics cr
    on oi.product_category = cr.product_category

group by
    oi.product_category,
    cr.average_review_score

order by delivered_item_revenue desc
