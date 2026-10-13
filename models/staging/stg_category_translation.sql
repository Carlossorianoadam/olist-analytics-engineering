select
    product_category_name,
    product_category_name_english
from {{ source('raw', 'raw_product_category_translation') }}
