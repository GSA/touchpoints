# frozen_string_literal: true

class SiteController < ApplicationController
  def index
    redirect_to admin_root_path if current_user
  end

  def agencies; end

  def registry; end

  def registry_search
    account = params[:account]
    # DigitalServiceAccount.find_by_account(account)
    @results = DigitalServiceAccount.published.limit(100)
  end

  def status
    render json: {
      status: :success,
      services: {
        database: :operational,
      },
    }
  end

  def hello_stimulus; end
end
