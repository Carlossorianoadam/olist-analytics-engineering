{{ config(severity='warn') }}

select *
from {{ ref('mart_orders') }}
where is_delivered_order = true
  and order_delivered_customer_date is null
