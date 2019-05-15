class Touchpoint < ApplicationRecord
  belongs_to :container, optional: true
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

  def config_gtm_container!
    return if Rails.env.test?

    google_service = GoogleApi.new

    # Lookup Workspaces
    path = "accounts/#{ENV.fetch('GOOGLE_TAG_MANAGER_ACCOUNT_ID')}/containers/#{self.service.container.gtm_container_id}"
    workspaces = google_service.list_account_container_workspaces(path: path)
    workspace_id = workspaces.first.workspace_id

    # Create the Touchpoints Tag
    path = "accounts/#{ENV.fetch('GOOGLE_TAG_MANAGER_ACCOUNT_ID')}/containers/#{self.service.container.gtm_container_id}/workspaces/#{workspace_id}"
    google_service.create_touchpoints_tag(path: path, body: touchpoints_js_string)

    # TODO: Figure out why this fails
    # Publish New Container Version
    # publish_new_container_version!(service: service, path: path)
  end

  # Publish New Container Version
  def publish_new_container_version!(service:, path:)
    new_container_version  = service.create_account_container_workspace_version(path: path)
    version_id = new_container_version.container_version.container_version_id
    path2 = "accounts/#{ENV.fetch('GOOGLE_TAG_MANAGER_ACCOUNT_ID')}/containers/#{self.container.gtm_container_id}/versions/#{version_id}"
    service.publish_account_container_version(path: path2)
  end

  def export_to_google_sheet!
    return unless self.submissions.present?

    sheet = create_google_sheet!

    self.submissions.each do |submission|
      values = submission.to_rows
      response = @google_service.add_row(spreadsheet_id: sheet.spreadsheet_id, values: values)
    end

    sheet
  end

  # Creates a Google Sheet for this Touchpoint
  def create_google_sheet!
    @google_service = GoogleSheetsApi.new
    new_spreadsheet = @google_service.create_permissioned_spreadsheet({ title: self.name })
    self.google_sheet_id = new_spreadsheet.spreadsheet_id

    push_title_row

    new_spreadsheet
  end

  # TODO - push the guts of the next 3 methods out. keep the method though
  # Returns the existing Google Spreadsheet as an object for this Touchpoint
  def google_spreadsheet
    raise ArgumentError unless self.google_sheet_id

    @google_service = GoogleSheetsApi.new
    spreadsheet = @google_service.service.get_spreadsheet(self.google_sheet_id)
  end

  def google_spreadsheet_values
    raise ArgumentError unless self.google_sheet_id

    @google_service = GoogleSheetsApi.new
    spreadsheet = @google_service.service.get_spreadsheet_values(self.google_sheet_id, "A1:ZZ")
  end


  private

  def push_title_row
    raise InvalidArgument unless self.form

    if self.form.kind == "recruiter"
    push_row(values: [
      "First Name",
      "Last Name",
      "Email",
      "User Agent",
      "Page",
      "Referrer",
      "Created At"
      ])
    elsif self.form.kind == "open-ended"
      push_row(values: [
        "Body",
        "User Agent",
        "Page",
        "Referrer",
        "Created At"
      ])
    elsif self.form.kind == "open-ended-with-contact-info"
      push_row(values: [
        "Body",
        "Name",
        "Email",
        "Phone",
        "User Agent",
        "Page",
        "Referrer",
        "Created At"
      ])
    elsif self.form.kind == "a11"
      push_row(values: [
        "Overall satisfaction",
        "Service confidence",
        "Service effectiveness",
        "Process ease",
        "Process efficiency",
        "Process transparency",
        "People employees",
        "User Agent",
        "Page",
        "Referrer",
        "Created At"
      ])
    else
      raise InvalidArgument("#{@touchpoint.name} has a Form with an unsupported Kind")
    end
  end

  def push_row(values: [])
    @google_service = GoogleSheetsApi.new
    @google_service.add_row(
      spreadsheet_id: self.google_sheet_id,
      values: values
    )
  end
end
