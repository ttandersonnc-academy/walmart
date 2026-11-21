{{ config(
    materialized='table',
    schema='BRONZE'
) }}

SELECT STORE,TYPE,SIZE
FROM RAW_STORE

