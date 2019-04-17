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
      json_key_io: GoogleApi.config_io,
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

    writer_users = ['ryan.wold@gsa.gov', 'lauren.ancona@gsa.gov']

    writer_users.each do |email|
      user_permission = {
        type: 'user',
        role: 'writer',
        email_address: email
      }
      @service.create_permission(file_id,
        user_permission,
        fields: 'id',
        &callback)
    end
  end
end
