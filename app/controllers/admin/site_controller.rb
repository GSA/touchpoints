class Admin::SiteController < AdminController
  before_action :ensure_admin
  
  def index
    @google_api = GoogleApi.new
    @account = @google_api.get_account(account_id: 4172456290).to_h
    @account[:containers] = @google_api.list_account_containers(account_id: @account[:account_id])
    @account[:user_permissions] = @google_api.list_account_user_permissions(account_id: @account[:account_id])
  end
end
