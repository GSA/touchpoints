class Submission < ApplicationRecord
  belongs_to :touchpoint

  validate :validate_recruiter_form, if: :form_kind_is_recruiter?
  validate :validate_open_ended_form, if: :form_kind_is_open_ended?
  validate :validate_a11_form, if: :form_kind_is_a11?
  validate :validate_custom_form, if: :form_kind_is_custom?

  scope :non_flagged, -> { where(flagged: false) }

  def validate_custom_form
    @valid_form_condition = false

    # gather all answer fields
    valid_answer_fields = self.touchpoint.form.questions.collect(&:answer_field)
    # loop the fields and ensure there is at least one answered
    valid_answer_fields.each do |valid_field|
      if self.send(valid_field).present?
        @valid_form_condition = true
      end
    end

    unless @valid_form_condition
      # push an error to a blank key to generate the generic error message
      errors[""] << "Please answer at least one of the core 7 questions."
    end
  end

  def validate_recruiter_form
    unless self.answer_01 && self.answer_01.present?
      errors.add(:first_name, "can't be blank")
    end
    unless self.answer_04 && self.answer_04.present?
      errors.add(:email, "can't be blank")
    end
  end

  def validate_open_ended_form
    unless self.answer_01 && self.answer_01.present?
      errors.add(:body, "can't be blank")
    end
    character_limit = self.touchpoint.form.character_limit
    if self.answer_01 && self.answer_01.length > character_limit
      errors.add(:body, "is limited to #{character_limit} characters")
    end
  end

  def validate_a11_form
    unless self.answer_01 && self.answer_01.present? ||
      self.answer_02 && self.answer_02.present? ||
      self.answer_03 && self.answer_03.present? ||
      self.answer_04 && self.answer_04.present? ||
      self.answer_05 && self.answer_05.present? ||
      self.answer_06 && self.answer_06.present? ||
      self.answer_07 && self.answer_07.present?
      errors.add("at least one answer", "is required")
    end
  end

  def send_notifications
    return unless self.touchpoint.send_notifications?
    return unless self.touchpoint.notification_emails?
    emails_to_notify = self.touchpoint.notification_emails
    UserMailer.submission_notification(submission: self, emails: emails_to_notify).deliver_now
  end

  # NOTE: this is brittle.
  #       this pattern will require every field to declare its validations
  #       Rethink.
  def form_kind_is_custom?
    self.touchpoint.form.kind == "custom"
  end

  def form_kind_is_recruiter?
    self.touchpoint.form.kind == "recruiter"
  end

  def form_kind_is_open_ended?
    self.touchpoint.form.kind == "open-ended" ||
    self.touchpoint.form.kind == "open-ended-with-contact-info"
  end

  def form_kind_is_a11?
    self.touchpoint.form.kind == "a11"
  end

  def to_rows
    if self.touchpoint.form.kind == "recruiter"
      values = [
        self.answer_01,
        self.answer_02,
        self.answer_03,
        self.answer_04
      ]
    end
    if self.touchpoint.form.kind == "open-ended"
      values = [
        self.answer_01
      ]
    end
    if self.touchpoint.form.kind == "open-ended-with-contact-info"
      values = [
        self.answer_01,
        self.answer_02,
        self.answer_03,
        self.answer_04
      ]
    end
    if self.touchpoint.form.kind == "a11"
      values = [
        self.answer_01,
        self.answer_02,
        self.answer_03,
        self.answer_04,
        self.answer_05,
        self.answer_06,
        self.answer_07,
        self.answer_08,
        self.answer_09,
        self.answer_10,
        self.answer_11,
        self.answer_12
      ]
    end

    values = values + [
      self.ip_address,
      self.user_agent,
      self.page,
      self.referer,
      self.created_at
    ]

    values
  end

  def organization_name
    self.touchpoint.service ? self.touchpoint.service.organization.name : "Placeholder Org Name"
  end
end
