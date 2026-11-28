{#
    Silver: cleansed weekly sales by store and department.

    Reads the bronze `department` model and:
      1. renames columns to silver naming (store_id, dept_id, ...)
      2. drops rows missing any key column
      3. defaults missing values (weekly_sales -> 0, is_holiday -> false)
      4. flags negative sales (returns/markdowns) instead of dropping them
      5. de-duplicates on (store_id, dept_id, sales_date), keeping the most
         recently loaded row
    Loaded incrementally with MERGE, so re-runs update rows instead of
    duplicating them.
#}
{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key=['store_id', 'dept_id', 'sales_date'],
    merge_update_columns=['weekly_sales', 'is_holiday', 'is_negative_sales', 'source_file_name', 'update_dts'],
    alias='DEPARTMENT',
    schema='SILVER'
) }}

WITH source AS (

    SELECT * FROM {{ ref('department') }}

),

renamed AS (

    SELECT
        STORE                               AS store_id,
        DEPT                                AS dept_id,
        DATE                                AS sales_date,
        COALESCE(WEEKLY_SALES, 0)           AS weekly_sales,
        COALESCE(ISHOLIDAY, FALSE)          AS is_holiday,
        SOURCE_FILE_NAME                    AS source_file_name,
        SOURCE_FILE_ROW_NUMBER              AS source_file_row_number,
        INSERT_DTS                          AS bronze_insert_dts
    FROM source
    WHERE STORE IS NOT NULL
      AND DEPT  IS NOT NULL
      AND DATE  IS NOT NULL

),

deduped AS (

    -- Same store/dept/week can appear in more than one file; keep the latest
    SELECT *
    FROM renamed
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY store_id, dept_id, sales_date
        ORDER BY bronze_insert_dts DESC,
                 source_file_name DESC,
                 source_file_row_number DESC
    ) = 1

)

SELECT
    store_id,
    dept_id,
    sales_date,
    weekly_sales,
    is_holiday,
    weekly_sales < 0                            AS is_negative_sales,
    source_file_name,
    CURRENT_TIMESTAMP()::TIMESTAMP_NTZ          AS insert_dts,
    CURRENT_TIMESTAMP()::TIMESTAMP_NTZ          AS update_dts
FROM deduped

{% if is_incremental() %}
-- Only touch rows bronze has loaded since the last silver run
WHERE bronze_insert_dts > (SELECT COALESCE(MAX(update_dts), '1900-01-01'::TIMESTAMP_NTZ) FROM {{ this }})
{% endif %}
