class Api::V1::ServiceProvidersController < ::ApiController
  def index
    respond_to do |format|
      format.json {
        render json: ServiceProvider.all, each_serializer: ServiceProviderSerializer
      }
    end
  end
end
