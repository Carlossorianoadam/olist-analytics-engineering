select
    order_id,

    count(*) as payment_records,
    string_agg(distinct payment_type, ', ') as payment_types,

    sum(payment_value) as total_payment_value,
    max(payment_installments) as max_payment_installments,

    sum(case when payment_type = 'credit_card' then payment_value else 0 end) as credit_card_payment_value,
    sum(case when payment_type = 'boleto' then payment_value else 0 end) as boleto_payment_value,
    sum(case when payment_type = 'voucher' then payment_value else 0 end) as voucher_payment_value,
    sum(case when payment_type = 'debit_card' then payment_value else 0 end) as debit_card_payment_value

from {{ ref('stg_payments') }}

group by order_id
