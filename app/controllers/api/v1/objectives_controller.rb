class Api::V1::ObjectivesController < ::ApiController
  def index
    respond_to do |format|
      format.json {
        render json: Objective.all.order(:id), each_serializer: ObjectiveSerializer
      }
    end
  end
end
