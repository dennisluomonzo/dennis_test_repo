{{
  config(
    tags=[
    "model_type=staging",
    "pii=false",
    "critical=true"
    ],
    unique_key="id"
  )
}}

-- Merge sales_partner table with referral table

WITH referral_sales_partner AS (
  SELECT
    referrals.*,
    EXTRACT(MONTH FROM referrals.updated_at) AS referral_month,
    EXTRACT(YEAR FROM referrals.updated_at) AS referral_year,
    sales_partner.partner_type,
    sales_partner.lead_sales_contact,
    sales_partner.sales_country

  FROM {{ ref("base_referrals") }} as referrals
  LEFT JOIN {{ ref("stg_sales_partner") }} as sales_partner
  ON referrals.partner_id = sales_partner.id

)

SELECT
  *

FROM referral_sales_partner

