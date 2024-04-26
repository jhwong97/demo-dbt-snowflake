{{
    config(
        materialized = 'table',
        tags=["staging"]
    )
}}

select
    c_customer_id
    , c_birth_day
    , c_birth_month
    , c_birth_year

from
    {{ source("customer", "customer")}}
    
limit 500