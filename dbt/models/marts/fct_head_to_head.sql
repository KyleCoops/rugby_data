
{{ config(materialized='table') }}

with enriched_matches as (
SELECT 
m.match_date,
ht.name as home_team,
awt.name as away_team,
m.home_score,
m.away_score,
s.name as stadium_name
FROM {{ source('silver_3nf', 'match') }} m
join {{ source('silver_3nf', 'stadium') }} s on s.stadium_id=m.stadium_id 
join {{ source('silver_3nf', 'team') }} ht on ht.team_id=m.home_team_id
join {{ source('silver_3nf', 'team') }} awt on awt.team_id=m.away_team_id),

mirror_source as (
SELECT 
m.match_date,
m.home_team as team,
m.away_team as opponent,
m.stadium_name as stadium_name,
m.home_score as points_for,
m.away_score as points_against
FROM enriched_matches m
UNION ALL
SELECT 
m.match_date,
m.away_team as team,
m.home_team as opponent,
m.stadium_name as stadium_name,
m.away_score as points_for,
m.home_score as points_against
FROM enriched_matches m
),

add_dims as (
select
dd.date_id as match_date_sk,
ht.dbt_scd_id as team_sk,
awt.dbt_scd_id as opponent_sk,
ds.stadium_id as stadium_sk,
ms.points_for as points_for,
ms.points_against as points_against
from mirror_source ms
join {{ ref('dim_stadium') }} ds on ds.name=ms.stadium_name
join {{ ref('dim_team') }} ht on ht.name=ms.team
--  and ms.match_date >= ht.dbt_valid_from
--  and (ms.match_date < ht.dbt_valid_to or ht.dbt_valid_to is null)
join {{ ref('dim_team') }} awt on awt.name=ms.opponent
--  and ms.match_date >= awt.dbt_valid_from
--  and (ms.match_date < awt.dbt_valid_to or awt.dbt_valid_to is null)
join {{ ref('dim_date') }} dd on dd.full_date=ms.match_date)

select * from add_dims