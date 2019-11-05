class SiteController < ApplicationController
  def index
    Rails.logger.debug("** AKT ** index")
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
