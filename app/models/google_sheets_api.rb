class GoogleSheetsApi
  require 'google/apis/sheets_v4'

  attr_reader :service

  def initialize
    Google::Apis.logger.level = Logger::DEBUG if Rails.env.development?

    scope = [
      "https://www.googleapis.com/auth/drive",
      "https://www.googleapis.com/auth/drive.file",
      "https://www.googleapis.com/auth/spreadsheets",
    ].freeze

    authorizer = Google::Auth::ServiceAccountCredentials.make_creds({
      json_key_io: File.open("tmp/google_service_account_#{Rails.env.downcase}.json"),
      scope: scope
    })
    authorizer.fetch_access_token!

    @service = Google::Apis::SheetsV4::SheetsService.new
    @service.authorization = authorizer
  end

  def create_permissioned_spreadsheet(options = {})
    spreadsheet = create_spreadsheet(options)
    GoogleDriveApi.new.add_permissions(file_id: spreadsheet.spreadsheet_id)
    spreadsheet
  end

  def create_spreadsheet(options = {})
    properties = Google::Apis::SheetsV4::SpreadsheetProperties.new(title: "FBA Sheet - #{options[:title]} - #{Rails.env}")
    new_spreadsheet = Google::Apis::SheetsV4::Spreadsheet.new(properties: properties)
    @service.create_spreadsheet(new_spreadsheet)
  end

  def add_row(spreadsheet_id: "", values: [])
    value_range = Google::Apis::SheetsV4::ValueRange.new(values: [values])
    @service.append_spreadsheet_value(spreadsheet_id, "A1", value_range, value_input_option: "RAW")
  end
end
