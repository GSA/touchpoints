# frozen_string_literal: true

class SiteController < ApplicationController
  def index
    redirect_to admin_root_path if current_user
  end

  def agencies; end

  def registry
    @results = nil
  end

  def registry_search_post
    organization_id = search_params[:organization_id]
    tags = search_params[:tags]
    platform = search_params[:platform]
    status = search_params[:status]

    # Record searches, to better understand what users are searching for and how
    RegistrySearch.create!({
      agency: organization_id,
      keywords: tags,
      platform: platform,
      status: status,
      session_id: session.id
    })

    if status == "published"
      @results = DigitalServiceAccount.published
    elsif status == "archived"
      @results = DigitalServiceAccount.archived
    else #all
      @max_results = true
      @results = DigitalServiceAccount
    end

    @results = @results.where(service: platform.downcase) if platform.present? && platform != ""
    @results = @results.tagged_with(organization_id, context: 'organizations') if organization_id.present? && organization_id != ''

    # Make params available to show the user
    @search_params = search_params

    # Cap search results, for performance
    @results = @results.limit(500)

    render :registry
  end

  def registry_export
    organization_id = params[:organization_id]
    tags = params[:tags]
    service = params[:service]
    status = params[:status]

    if status == "published"
      @results = DigitalServiceAccount.published
    elsif status == "archived"
      @results = DigitalServiceAccount.archived
    else #all
      @results = DigitalServiceAccount
    end

    @results = @results.limit(100)
    respond_to do |format|
      format.csv do
        csv = CSV.generate(headers: true) do |csv|
          csv << @results.first.attributes.keys
          @results.each do |result|
            csv << result.attributes.values
          end
        end
        send_data csv, filename: "touchpoints-digital-registry-#{Date.today}.csv"

      end
    end
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
        :platform,
        :status
      )
    end
end
