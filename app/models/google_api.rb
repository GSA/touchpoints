class GoogleApi
  require 'google/apis'
  require 'google/apis/tagmanager_v2'

  attr_reader :service

  def self.gtm_header_text(key:)
<<-eos
<!-- Google Tag Manager -->
<script>(function(w,d,s,l,i){w[l]=w[l]||[];w[l].push({'gtm.start':
new Date().getTime(),event:'gtm.js'});var f=d.getElementsByTagName(s)[0],
j=d.createElement(s),dl=l!='dataLayer'?'&l='+l:'';j.async=true;j.src=
'https://www.googletagmanager.com/gtm.js?id='+i+dl;f.parentNode.insertBefore(j,f);
})(window,document,'script','dataLayer','#{key}');</script>
<!-- End Google Tag Manager -->
eos
  end

  def self.gtm_body_text(key:)
<<-eos
<!-- Google Tag Manager (noscript) -->
<noscript><iframe src="https://www.googletagmanager.com/ns.html?id=#{key}"
height="0" width="0" style="display:none;visibility:hidden"></iframe></noscript>
<!-- End Google Tag Manager (noscript) -->
eos
  end

  def initialize
    Google::Apis.logger.level = Logger::DEBUG if Rails.env.development?

    scope = [
      Google::Apis::TagmanagerV2::AUTH_TAGMANAGER_MANAGE_ACCOUNTS,
      Google::Apis::TagmanagerV2::AUTH_TAGMANAGER_READONLY,
      Google::Apis::TagmanagerV2::AUTH_TAGMANAGER_MANAGE_USERS,
      Google::Apis::TagmanagerV2::AUTH_TAGMANAGER_EDIT_CONTAINERS,
      Google::Apis::TagmanagerV2::AUTH_TAGMANAGER_DELETE_CONTAINERS
    ]

    authorizer = Google::Auth::ServiceAccountCredentials.make_creds({
      json_key_io: File.open('tmp/google_service_account.json'),
      scope: scope
    })
    authorizer.fetch_access_token!

    @service = Google::Apis::TagmanagerV2::TagManagerService.new
    @service.authorization = authorizer
    @account_id = ENV.fetch("GOOGLE_TAG_MANAGER_ACCOUNT_ID")
  end

  def get_accounts
    @service.list_accounts.account # => []
  end

  def get_account(account_id:)
    @service.get_account("accounts/#{account_id}")
  end

  def list_account_containers(account_id:)
    @service.list_account_containers("accounts/#{account_id}").container
  end

  def list_account_container_workspaces(path:)
    @service.list_account_container_workspaces(path).workspace
  end

  def list_account_user_permissions(account_id:)
    @service.list_account_user_permissions("accounts/#{account_id}").user_permission
  end

  def clean_account_containers(account_id:)
    return if Rails.env.production?

    containers  = list_account_containers(account_id: account_id)
    containers.each do |c|
      begin
        @service.delete_account_container(c.path)
      rescue
        puts "WARNING: Could not delete GTM Container #{c.name} - #{c.fingerprint}"
      end
    end
  end

  # Reference: https://github.com/googleapis/google-api-ruby-client/blob/711dfb83b33c03535076917726956584d5c8bf9a/generated/google/apis/tagmanager_v2/representations.rb
  def create_account_container(name:)
    # Define the new Container
    new_container = Google::Apis::TagmanagerV2::Container.new
    new_container.name = name
    new_container.usage_context = ["web"]

    # Post it to GTM's API
    @service.create_account_container("accounts/#{@account_id}", new_container)
  end
end
