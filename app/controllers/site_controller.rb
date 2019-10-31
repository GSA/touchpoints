class SiteController < ApplicationController
  def index
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
