class Admin::SiteController < AdminController
  before_action :ensure_admin

  def index
  end
end
