# frozen_string_literal: true

require 'kramdown'

module ApplicationHelper
  def suppress_main_layout_flash?
    return true if flash && ['User successfully added', 'User successfully removed'].include?(flash.notice)
  end

  def to_markdown(text)
    return nil if text.blank?

    raw(sanitize(Kramdown::Document.new(text).to_html))
  end

  def organization_dropdown_options
    Organization.all.order(:name).map { |org| ["#{org.abbreviation} - #{org.name}", org.id] }
  end

  def hisp_questions_key
    {
      '1' => 'satisfaction',
      '2' => 'trust',
      '3' => 'effectiveness',
      '4' => 'ease',
      '5' => 'efficiency',
      '6' => 'transparency',
      '7' => 'employee',
    }
  end

  def collection_rating_label(rating:)
    case rating
    when 'TRUE'
      '🟢'
    when 'FALSE'
      '🔴'
    when 'PARTIAL'
      '🟡'
    end
  end

  # key = a Collection.rating
  # value = sort order
  def collection_rating_sort_values
    {
      'FALSE' => '1',
      'PARTIAL' => '2',
      'TRUE' => '3',
    }
  end

  # key = a Service.aasm_state
  # value = sort order
  def service_status_sort_values
    {
      'created' => '1',
      'submitted' => '2',
      'approved' => '3',
      'verified' => '4',
      'archived' => '5',
    }
  end

  # key = a Website.production_status
  # value = sort order
  def website_status_sort_values
    {
      'newly_requested' => '1',
      'request_approved' => '2',
      'request_denied' => '3',
      'in_development' => '4',
      'production' => '5',
      'being_decommissioned' => '6',
      'redirect' => '7',
      'archived' => '8',
      'decommissioned' => '9',
    }
  end

  def website_status_label_tags(status)
    {
      'newly_requested' => 'bg-primary-light',
      'request_approved' => 'bg-primary',
      'request_denied' => 'bg-red',
      'in_development' => 'bg-blue',
      'production' => 'bg-mint',
      'being_decommissioned' => 'bg-accent-warm-dark',
      'redirect' => 'bg-accent-warm-light',
      'archived' => 'bg-gray-30',
      'decommissioned' => 'bg-black',
    }[status]
  end

  # Returns javascript to capture form input for one Form Question
  def question_type_javascript_params(question)
    if question.question_type == 'text_field'
      "form.querySelector(\"##{question.answer_field}\") && form.querySelector(\"##{question.answer_field}\").value"
    elsif question.question_type == 'hidden_field'
      "form.querySelector(\"##{question.answer_field}\") && form.querySelector(\"##{question.answer_field}\").value"
    elsif question.question_type == 'date_select'
      "form.querySelector(\"##{question.answer_field}\") && form.querySelector(\"##{question.answer_field}\").value"
    elsif question.question_type == 'text_email_field'
      "form.querySelector(\"##{question.answer_field}\") && form.querySelector(\"##{question.answer_field}\").value"
    elsif question.question_type == 'text_phone_field'
      "form.querySelector(\"##{question.answer_field}\") && form.querySelector(\"##{question.answer_field}\").value"
    elsif question.question_type == 'textarea'
      "form.querySelector(\"##{question.answer_field}\") && form.querySelector(\"##{question.answer_field}\").value"
    elsif question.question_type == 'radio_buttons'
      "form.querySelector(\"input[name=#{question.answer_field}]:checked\") && form.querySelector(\"input[name=#{question.answer_field}]:checked\").value"
    elsif question.question_type == 'star_radio_buttons'
      "form.querySelector(\"input[name=#{question.answer_field}]:checked\") && form.querySelector(\"input[name=#{question.answer_field}]:checked\").value"
    elsif question.question_type == 'thumbs_up_down_buttons'
      "form.querySelector(\"input[name=#{question.answer_field}]:checked\") && form.querySelector(\"input[name=#{question.answer_field}]:checked\").value"
    elsif question.question_type == 'yes_no_buttons'
      "form.querySelector(\"input[name=#{question.answer_field}]\") && form.querySelector(\"input[name=#{question.answer_field}]\").value"
    elsif question.question_type == 'checkbox'
      "form.querySelector(\"input[name=#{question.answer_field}]:checked\") && Array.apply(null,form.querySelectorAll(\"input[name=#{question.answer_field}]:checked\")).map(function(x) {return x.value;}).join(',')"
    elsif %w[dropdown states_dropdown].include?(question.question_type)
      "form.querySelector(\"##{question.answer_field}\") && form.querySelector(\"##{question.answer_field}\").value"
    elsif question.question_type == 'text_display'
      'null'
    elsif question.question_type == 'custom_text_display'
      "form.querySelector(\"input[name=#{question.answer_field}]:checked\") && form.querySelector(\"input[name=#{question.answer_field}]:checked\").value"
    end
  end

  def is_at_least_form_manager?(user:, form:)
    user.admin? ||
      form.user_role?(user:) == UserRole::Role::FormManager
  end

  def current_path
    request.fullpath
  end

  def answer_fields
    %w[
      answer_01
      answer_02
      answer_03
      answer_04
      answer_05
      answer_06
      answer_07
      answer_08
      answer_09
      answer_10
      answer_11
      answer_12
      answer_13
      answer_14
      answer_15
      answer_16
      answer_17
      answer_18
      answer_19
      answer_20
    ]
  end

  # Legacy route from before the Form model was merged with the Touchpoint model
  def submit_touchpoint_uuid_url(form)
    "#{root_url}touchpoints/#{form.short_uuid}/submit"
  end

  def format_time(time, timezone)
    I18n.l time.to_time.in_time_zone(timezone), format: :long
  end

  def form_integrity_checksum(form:)
    data_to_encode = render(partial: 'components/widget/fba', formats: :js, locals: { form: })
    Digest::SHA256.base64digest(data_to_encode)
  end
end
