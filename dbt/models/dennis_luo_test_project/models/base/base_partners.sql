{{
    config(
        tags=["pii=false","model_type=base"],
        materialized='incremental',
        unique_key="id"
    )
}}

-- Get source data and convert unix nano to time format

WITH raw AS (
SELECT
    id,
    TIMESTAMP_SECONDS(CAST(created_at/1e9 AS INTEGER)) AS created_at,
    TIMESTAMP_SECONDS(CAST(updated_at/1e9 AS INTEGER)) AS updated_at,
    UPPER(partner_type) AS partner_type,
    UPPER(lead_sales_contact) AS lead_sales_contact

FROM
    {{ source('test', 'partners') }}

),

-- Deduplicate by the order ID to remove any duplicates

deduped AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY created_at DESC) AS rank_rev FROM raw)

SELECT
    *
EXCEPT
    (rank_rev)
FROM
    deduped
WHERE
    rank_rev = 1
