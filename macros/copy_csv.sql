{#
    Reloads a BRONZE landing table from CSV files in the S3 stage.

    table_nm     : target table in target_db.target_schema (e.g. 'RAW_DEPARTMENT')
    columns      : ordered list of column names, matching the CSV column order
    file_pattern : regex selecting which files in the stage to load
#}
{% macro copy_csv(table_nm, columns, file_pattern) %}

DELETE FROM {{ var('target_db') }}.{{ var('target_schema') }}.{{ table_nm }};

COPY INTO {{ var('target_db') }}.{{ var('target_schema') }}.{{ table_nm }}
FROM
(
SELECT
{%- for col in columns %}
${{ loop.index }} AS {{ col }}{{ "," if not loop.last }}
{%- endfor %}
FROM @{{ var('stage_name') }}
)
PATTERN = '{{ file_pattern }}'
FILE_FORMAT = (FORMAT_NAME = '{{ var("file_format_csv") }}')
FORCE = TRUE;

{% endmacro %}
