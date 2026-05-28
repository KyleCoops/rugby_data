

{{ config(materialized='table') }}

with source_data as (

    select *
    from {{ source('silver_3nf', 'team') }} as m
    join {{ source('silver_3nf', 'country') }} as c 
    on c.country_id=m.country_id

)

select *
from source_data