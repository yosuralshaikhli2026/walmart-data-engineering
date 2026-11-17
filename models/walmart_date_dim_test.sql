
{{
    config(
        materialized='incremental',
        incremental_strategy='merge',
        unique_key='DATE_ID',
        merge_update_columns=['ISHOLIDAY', 'UPDATE_DATE']
    )
}}

SELECT
    s.DATE_ID,
    TO_DATE(s.STORE_DATE) AS STORE_DATE,
    s.ISHOLIDAY,
    CURRENT_TIMESTAMP() AS INSERT_DATE,
    CURRENT_TIMESTAMP() AS UPDATE_DATE

FROM {{ ref('test_walmart_dates') }} s
{% if is_incremental() %}

LEFT JOIN {{ this }} t
    ON s.DATE_ID = t.DATE_ID

WHERE t.DATE_ID IS NULL
   OR s.ISHOLIDAY IS DISTINCT FROM t.ISHOLIDAY

{% endif %}