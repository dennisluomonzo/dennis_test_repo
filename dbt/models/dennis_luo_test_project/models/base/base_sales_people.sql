{{
    config(
        tags=["pii=false","model_type=base"],
        materialized='incremental',
        unique_key="name"
    )
}}

-- Get source data and convert unix nano to time format

WITH raw AS (
SELECT
    UPPER(name) AS name,
    UPPER(country) AS country

FROM
    {{ source('test', 'sales_people') }}

),
-- Deduplicate by the name to remove any duplicates

deduped AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY name ORDER BY country DESC) AS rank_rev FROM raw)

SELECT
    *
EXCEPT
    (rank_rev)
FROM
    deduped
WHERE
    rank_rev = 1