class AdminController < ::ApplicationController
  before_action :ensure_user
end
