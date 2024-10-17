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

  def organization_abbreviation_dropdown_options
    Organization.all.order(:name).map { |org| ["#{org.abbreviation} - #{org.name}", org.abbreviation] }
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
      'in_development' => '1',
      'production' => '2',
      'being_decommissioned' => '3',
      'redirect' => '4',
      'archived' => '5',
      'decommissioned' => '6',
    }
  end

  def website_status_label_tags(status)
    {
      'in_development' => 'bg-blue',
      'production' => 'bg-mint',
      'being_decommissioned' => 'bg-accent-warm-dark',
      'redirect' => 'bg-accent-warm-light',
      'archived' => 'bg-gray-30',
      'decommissioned' => 'bg-black',
    }[status]
  end

  def cx_collections_filters_applied?(quarter, year, status)
    [quarter, year, status].any? { |param| param.present? && param.downcase != "all" }
  end

  def cx_collections_filter_message(quarter, year, status)
    parts = []

    if quarter.present? && quarter.downcase != "all"
      parts << "Q#{quarter}"
    end

    if year.present? && year.downcase != "all"
      parts << "FY#{year}"
    end

    if status.present? && status.downcase != "all"
      parts << status
    end

    return "" if parts.empty?

    "for " + parts.join(" ")
  end

  # Returns javascript to capture form input for one Form Question
  def question_type_javascript_params(question)
    if question.question_type == 'text_field'
      "form.querySelector(\"##{question.ui_selector}\") && form.querySelector(\"##{question.ui_selector}\").value"
    elsif question.question_type == 'hidden_field'
      "form.querySelector(\"##{question.ui_selector}\") && form.querySelector(\"##{question.ui_selector}\").value"
    elsif question.question_type == 'date_select'
      "form.querySelector(\"##{question.ui_selector}\") && form.querySelector(\"##{question.ui_selector}\").value"
    elsif question.question_type == 'text_email_field'
      "form.querySelector(\"##{question.ui_selector}\") && form.querySelector(\"##{question.ui_selector}\").value"
    elsif question.question_type == 'text_phone_field'
      "form.querySelector(\"##{question.ui_selector}\") && form.querySelector(\"##{question.ui_selector}\").value"
    elsif question.question_type == 'textarea'
      "form.querySelector(\"##{question.ui_selector}\") && form.querySelector(\"##{question.ui_selector}\").value"
    elsif question.question_type == 'radio_buttons'
      "form.querySelector(\"input[name=#{question.ui_selector}]:checked\") && form.querySelector(\"input[name=#{question.ui_selector}]:checked\").value"
    elsif question.question_type == 'star_radio_buttons'
      "form.querySelector(\"input[name=#{question.ui_selector}]:checked\") && form.querySelector(\"input[name=#{question.ui_selector}]:checked\").value"
    elsif question.question_type == 'thumbs_up_down_buttons'
      "form.querySelector(\"input[name=#{question.ui_selector}]:checked\") && form.querySelector(\"input[name=#{question.ui_selector}]:checked\").value"
    elsif question.question_type == 'big_thumbs_up_down_buttons'
      "form.querySelector(\"input[name=#{question.ui_selector}]:checked\") && form.querySelector(\"input[name=#{question.ui_selector}]:checked\").value"
    elsif question.question_type == 'yes_no_buttons'
      "form.querySelector(\"input[name=#{question.ui_selector}]\") && form.querySelector(\"input[name=#{question.ui_selector}]\").value"
    elsif question.question_type == 'checkbox'
      "form.querySelector(\"input[name=#{question.ui_selector}]:checked\") && Array.apply(null,form.querySelectorAll(\"input[name=#{question.ui_selector}]:checked\")).map(function(x) {return x.value;}).join(',')"
    elsif question.question_type == 'combobox'
      "form.querySelector(\"##{question.ui_selector}\") && form.querySelector(\"##{question.ui_selector}\").value"
    elsif %w[dropdown states_dropdown].include?(question.question_type)
      "form.querySelector(\"##{question.ui_selector}\") && form.querySelector(\"##{question.ui_selector}\").value"
    elsif question.question_type == 'text_display'
      'null'
    elsif question.question_type == 'custom_text_display'
      "form.querySelector(\"input[name=#{question.ui_selector}]:checked\") && form.querySelector(\"input[name=#{question.ui_selector}]:checked\").value"
    end
  end

  def is_at_least_form_manager?(user:, form:)
    user.admin? ||
      user.organizational_form_approver && user.organization_id == form.organization_id ||
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
    I18n.l time.to_time.in_time_zone(timezone), format: :with_timezone
  end

  def timezone_abbreviation(timezone)
    zone = ActiveSupport::TimeZone.new(timezone)
    zone.now.strftime('%Z')
  end

  def form_integrity_checksum(form:)
    data_to_encode = render(partial: 'components/widget/fba', formats: :js, locals: { form: })
    Digest::SHA256.base64digest(data_to_encode)
  end

  def fiscal_year_and_quarter(date)
    FiscalYear.fiscal_year_and_quarter(date)
  end
end
