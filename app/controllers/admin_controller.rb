class AdminController < ::ApplicationController
  before_action :ensure_onboarding
  before_action :ensure_user
end
