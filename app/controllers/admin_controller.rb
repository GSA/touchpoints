class AdminController < ::ApplicationController
  include ApplicationHelper

  before_action :ensure_user, except: [:deactivate]
end
