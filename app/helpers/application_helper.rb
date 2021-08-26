module ApplicationHelper

  def suppress_main_layout_flash?
    if flash && ["User successfully added", "User successfully removed"].include?(flash.notice)
      return true
    end
  end

  def organization_dropdown_options
    Organization.all.order(:name).map { |org| ["#{org.abbreviation} - #{org.name}", org.id] }
  end

  def hisp_questions_key
    {
      "1" => "satisfaction",
      "2" => "trust",
      "3" => "effectiveness",
      "4" => "ease",
      "5" => "effiency",
      "6" => "transparency",
      "7" => "employee",
    }
  end

  def collection_rating_label(rating:)
    if rating == "TRUE"
      "🟢"
    elsif rating == "FALSE"
      "🔴"
    elsif rating == "PARTIAL"
      "🟡"
    end
  end

  # Returns javascript to capture form input for one Form Question
  def question_type_javascript_params(question)
    if question.question_type == "text_field"
      "form.querySelector(\"##{question.answer_field}\") && form.querySelector(\"##{question.answer_field}\").value"
    elsif question.question_type == "hidden_field"
      "form.querySelector(\"##{question.answer_field}\") && form.querySelector(\"##{question.answer_field}\").value"
    elsif question.question_type == "text_email_field"
      "form.querySelector(\"##{question.answer_field}\") && form.querySelector(\"##{question.answer_field}\").value"
    elsif question.question_type == "text_phone_field"
      "form.querySelector(\"##{question.answer_field}\") && form.querySelector(\"##{question.answer_field}\").value"
    elsif question.question_type == "textarea"
      "form.querySelector(\"##{question.answer_field}\") && form.querySelector(\"##{question.answer_field}\").value"
    elsif question.question_type == "radio_buttons"
      "form.querySelector(\"input[name=#{question.answer_field}]:checked\") && form.querySelector(\"input[name=#{question.answer_field}]:checked\").value"
    elsif question.question_type == "star_radio_buttons"
      "form.querySelector(\"input[name=#{question.answer_field}]:checked\") && form.querySelector(\"input[name=#{question.answer_field}]:checked\").value"
    elsif question.question_type == "thumbs_up_down_buttons"
      "form.querySelector(\"input[name=#{question.answer_field}]:checked\") && form.querySelector(\"input[name=#{question.answer_field}]:checked\").value"
    elsif question.question_type == "yes_no_buttons"
      "form.querySelector(\"input[name=#{question.answer_field}]\") && form.querySelector(\"input[name=#{question.answer_field}]\").value"
    elsif question.question_type == "checkbox"
      "form.querySelector(\"input[name=#{question.answer_field}]:checked\") && Array.apply(null,form.querySelectorAll(\"input[name=#{question.answer_field}]:checked\")).map(function(x) {return x.value;}).join(',')"
    elsif ["dropdown", "states_dropdown"].include?(question.question_type)
      "form.querySelector(\"##{question.answer_field}\") && form.querySelector(\"##{question.answer_field}\").value"
    elsif question.question_type == "text_display"
      "null"
    elsif question.question_type == "custom_text_display"
      "form.querySelector(\"input[name=#{question.answer_field}]:checked\") && form.querySelector(\"input[name=#{question.answer_field}]:checked\").value"
    end
  end

  def is_at_least_form_manager?(user:, form:)
    user.admin? ||
      form.user_role?(user: user) == UserRole::Role::FormManager
  end

  def current_path
    request.fullpath
  end

  def answer_fields
    [
      "answer_01",
      "answer_02",
      "answer_03",
      "answer_04",
      "answer_05",
      "answer_06",
      "answer_07",
      "answer_08",
      "answer_09",
      "answer_10",
      "answer_11",
      "answer_12",
      "answer_13",
      "answer_14",
      "answer_15",
      "answer_16",
      "answer_17",
      "answer_18",
      "answer_19",
      "answer_20"
    ]
  end

  # Legacy route from before the Form model was merged with the Touchpoint model
  def submit_touchpoint_uuid_url(form)
    return "#{root_url}touchpoints/#{form.short_uuid}/submit"
  end

  def format_time(time, timezone)
    I18n.l time.to_time.in_time_zone(timezone), format: :long
  end

  def form_integrity_checksum(form:)
    data_to_encode = render(partial: "components/widget/fba", formats: :js, locals: { form: form })
    Digest::SHA256.base64digest(data_to_encode)
  end
end
