class Admin::SiteController < AdminController
  def index
    ensure_admin
  end

  def dashboard
  end
end
