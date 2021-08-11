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

    ServiceProvider.includes(:organization).order("organizations.name", :name).each do |hisp|
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
end
