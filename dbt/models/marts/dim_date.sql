{{ config(materialized='table')}}

with date_table_source as ({{ dbt_utils.date_spine(
    datepart="day",
    start_date="cast('1871-01-01' as date)",
    end_date="cast('2050-01-01' as date)"
) }})

select 
cast(strftime(date_day, '%Y%m%d') as integer) as date_id,
date_day as "full_date",
YEAR(date_day)as "year_number",
month(date_day) as "month_number",
day(date_day) as "day_number",
dayname(date_day)as day_of_week,
year(date_day) in (1987, 1991, 1995, 1999, 2003, 2007, 2011, 2015, 2019, 2023, 2027) as is_world_cup_year,
from date_table_source