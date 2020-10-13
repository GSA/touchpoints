class Api::V1::ResponsesController < ::ApiController
  def index
    respond_to do |format|
      format.json {
        render json: Submission.limit(100)
      }
    end
  end
end
