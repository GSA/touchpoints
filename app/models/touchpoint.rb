class Touchpoint < ApplicationRecord
  belongs_to :service
  belongs_to :form, optional: true
  has_many :submissions

  validates :name, presence: true

  validate :omb_number_with_expiration_date

  def omb_number_with_expiration_date
    if omb_approval_number.present? && !expiration_date.present?
      errors.add(:expiration_date, "required with an OMB Number")
    end
    if expiration_date.present? && !omb_approval_number.present?
      errors.add(:omb_approval_number, "required with an Expiration Date")
    end
  end

  DELIVERY_METHODS = [
    "touchpoints-hosted-only",
    "modal",
    "custom-button-modal",
    "inline"
  ]

  scope :active, -> { where("id > 0") } # TODO: make this sample scope more intelligent/meaningful

  def send_notifications?
    self.notification_emails.present?
  end

  def deployable_touchpoint?
    (self.form && self.service) ? true : false
  end

  # returns javascript text that can be used standalone
  # or injected into a GTM Container Tag
  def touchpoints_js_string
    ApplicationController.new.render_to_string(partial: "components/widget/fba.js", locals: { touchpoint: self })
  end

  def to_csv
    non_flagged_submissions = self.submissions.non_flagged
    return nil unless non_flagged_submissions.present?

    header_attributes = self.hashed_fields_for_export.values
    attributes = self.fields_for_export

    CSV.generate(headers: true) do |csv|
      csv << header_attributes

      non_flagged_submissions.each do |submission|
        csv << attributes.map { |attr| submission.send(attr) }
      end
    end
  end

  APPROVED_FORM_KINDS = [
    "a11"
  ]

  def fields_for_export
    raise InvalidArgument unless self.form
    raise InvalidArgument("#{@touchpoint.name} has a Form with an unsupported Kind") unless APPROVED_FORM_KINDS.include?(self.form.kind)

    self.hashed_fields_for_export.keys
  end

  # TODO: Move to /models/submission.rb
  def hashed_fields_for_export
    raise InvalidArgument unless self.form

    if self.form.kind == "a11"
      {
        answer_01: "Overall satisfaction",
        answer_02: "Service confidence",
        answer_03: "Service effectiveness",
        answer_04: "Process ease",
        answer_05: "Process efficiency",
        answer_06: "Process transparency",
        answer_07: "People employees",
        answer_08: "Custom Question 1",
        answer_09: "Custom Question 2",
        answer_10: "Custom Question 3",
        answer_11: "Custom Question 4",
        answer_12: "Custom Question 5",
        ip_address: "IP Address",
        user_agent: "User Agent",
        page: "Page",
        referer: "Referrer",
        created_at: "Created At"
      }
    else
      raise InvalidArgument("#{@touchpoint.name} has a Form with an unsupported Kind")
    end
  end

end
