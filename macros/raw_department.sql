{% macro copy_csv(table_nm) %} 

DELETE FROM {{var ('target_db') }}.{{var ('target_schema')}}.{{ table_nm }}; 

COPY INTO {{var ('target_db') }}.{{var ('target_schema')}}.{{ table_nm }}
FROM
(
SELECT 
$1 as STORE,
$2 as DEPT,
$3 as DATE,
$4 AS WEEKLY_SALES,
$5 AS ISHOLIDAY,
$6 AS INSERT_DTS,
$7 AS UPDATE_DTS,
$8 AS SOURCE_FILE_NAME,
$9 AS SOURCE_FILE_ROW_NUMBER
FROM @{{var('dept_name')}}
)
FILE_FORMAT = {{var ('file_format_csv') }}
FORCE = TRUE;

{% endmacro %}