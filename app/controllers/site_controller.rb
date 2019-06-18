class SiteController < ApplicationController
  def index
  end

  def onboarding
    if current_user && current_user.organization
      redirect_to admin_root_path
    end
  end

  def status
    render json: {
      status: :success,
      services: {
        database: :operational
      }
    }
  end
end
