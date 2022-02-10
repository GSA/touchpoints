class Api::V1::CollectionsController < ::ApiController
  def index
    respond_to do |format|
      format.json {
        render json: Collection.all, each_serializer: CollectionSerializer
      }
    end
  end
end
