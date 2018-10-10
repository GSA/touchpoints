class SiteController < ApplicationController
  def index
  end

  def status
    render json: {
      status: :success,
      services: {
        database: :operational,
        google: {
          sheets: :operational,
          gtm: :operational
        }
      }
    }
  end
end
