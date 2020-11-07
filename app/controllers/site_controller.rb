class SiteController < ApplicationController
  def index
    if current_user
      redirect_to admin_root_path
    end
  end

  def agencies
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
