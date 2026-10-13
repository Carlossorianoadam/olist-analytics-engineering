select *
from {{ ref('mart_orders') }}
where total_order_value < 0
