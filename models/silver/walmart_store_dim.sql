{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key=['store_id', 'dept_id'],
    merge_update_columns=['store_type','store_size','source_file_name','update_dts'],
    alias='walmart_store_dim',
    schema='SILVER'
) }}


WITH dept AS (

    SELECT * FROM {{ ref('department') }}

),

str AS (

    SELECT * FROM {{ ref('store') }}

),

joined AS (

     SELECT DISTINCT 
        s.store as store_id, 
        d.dept as dept_id,
        s.type as store_type, 
        s.size as store_size,
        d.source_file_name,
        d.source_file_row_number,
        d.insert_dts as bronze_insert_dts
    FROM dept d
    LEFT JOIN str s
        ON d.STORE = s.STORE

),


deduped AS (

    -- Same store/dept/week can appear in more than one file; keep the latest
    SELECT *
    FROM joined
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY store_id, dept_id, store_type, store_size
        ORDER BY bronze_insert_dts DESC,
                 source_file_name DESC,
                 source_file_row_number DESC
    ) = 1

)

SELECT
    store_id 
    ,dept_id
    ,store_type
    ,store_size
    ,CURRENT_TIMESTAMP()::TIMESTAMP_NTZ          AS insert_dts
    ,CURRENT_TIMESTAMP()::TIMESTAMP_NTZ          AS update_dts
FROM deduped

{% if is_incremental() %}
-- Only touch rows bronze has loaded since the last silver run
 WHERE bronze_insert_dts > (SELECT COALESCE(MAX(update_dts), '1900-01-01'::TIMESTAMP_NTZ) FROM {{ this }})
{% endif %}

