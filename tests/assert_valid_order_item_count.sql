select *
from {{ ref('mart_orders') }}
where order_item_count < 0
