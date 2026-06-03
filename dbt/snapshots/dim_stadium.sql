{% snapshot dim_stadium %}

{{
    config(
        unique_key='stadium_id',
        strategy='check',
        check_cols=['name', 'country_name']
    )
}}

SELECT
    t.stadium_id,
    t.name,
    c.country AS country_name,
    t.run_id,
    t.pipeline_id,
    t.silver_3nf_processed,
    t.silver_source_processed,
    t.bronze_raw_date_ingested,
    t.bronze_landing_date_ingested,
    t.bronze_source
FROM {{ source('silver_3nf', 'stadium') }} t
LEFT JOIN {{ source('silver_3nf', 'country') }} c
    ON t.country_id = c.country_id

{% endsnapshot %}