select
    p.payment_type,

    count(distinct p.order_id) as total_orders,
    count(*) as payment_records,

    round(sum(p.payment_value), 2) as total_payment_value,
    round(avg(p.payment_value), 2) as average_payment_value,
    round(avg(p.payment_installments), 2) as average_installments,

    round(avg(o.average_review_score), 2) as average_review_score,
    round(avg(o.delivery_days), 2) as average_delivery_days,

    round(
        sum(case when o.is_late_delivery then 1 else 0 end) * 100.0 /
        nullif(sum(case when o.order_delivered_customer_date is not null then 1 else 0 end), 0),
        2
    ) as late_delivery_rate_pct

from stg_payments p

left join mart_orders o
    on p.order_id = o.order_id

group by p.payment_type

order by total_payment_value desc
