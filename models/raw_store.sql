{{
config
({
"materialized":'table',
"pre_hook": copy_csv('RAW_STORE'), 
"schema": 'BRONZE'
})
}}

SELECT
STORE,TYPE,SIZE
FROM RAW_DEPARTMENT