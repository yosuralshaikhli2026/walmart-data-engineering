
{{
    config(
        materialized='incremental',
        incremental_strategy='merge',
        unique_key=['STORE_ID', 'DEPT_ID'],
        merge_update_columns=[
            'STORE_TYPE',
            'STORE_SIZE',
            'UPDATE_DATE'
        ]
    )
}}

SELECT
    s.STORE_ID,
    s.DEPT_ID,
    s.STORE_TYPE,
    s.STORE_SIZE,
    CURRENT_TIMESTAMP() AS INSERT_DATE,
    CURRENT_TIMESTAMP() AS UPDATE_DATE

FROM {{ ref('stg_walmart_stores') }} s

{% if is_incremental() %}

LEFT JOIN {{ this }} t
    ON s.STORE_ID = t.STORE_ID
   AND s.DEPT_ID = t.DEPT_ID

WHERE t.STORE_ID IS NULL
   OR s.STORE_TYPE IS DISTINCT FROM t.STORE_TYPE
   OR s.STORE_SIZE IS DISTINCT FROM t.STORE_SIZE

{% endif %}
