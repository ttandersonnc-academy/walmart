{{ config(
    materialized='table',
    transient=true,
    pre_hook=copy_csv(
        'DEPARTMENT',
        ['STORE','DEPT','DATE','WEEKLY_SALES','ISHOLIDAY'],
        var('dept_file_pattern')
    ),
    schema='BRONZE'
) }}

SELECT
    STORE::NUMBER          AS STORE,
    DEPT::NUMBER           AS DEPT,
    DATE::DATE             AS DATE,
    WEEKLY_SALES::NUMBER(18,2) AS WEEKLY_SALES,
    ISHOLIDAY::BOOLEAN     AS ISHOLIDAY,
    INSERT_DTS,
    UPDATE_DTS,
    SOURCE_FILE_NAME,
    SOURCE_FILE_ROW_NUMBER
<<<<<<< HEAD:models/bronze/department.sql
FROM {{ source('BRONZE', 'DEPARTMENT') }}
=======
FROM {{ source('landing', 'DEPARTMENT') }}
>>>>>>> fc6862e03a477d4ae88dc93854e62ba6f7f24fcf:models/raw_department.sql
