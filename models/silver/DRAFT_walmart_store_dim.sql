{{ config(
    materialized='incremental',
    schema='SILVER',
    materialized='incremental', 
    incremental_strategy='merge', 
    unique_key=['store_id','dept_id'] ,
    merge_update_columns=['store_type','store_size','update_date']
) }}

SELECT DISTINCT STORE, DEPT FROM ref('raw_department')