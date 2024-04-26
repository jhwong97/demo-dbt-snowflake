{{
    config(
        materialized='table',
        tags=['customer']
    )
}}
select
    c_customer_id
    , date(c_birth_year || '-' || c_birth_month || '-' || c_birth_day) as c_birth_date
from
    {{ref('stg_customer__filtered_attributes')}}
where
    c_birth_date > '1960-01-01'