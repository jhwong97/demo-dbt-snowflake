{{
    config(
        materialized = 'ephemeral',
        tags=["staging"]
    )
}}

select
    ca_address_id
    , ca_street_number
    , ca_street_name
    , ca_city

from
    {{ source("customer", "customer_address")}}
    
limit 500