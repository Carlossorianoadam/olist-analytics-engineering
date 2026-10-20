
with revenue_totals as (

    select
        'orders' as source,
        round(
            sum(
                case
                    when is_delivered_order
                    then total_item_revenue
                    else 0
                end
            ),
            2
        ) as delivered_revenue
    from {{ ref('mart_orders') }}

    union all

    select
        'order_items' as source,
        round(sum(delivered_item_revenue), 2)
    from {{ ref('mart_order_items') }}

    union all

    select
        'products' as source,
        round(sum(delivered_item_revenue), 2)
    from {{ ref('mart_product_performance') }}

    union all

    select
        'sellers' as source,
        round(sum(delivered_item_revenue), 2)
    from {{ ref('mart_seller_performance') }}

),

reference_total as (

    select delivered_revenue
    from revenue_totals
    where source = 'orders'

)

select
    t.source,
    t.delivered_revenue

from revenue_totals t

cross join reference_total r

where
    t.delivered_revenue is distinct from r.delivered_revenue
