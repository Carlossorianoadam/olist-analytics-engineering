select
    count(*) as total_orders,

    count(*) filter (
        where is_delivered_order
    ) as delivered_orders,

    count(*) filter (
        where is_canceled_order
    ) as canceled_orders,

    -- All orders, regardless of status
    round(sum(total_item_revenue), 2) as total_item_revenue,
    round(sum(total_freight_value), 2) as total_freight_value,
    round(sum(total_order_value), 2) as total_order_value,

    -- Delivered orders only
    round(sum(
        case
            when is_delivered_order then total_item_revenue
            else 0
        end
    ), 2) as delivered_item_revenue,

    round(sum(
        case
            when is_delivered_order then total_order_value
            else 0
        end
    ), 2) as delivered_order_value,

    round(
        sum(
            case
                when is_delivered_order then total_order_value
                else 0
            end
        ) / nullif(
            count(*) filter (where is_delivered_order), 0
        ),
        2
    ) as average_delivered_order_value,

    round(avg(total_order_value), 2) as average_order_value,
    round(avg(delivery_days), 2) as average_delivery_days,
    round(avg(average_review_score), 2) as average_review_score,

    round(
        100.0 * count(*) filter (
            where is_late_delivery = true
        ) / nullif(
            count(*) filter (
                where is_late_delivery is not null
            ), 0
        ),
        2
    ) as late_delivery_rate_pct

from mart_orders