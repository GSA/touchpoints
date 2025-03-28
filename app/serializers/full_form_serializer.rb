# frozen_string_literal: true

class FullFormSerializer < ActiveModel::Serializer
  attributes :page, :size, :start_date, :end_date

  def page
    @instance_options[:page]
  end

  def size
    @instance_options[:size]
  end

  def start_date
    @instance_options[:start_date]
  end

  def end_date
    @instance_options[:end_date]
  end

  def links
    @instance_options[:links]
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
             :whitelist_url_1,
             :whitelist_url_2,
             :whitelist_url_3,
             :whitelist_url_4,
             :whitelist_url_5,
             :whitelist_url_6,
             :whitelist_url_7,
             :whitelist_url_8,
             :whitelist_url_9,
             :whitelist_test_url,
             :display_header_logo,
             :success_text_heading,
             :success_text,
             :modal_button_text,
             :display_header_square_logo,
             :early_submission,
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
    object.submissions.order(:id).where('created_at BETWEEN ? AND ?', start_date, end_date).limit(size).offset(size * page)
  end
end
