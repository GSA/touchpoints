class Api::V1::GoalsController < ::ApiController
  def index
    respond_to do |format|
      format.json {
        render json: Goal.all.order(:id), each_serializer: GoalSerializer
      }
    end
  end
end
