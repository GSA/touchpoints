class Api::V1::ServiceProvidersController < ::ApiController
  def index
    respond_to do |format|
      format.json {
        render json: ServiceProvider.all.includes(:organization).order("organizations.name", :name), each_serializer: ServiceProviderSerializer
      }
    end
  end
end
