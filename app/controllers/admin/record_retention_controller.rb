# frozen_string_literal: true

require 'csv'

module Admin
  class RecordRetentionController < AdminController
    before_action :ensure_admin

    def index
      @forms_to_delete = Form.forms_whose_retention_period_has_passed
                             .includes(user_roles: { user: [] })
                             .order(:name)
    end

    def export_form_managers
      form_manager_emails = Form.forms_whose_retention_period_has_passed
                        .flat_map(&:form_managers)
                        .map(&:email)
                        .sort
                        .uniq
      csv_content = CSV.generate(headers: false) do |csv|
        form_manager_emails.each { |email| csv << [email] }
      end
      send_data csv_content, filename: "record-retention-form-manager-emails-#{timestamp_string}.csv"
    end
  end
end
