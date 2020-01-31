class CreatePraRecords < ActiveRecord::Migration[5.2]

  def change
    create_table :pra_records do |t|

      t.integer "form_id"
      t.string "omb_approval_number"
      t.date "expiration_date"
      t.string "medium"
      t.string "federal_register_url"
      t.integer "anticipated_delivery_count", default: 0
      t.boolean "hisp", default: false
      t.string "service_name"
      t.text "data_submission_comment"
      t.string "survey_instrument_reference"
      t.string "agency_poc_email"
      t.string "agency_poc_name"
      t.string "department"
      t.string "bureau"

      t.timestamps
    end

    add_column :forms, :uuid, :string
    add_index :forms, :uuid
    add_column :forms, :notification_emails, :string
    add_column :forms, :start_date, :datetime
    add_column :forms, :end_date, :datetime
    add_column :forms, :aasm_state, :string
    add_column :forms, :delivery_method, :string
    add_column :forms, :element_selector, :string


    Touchpoint.all.each do |touchpoint|
      # Migrate Touchpoint data to the Form
      form = touchpoint.form
      # Use the existing Form's name
      # The Touchpoint name will be discarded.
      form.notification_emails = touchpoint.notification_emails
      form.start_date = touchpoint.start_date
      form.end_date = touchpoint.end_date
      form.uuid = touchpoint.uuid
      form.aasm_state = touchpoint.aasm_state
      form.delivery_method = touchpoint.delivery_method
      form.element_selector = touchpoint.element_selector
      form.save

      # Migrate Touchpoint data to the associated PRA Record
      pra_record = PraRecord.new
      pra_record.form_id = touchpoint.form_id
      pra_record.omb_approval_number = touchpoint.omb_approval_number
      pra_record.expiration_date = touchpoint.expiration_date
      pra_record.medium = touchpoint.medium
      pra_record.federal_register_url = touchpoint.federal_register_url
      pra_record.anticipated_delivery_count = touchpoint.anticipated_delivery_count
      pra_record.hisp = touchpoint.hisp
      pra_record.service_name = touchpoint.service_name
      pra_record.data_submission_comment = touchpoint.data_submission_comment
      pra_record.survey_instrument_reference = touchpoint.survey_instrument_reference
      pra_record.agency_poc_email = touchpoint.agency_poc_email
      pra_record.agency_poc_name = touchpoint.agency_poc_name
      pra_record.department = touchpoint.department
      pra_record.bureau = touchpoint.bureau
      pra_record.save!
    end

  end
end
