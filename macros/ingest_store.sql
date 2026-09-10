{% macro copy_csv(table_nm) %} 

DELETE FROM {{var ('target_db') }}.{{var ('target_schema')}}.{{ table_nm }}; 

COPY INTO {{var ('target_db') }}.{{var ('target_schema')}}.{{ table_nm }}
FROM
(
SELECT 
$1 as STORE,
$2 as TYPE,
$3 as SIZE,
$4 AS INSERT_DTS,
$5 AS UPDATE_DTS,
$6 AS SOURCE_FILE_NAME,
$7 AS SOURCE_FILE_ROW_NUMBER
FROM @{{var('store_name')}}
)
FILE_FORMAT = {{var ('file_format_csv') }}
FORCE = TRUE;

{% endmacro %}