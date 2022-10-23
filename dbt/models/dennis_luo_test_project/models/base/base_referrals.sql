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
    company_id,
    partner_id,
    consultant_id,
    status,
    CAST(is_outbound AS INTEGER) AS is_outbound

FROM
    {{ source('test', 'referrals') }}

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
