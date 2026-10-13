select *
from {{ ref('mart_order_items') }}
where freight_value < 0
