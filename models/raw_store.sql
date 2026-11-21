{{ config(
    materialized='table',
    transient=true,
    pre_hook=copy_csv(
        'LND_STORE',
        ['STORE','TYPE','SIZE'],
        var('store_file_pattern')
    ),
    schema='BRONZE'
) }}

SELECT
    STORE::NUMBER  AS STORE,
    TYPE           AS TYPE,
    SIZE::NUMBER   AS SIZE,
    INSERT_DTS,
    UPDATE_DTS,
    SOURCE_FILE_NAME,
    SOURCE_FILE_ROW_NUMBER
FROM {{ source('landing', 'LND_STORE') }}
