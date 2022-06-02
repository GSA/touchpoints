class Api::V1::OmbCxReportingCollectionsController < ::ApiController
  def index
    respond_to do |format|
      format.json {
        render json: OmbCxReportingCollection.all.order(:id), each_serializer: OmbCxReportingCollectionSerializer
      }
    end
  end
end
