{#
    Reloads a landing table from CSV files in the S3 stage.

    The landing table is separate from the dbt model that reads it, so the
    model can be rebuilt freely and the first run works (the landing table
    is created here if it doesn't exist yet).

    landing_table : landing table in target_db.target_schema (e.g. 'LND_DEPARTMENT')
    columns       : ordered list of column names, matching the CSV column order.
                    Landed as VARCHAR; the model casts them to proper types.
    file_pattern  : regex selecting which files in the stage to load

    Audit columns are filled from load metadata, not from the CSV:
    INSERT_DTS, UPDATE_DTS, SOURCE_FILE_NAME, SOURCE_FILE_ROW_NUMBER.
#}
{% macro copy_csv(landing_table, columns, file_pattern) %}

{%- set tbl = var('target_db') ~ '.' ~ var('target_schema') ~ '.' ~ landing_table -%}

CREATE TRANSIENT TABLE IF NOT EXISTS {{ tbl }} (
{%- for col in columns %}
    {{ col }} VARCHAR,
{%- endfor %}
    INSERT_DTS TIMESTAMP_NTZ,
    UPDATE_DTS TIMESTAMP_NTZ,
    SOURCE_FILE_NAME VARCHAR,
    SOURCE_FILE_ROW_NUMBER NUMBER
);

TRUNCATE TABLE {{ tbl }};

COPY INTO {{ tbl }}
FROM
(
SELECT
{%- for col in columns %}
    ${{ loop.index }} AS {{ col }},
{%- endfor %}
    CURRENT_TIMESTAMP()::TIMESTAMP_NTZ AS INSERT_DTS,
    CURRENT_TIMESTAMP()::TIMESTAMP_NTZ AS UPDATE_DTS,
    METADATA$FILENAME AS SOURCE_FILE_NAME,
    METADATA$FILE_ROW_NUMBER AS SOURCE_FILE_ROW_NUMBER
FROM @{{ var('stage_name') }}
)
PATTERN = '{{ file_pattern }}'
FILE_FORMAT = (FORMAT_NAME = '{{ var("file_format_csv") }}')
FORCE = TRUE;

{% endmacro %}
