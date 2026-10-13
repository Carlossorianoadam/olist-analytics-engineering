select *
from {{ ref('mart_order_items') }}
where item_price < 0
