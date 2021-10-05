class Api::V1::WebsitesController < ::ApiController
  def index
    respond_to do |format|
      format.json {
        render json: Website.active, each_serializer: WebsiteSerializer
      }
    end
  end
end
