require 'csv'

namespace :websites do
  desc ""
  task import: :environment do
    table = CSV.read("tmp/gsa-websites.csv", headers: true)

    table.each do |row|
      puts row["Public-Facing Sites/Domains"]

      website = {
        domain: row["Public-Facing Sites/Domains"],
        office: row["Office"],
        sub_office: row["Sub- office"],
        contact_email: row["Contact Email"],
        site_owner_email: row["Site Owner Email"],
        production_status: row["Production Status"],
        type_of_site: row["Type of Site"],
        digital_brand_category: row["Digital Brand Category"],
        redirects_to: row["Redirects to ..."],
        status_code: row["Status Code"],
        cms_platform: row["CMS/Platform"],
        required_by_law_or_policy: row["Required by law/policy?"],
        has_dap: row["Has DAP?"],
        cost_estimator_url: row["Cost Estimator"],
        modernization_plan_url: row["Mod Plan"],
        annual_baseline_cost: row["FY20 Baseline Cost"],
        modernization_cost: row["Total Mod Cost"],
        current_uswds_score: row["Current USWDS Score"],
        uses_feedback: row["Uses Feedback"],
        sitemap_url: row["Sitemap/ SEO"],
        mobile_friendly: row["Mobile Friendly"],
        has_search: row["Has Search"],
        uses_tracking_cookies: row["Uses Tracking Cookies"],
        has_authenticated_experience: row["Has Authenticated Experience"],
        notes: row["Notes"],
      }
      Website.create(website)
    end
  end
end
