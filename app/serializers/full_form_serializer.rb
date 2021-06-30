class FullFormSerializer < ActiveModel::Serializer

  attributes :page_num, :page_size

  def page_num
    @instance_options[:page_num]
  end

  def page_size
    @instance_options[:page_size]
  end

  attributes :id,
    :name,
    :title,
    :instructions,
    :disclaimer_text,
    :kind,
    :notes,
    :status,
    :created_at,
    :updated_at,
    :whitelist_url,
    :whitelist_test_url,
    :display_header_logo,
    :success_text_heading,
    :success_text,
    :modal_button_text,
    :display_header_square_logo,
    :early_submission,
    :user_id,
    :template,
    :uuid,
    :short_uuid,
    :organization_id,
    :omb_approval_number,
    :expiration_date,
    :medium,
    :federal_register_url,
    :anticipated_delivery_count,
    :service_name,
    :data_submission_comment,
    :survey_instrument_reference,
    :agency_poc_email,
    :agency_poc_name,
    :department,
    :bureau,
    :notification_emails,
    :start_date,
    :end_date,
    :aasm_state,
    :delivery_method,
    :element_selector,
    :survey_form_activations,
    :load_css,
    :logo,
    :time_zone,
    :response_count,
    :last_response_created_at

  has_many :questions
  has_many :submissions

  def submissions
    object.submissions.limit(page_size).offset(page_size * page_num)
  end
end
