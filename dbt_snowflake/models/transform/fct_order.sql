{{
    config(
        materialized="incremental",
        tags=["orders"]
    )
}}

with orders as (
    
    select * from {{ ref('stg_order__filtered_attributes')}}
    
    {% if is_incremental() %}

    -- this filter will only be applied on an incremental run
    where o_orderdate > (select max(o_orderdate) from {{ this }})

    {% endif %}

),

final as (

    select
        o_orderkey
        , o_orderdate
        , o_totalprice
        , {{ "to_char(current_timestamp, 'YYYYMMDDHH24MISS')" }} as batch_id
    
    from orders
)

select * from final
order by o_orderdate