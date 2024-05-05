{{
    config(
        materialized = 'view',
        tags=["staging"]
    )
}}

select
    o_orderkey
    , o_orderstatus
    , o_totalprice
    , o_orderdate

from
    {{ source("order", "orders")}}
    
limit 300