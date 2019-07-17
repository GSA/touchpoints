class SiteController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:csp_violation]

  def index
  end

  def onboarding
    if current_user && current_user.organization
      redirect_to admin_root_path
    end
  end

  def csp_violation
    render json: { message: "CSP Violation" }
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
