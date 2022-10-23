{{
  config(
    tags=[
    "model_type=staging",
    "pii=false",
    "critical=true",
    ],
    unique_key="id"
  )
}}

-- Merge sales_country with partners table

WITH sales_partner AS (
  SELECT
    partners.*,
    COALESCE(sales_people.country, "NONE") AS sales_country

  FROM {{ ref("base_partners") }} as partners
  LEFT JOIN {{ ref("base_sales_people") }} as sales_people 
  ON partners.lead_sales_contact = sales_people.name
)

SELECT
  *

FROM sales_partner

