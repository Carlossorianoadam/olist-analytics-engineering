select *
from {{ ref('mart_orders') }}
where average_review_score is not null
  and (average_review_score < 1 or average_review_score > 5)
