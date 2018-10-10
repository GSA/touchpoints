class Touchpoint < ApplicationRecord

  belongs_to :organization
  belongs_to :form
  has_many :submissions

  before_save :create_container_in_gtm
  before_save :create_google_sheet

  validates :name, presence: true

  def gtm_container_url
    "https://tagmanager.google.com/#/admin/?accountId=#{ENV.fetch('GOOGLE_TAG_MANAGER_ACCOUNT_ID')}&containerId=#{gtm_container_id}"
  end

  def embed_code
    GoogleApi.gtm_header_text(key: "asdf")
  end

  def embed_code_body
    GoogleApi.gtm_body_text(key: "asdf")
  end

  # Creates a GTM Container for this Touchpoint
  def create_container_in_gtm
    return if Rails.env.test?

    @service = GoogleApi.new
    new_container = @service.create_account_container(name: "fba-#{Rails.env.downcase}-#{name.parameterize}")
    self.gtm_container_id = new_container.container_id
  end

  # Creates a Google Sheet for this Touchpoint
  def create_google_sheet
    return unless self.enable_google_sheets

    @service = GoogleSheetsApi.new
    new_spreadsheet = @service.create_permissioned_spreadsheet({ title: self.name })
    self.google_sheet_id = new_spreadsheet.spreadsheet_id

    push_title_row
  end

  # Returns the existing Google Spreadsheet as an object for this Touchpoint
  def google_spreadsheet
    raise ArgumentError unless self.google_sheet_id

    @service = GoogleSheetsApi.new
    spreadsheet = @service.service.get_spreadsheet(self.google_sheet_id)
  end

  def push_title_row
    push_row(values: [
      "First Name",
      "Last Name",
      "email"
      ])
  end

  def push_row(values: [])
    @service = GoogleSheetsApi.new
    @service.add_row(
      spreadsheet_id: self.google_sheet_id,
      values: values
    )
  end
end
