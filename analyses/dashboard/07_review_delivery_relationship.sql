select
    case
        when delivery_days is null then 'No delivery date'
        when delivery_delay_days > 0 then 'Late delivery'
        when delivery_delay_days between -3 and 0 then 'On time'
        when delivery_delay_days < -3 then 'Early delivery'
        else 'Unknown'
    end as delivery_performance_group,

    count(*) as total_orders,

    round(avg(delivery_days), 2) as average_delivery_days,
    round(avg(delivery_delay_days), 2) as average_delivery_delay_days,
    round(avg(average_review_score), 2) as average_review_score,

    round(sum(total_order_value), 2) as total_order_value

from mart_orders

group by delivery_performance_group

order by average_review_score desc
