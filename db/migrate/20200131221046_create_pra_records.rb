class CreatePraRecords < ActiveRecord::Migration[5.2]

  def change

    add_column :forms, :uuid, :string
    add_index :forms, :uuid

    add_column :forms, :organization_id, :integer
    add_column :forms, :hisp, :boolean
    add_column :forms, :omb_approval_number, :string
    add_column :forms, :expiration_date, :date
    add_column :forms, :medium, :string
    add_column :forms, :federal_register_url, :string
    add_column :forms, :anticipated_delivery_count, :integer
    add_column :forms, :service_name, :string
    add_column :forms, :data_submission_comment, :text
    add_column :forms, :survey_instrument_reference, :string
    add_column :forms, :agency_poc_email, :string
    add_column :forms, :agency_poc_name, :string
    add_column :forms, :department, :string
    add_column :forms, :bureau, :string

    add_column :forms, :notification_emails, :string
    add_column :forms, :start_date, :datetime
    add_column :forms, :end_date, :datetime
    add_column :forms, :aasm_state, :string
    add_column :forms, :delivery_method, :string
    add_column :forms, :element_selector, :string
    add_column :forms, :survey_form_activations, :integer, default: 0

    add_column :forms, :legacy_touchpoint_id, :integer
    add_column :forms, :legacy_touchpoint_uuid, :string
    add_index :forms, :legacy_touchpoint_id
    add_index :forms, :legacy_touchpoint_uuid

    add_column :submissions, :form_id, :integer
    change_column_null :submissions, :touchpoint_id, true

    # Update Touchpoint -> Form
    # Update Organization -> Form
    Touchpoint.all.each do |touchpoint|
      next unless touchpoint.form.present?
      # Migrate Touchpoint data to the Form
      form = touchpoint.form
      # Use the existing Form's name
      # The Touchpoint name will be discarded.
      form.legacy_touchpoint_id = touchpoint.id
      form.legacy_touchpoint_uuid = touchpoint.uuid

      form.organization_id = touchpoint.organization_id
      form.notification_emails = touchpoint.notification_emails
      form.start_date = touchpoint.start_date
      form.end_date = touchpoint.end_date
      form.aasm_state = touchpoint.aasm_state
      form.delivery_method = touchpoint.delivery_method
      form.element_selector = touchpoint.element_selector
      form.survey_form_activations = touchpoint.survey_form_activations

      # Migrate Touchpoint data to the associated PRA Record
      form.omb_approval_number = touchpoint.omb_approval_number
      form.expiration_date = touchpoint.expiration_date
      form.medium = touchpoint.medium
      form.federal_register_url = touchpoint.federal_register_url
      form.anticipated_delivery_count = touchpoint.anticipated_delivery_count
      form.hisp = touchpoint.hisp
      form.service_name = touchpoint.service_name
      form.data_submission_comment = touchpoint.data_submission_comment
      form.survey_instrument_reference = touchpoint.survey_instrument_reference
      form.agency_poc_email = touchpoint.agency_poc_email
      form.agency_poc_name = touchpoint.agency_poc_name
      form.department = touchpoint.department
      form.bureau = touchpoint.bureau
      form.save!
    end

    # Update Submission -> Form
    Touchpoint.all.each do |touchpoint|
      next unless touchpoint.form.present?

      touchpoint.submissions.update_all(form_id: touchpoint.form.id)
    end

    # Update UserRole -> Form
    UserRole.all.each do |role|
      next unless role.touchpoint && role.touchpoint.form.present?

      role.form_id = role.touchpoint.form_id
      if role.role == UserRole::Role::TouchpointManager
        role.role = UserRole::Role::FormManager
      end
      role.save!
    end
  end
end
