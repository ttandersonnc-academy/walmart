{{ config(
    materialized='table',
    transient=true,
    pre_hook=copy_csv(
        'STORE',
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
<<<<<<< HEAD:models/bronze/store.sql
FROM {{ source('BRONZE', 'STORE') }}
=======
FROM {{ source('landing', 'STORE') }}
>>>>>>> fc6862e03a477d4ae88dc93854e62ba6f7f24fcf:models/raw_store.sql
