{{
    config(
        materialized = 'view',
        tags=["staging"]
    )
}}

select
    cd_demo_sk
    , cd_gender
    , cd_education_status
    , cd_credit_rating

from
    {{ source("customer", "customer_demographics")}}
    
limit 500