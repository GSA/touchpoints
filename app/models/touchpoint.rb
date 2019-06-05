class Touchpoint < ApplicationRecord
  belongs_to :service, optional: true
  belongs_to :form, optional: true
  has_many :submissions

  validates :name, presence: true

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
    return nil unless self.submissions.present?

    header_attributes = self.hashed_fields_for_export.values
    attributes = self.fields_for_export

    CSV.generate(headers: true) do |csv|
      csv << header_attributes

      submissions.each do |submission|
        csv << attributes.map { |attr| submission.send(attr) }
      end
    end
  end

  APPROVED_FORM_KINDS = [
    "recruiter",
    "open-ended",
    "open-ended-with-contact-info",
    "a11",
  ]

  def fields_for_export
    raise InvalidArgument unless self.form
    raise InvalidArgument("#{@touchpoint.name} has a Form with an unsupported Kind") unless APPROVED_FORM_KINDS.include?(self.form.kind)

    self.hashed_fields_for_export.keys
  end

  # TODO: Move to /models/submission.rb
  def hashed_fields_for_export
    raise InvalidArgument unless self.form

    if self.form.kind == "recruiter"
      {
        answer_01: "First Name",
        answer_02: "Last Name",
        answer_03: "Email",
        answer_04: "IP Address",
        ip_address: "IP Address",
        user_agent: "User Agent",
        page: "Page",
        referer: "Referrer",
        created_at: "Created At"
      }
    elsif self.form.kind == "open-ended"
      {
        answer_01: "Body",
        ip_address: "IP Address",
        user_agent: "User Agent",
        page: "Page",
        referer: "Referrer",
        created_at: "Created At"
      }
    elsif self.form.kind == "open-ended-with-contact-info"
      {
        answer_01: "Body",
        answer_02: "Name",
        answer_03: "Email",
        answer_04: "Phone",
        ip_address: "IP Address",
        user_agent: "User Agent",
        page: "Page",
        referer: "Referrer",
        created_at: "Created At"
      }
    elsif self.form.kind == "a11"
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
