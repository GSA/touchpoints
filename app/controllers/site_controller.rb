class SiteController < ApplicationController
  def index
    if current_user
      if ENV["INDEX_URL"].present?
        redirect_to ENV["INDEX_URL"]
      else
        redirect_to admin_root_path
      end
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
