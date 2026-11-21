{{ config(
    materialized='table',
    transient=true,
    pre_hook=copy_csv(
        'RAW_STORE',
        ['STORE','TYPE','SIZE','INSERT_DTS','UPDATE_DTS','SOURCE_FILE_NAME','SOURCE_FILE_ROW_NUMBER'],
        var('store_file_pattern')
    ),
    schema='BRONZE'
) }}

SELECT STORE,TYPE,SIZE
FROM RAW_STORE
