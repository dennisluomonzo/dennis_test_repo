{{
  config(
    tags=[
      "model_type=entity",
      "pii=false",
      "critical=true",
      "run=nightly",
    ],
    unique_key="id"
  )
}}

-- Partner level stats

WITH referral_sales_partner AS (
  SELECT
    partner_id,  
    partner_type, 
    lead_sales_contact, 
    sales_country, 
    COUNT(*) AS number_of_references,
    SUM(CASE status WHEN 'pending' THEN 1 ELSE 0 END) AS number_of_pending,
    SUM(CASE status WHEN 'disinterested' THEN 1 ELSE 0 END) AS number_of_disinterested,
    SUM(CASE status WHEN 'successful' THEN 1 ELSE 0 END) AS number_of_signups,
    MAX(CASE status WHEN 'successful' THEN updated_at ELSE NULL END) AS latest_successful_referral,
    SUM(is_outbound) AS number_of_upsell,

  FROM {{ ref("stg_referral_sales_partner") }} 
  GROUP BY partner_id, partner_type, lead_sales_contact, sales_country
),

-- Aggregate companies under each partner which were successul as this counts as one referral
partner_referrals AS (
  SELECT
    partner_id,
    company_id
  FROM {{ ref("stg_referral_sales_partner") }}
  WHERE status = 'successful'
  GROUP BY partner_id, company_id
),

partner_referrals_stats AS (
  SELECT
    partner_id,
    COUNT(partner_id) AS number_of_successful_referrals,
  FROM partner_referrals
  GROUP BY partner_id
),

-- Join to stg_sales_partner to get full partner list for stats table
partner_stats AS (
  SELECT
    sales_partner.id AS partner_id,
    sales_partner.partner_type,
    sales_partner.lead_sales_contact,
    sales_partner.sales_country,    
    COALESCE(referral_sales_partner.number_of_references, 0) AS number_of_references,
    COALESCE(referral_sales_partner.number_of_pending, 0) AS number_of_pending,
    COALESCE(referral_sales_partner.number_of_disinterested, 0) AS number_of_disinterested,
    COALESCE(referral_sales_partner.number_of_signups, 0) AS number_of_signups,
    COALESCE(referral_sales_partner.latest_successful_referral, NULL) AS latest_successful_referral,
    COALESCE(referral_sales_partner.number_of_upsell, 0) AS number_of_upsell,
    COALESCE(partner_referrals_stats.number_of_successful_referrals, 0) AS number_of_successful_referrals

  FROM {{ ref("stg_sales_partner") }} AS sales_partner
  LEFT JOIN referral_sales_partner
  ON sales_partner.id = referral_sales_partner.partner_id
  LEFT JOIN partner_referrals_stats
  ON sales_partner.id = partner_referrals_stats.partner_id
)

SELECT
  *

FROM partner_stats







