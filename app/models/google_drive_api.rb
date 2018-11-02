class GoogleDriveApi
  require 'google/apis/drive_v3'

  attr_reader :service

  def initialize
    Google::Apis.logger.level = Logger::DEBUG if Rails.env.development?

    scope = [
      "https://www.googleapis.com/auth/drive",
      "https://www.googleapis.com/auth/drive.file"
    ].freeze

    authorizer = Google::Auth::ServiceAccountCredentials.make_creds({
      json_key_io: File.open("tmp/google_service_account_#{Rails.env.downcase}.json"),
      scope: scope
    })
    authorizer.fetch_access_token!

    @service = Google::Apis::DriveV3::DriveService.new
    @service.authorization = authorizer
  end

  def list_files
    Google::Apis::DriveV3::FileList.new
  end

  def add_permissions(file_id:)
    callback = lambda do |res, err|
      if err
        # Handle error...
        puts err.body
      else
        puts "Adding Permission ID #{res.id} to Google Drive File ID #{file_id}"
      end
    end

    user_permission = {
      type: 'user',
      role: 'writer',
      email_address: 'ryanjwold@gmail.com'
    }
    @service.create_permission(file_id,
                              user_permission,
                              fields: 'id',
                              &callback)

    user_permission = {
      type: 'user',
      role: 'writer',
      email_address: 'ryan.wold@gsa.gov'
    }
    @service.create_permission(file_id,
      user_permission,
      fields: 'id',
      &callback)

    user_permission = {
      type: 'user',
      role: 'owner',
      email_address: 'ryanjwold@gmail.com'
    }
    @service.create_permission(file_id,
                              user_permission,
                              transfer_ownership: true,
                              fields: 'id',
                              &callback)
  end
end
