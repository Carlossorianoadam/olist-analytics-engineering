select *
from {{ ref('mart_customer_metrics') }}
where number_of_orders <= 0
   or total_order_value < 0
