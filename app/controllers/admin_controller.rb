class AdminController < ::ApplicationController
  before_action :ensure_user
  before_action :ensure_onboarding
end
