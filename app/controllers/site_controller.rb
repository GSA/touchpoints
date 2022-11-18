# frozen_string_literal: true

class SiteController < ApplicationController
  def index
    redirect_to admin_root_path if current_user
  end

  def agencies; end

  def registry
    @results = nil
  end

  def registry_search
    organization_id = search_params[:organization_id]
    tags = search_params[:tags]
    service = search_params[:service]
    aasm_state = search_params[:status]

    if aasm_state == "published"
      @results = DigitalServiceAccount.published.limit(100)
    elsif aasm_state == "archived"
      @results = DigitalServiceAccount.archived.limit(100)
    else #all
      @results = DigitalServiceAccount.limit(100)
    end

    render :registry
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

  def search_params
      params.require(:search).permit(
        :organization_id,
        :tags,
        :service,
        :status,
      )
    end
end
