class CreateAdminWebsites < ActiveRecord::Migration[6.1]
  def change
    create_table :websites do |t|
      t.string :domain
      t.string :parent_domain
      t.string :office
      t.integer :office_id
      t.string :sub_office
      t.integer :suboffice_id
      t.string :contact_email
      t.string :site_owner_email
      t.string :production_status
      t.string :type_of_site
      t.string :digital_brand_category
      t.string :redirects_to
      t.string :status_code
      t.string :cms_platform
      t.string :required_by_law_or_policy
      t.boolean :has_dap
      t.string :dap_gtm_code
      t.string :cost_estimator_url
      t.string :modernization_plan_url
      t.float :annual_baseline_cost
      t.float :modernization_cost
      t.string :analytics_url
      t.integer :current_uswds_score
      t.boolean :uses_feedback
      t.string :feedback_tool
      t.string :sitemap_url
      t.boolean :mobile_friendly
      t.boolean :has_search
      t.boolean :uses_tracking_cookies
      t.boolean :has_authenticated_experience
      t.string :authentication_tool
      t.text :notes

      t.timestamps
    end
  end
end
