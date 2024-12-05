# frozen_string_literal: true

module Admin
  class ReportingController < AdminController
    def index; end

    def hisps
      send_data ServiceProvider.to_csv, filename: "touchpoints-service-providers-#{Date.today}.csv"
    end

    def lifespan
      @form_lifespans = Submission.select('form_id, count(*) as num_submissions, (max(submissions.created_at) - min(submissions.created_at)) as lifespan').group(:form_id)
      @forms = Form.select(:id, :name, :organization_id, :uuid, :short_uuid).where('exists (select id from submissions where submissions.form_id = forms.id)')
      @orgs = Organization.order(:name)
      @org_summary = []
      @orgs.each do |org|
        org_row = {}
        org_row[:name] = org.name
        org_row[:forms] = []
        total_lifespan = 0
        total_submissions = 0
        @forms.select { |form| form.organization_id == org.id }.each do |org_form|
          form_summary = {}
          form_summary[:id] = org_form.id
          form_summary[:name] = org_form.name
          form_summary[:short_uuid] = org_form.short_uuid
          form_summary[:counts] = @form_lifespans.select { |row| row.form_id == org_form.id }.first
          total_lifespan += form_summary[:counts].lifespan if form_summary[:counts].present?
          total_submissions += form_summary[:counts].num_submissions if form_summary[:counts].present?
          org_row[:forms] << form_summary
        end
        org_row[:submissions] = total_submissions
        org_row[:avg_lifespan] = org_row[:forms].size.positive? ? (total_lifespan / org_row[:forms].size) : 0
        @org_summary << org_row
      end
    end

    def no_submissions
      @forms = Form.published.select(:id, :name, :organization_id, :uuid, :short_uuid).where("not exists (select id, uuid from submissions where submissions.form_id = forms.id and submissions.created_at > current_date - interval '30' day)").order(:organization_id)
      @orgs = Organization.order(:name)
      @org_summary = []
      @orgs.each do |org|
        org_row = {}
        org_row[:name] = org.name
        org_row[:forms] = []
        @forms.select { |form| form.organization_id == org.id }.each do |org_form|
          form_summary = {}
          form_summary[:id] = org_form.id
          form_summary[:name] = org_form.name
          form_summary[:short_uuid] = org_form.short_uuid
          org_row[:forms] << form_summary
        end
        @org_summary << org_row
      end
    end

    def service_surveys
      @services = Service.includes(:organization, :forms).order('organizations.name, services.name')
    end

    def users
      @users_who_need_accounts = []
      Website.where('site_owner_email IS NOT NULL OR contact_email IS NOT NULL').find_each do |website|
        if website.site_owner_email.present?
          user = User.find_by_email(website.site_owner_email)
          @users_who_need_accounts << website.site_owner_email if user.nil?
        end

        if website.contact_email.present?
          user2 = User.find_by_email(website.contact_email)
          @users_who_need_accounts << website.contact_email if user2.nil?
        end

        @users_who_need_accounts.uniq!
      end
    end

    def form_whitelist
      @forms = Form.order(:created_at).includes(:organization)
    end

    def form_logos
      @forms = Form.where.not(logo: nil)
    end
  end
end
