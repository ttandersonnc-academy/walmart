{{
config
({
"materialized":'table',
"pre_hook": copy_csv('RAW_STORE'), 
"schema": 'BRONZE'
})
}}

SELECT
STORE AS STORE_ID,TYPE AS STORE_TYPE,SIZE AS STORE_SIZE
FROM RAW_STORE