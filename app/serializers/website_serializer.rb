# frozen_string_literal: true

class WebsiteSerializer < ActiveModel::Serializer
  attributes :id,
             :domain,
             :parent_domain,
             :office,
             # :office_id,
             :sub_office,
             # :suboffice_id,
             :contact_email,
             :site_owner_email,
             :production_status,
             :type_of_site,
             :digital_brand_category,
             :redirects_to,
             :status_code,
             :cms_platform,
             :required_by_law_or_policy,
             :has_dap,
             :dap_gtm_code,
             # :cost_estimator_url,
             # :modernization_plan_url,
             # :annual_baseline_cost,
             # :modernization_cost,
             :analytics_url,
             :uses_feedback,
             :feedback_tool,
             :sitemap_url,
             :mobile_friendly,
             :has_search,
             :uses_tracking_cookies,
             :has_authenticated_experience,
             :authentication_tool,
             :login_supported,
             :notes,
             :repository_url,
             :hosting_platform,
             # :modernization_cost_2021,
             # :modernization_cost_2022,
             # :modernization_cost_2023,
             :website_contacts,
             :uswds_version,
             :https,
             :created_at,
             :updated_at

  def website_contacts
    ActiveModel::Serializer::CollectionSerializer.new(object.website_managers, serializer: UserSerializer)
  end
end
