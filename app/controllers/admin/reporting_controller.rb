class Admin::ReportingController < AdminController
  def hisps
    row = []
    header_fields = [
        :department,
        :department_abbreviation,
        :service_provider_id,
        :name,
        :description,
        :notes,
        :new_hisp
      ]

    row << header_fields.join(",")

    ServiceProvider.active.includes(:organization).order("organizations.name", :name).each do |hisp|
    row_fields = [
        hisp.organization.name,
        hisp.organization.abbreviation.downcase,
        hisp.slug,
        "\"#{hisp.name}\"",
        "\"#{hisp.description}\"",
        "\"#{hisp.notes}\"",
        hisp.new,
      ]
      row << row_fields.join(",")
    end

    render plain: row.join("\n")
  end

  def lifespan
    @form_lifespans = Submission.select("form_id, count(*) as num_submissions, (max(submissions.created_at) - min(submissions.created_at)) as lifespan").group(:form_id)
    @forms = Form.select(:id,:name,:organization_id,:uuid).where("exists (select id, uuid from submissions where submissions.form_id = forms.id)")
    @orgs = Organization.all.order(:name)
    @org_summary = []
    @orgs.each do | org |
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
      org_row[:avg_lifespan] = org_row[:forms].size > 0 ? (total_lifespan / org_row[:forms].size) : 0
      @org_summary << org_row
    end
  end

  def no_submissions
    @forms = Form.live.select(:id,:name,:organization_id,:uuid).where("not exists (select id, uuid from submissions where submissions.form_id = forms.id and submissions.created_at > current_date - interval '30' day)").order(:organization_id)
    @orgs = Organization.all.order(:name)
    @org_summary = []
    @orgs.each do | org |
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
end
