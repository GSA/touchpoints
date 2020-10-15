class Api::V1::FormsController < ::ApiController
  def index
    respond_to do |format|
      format.json {
        render json: Form.limit(100)
      }
    end
  end

  def show
    @form = Form.find_by_short_uuid(params[:id])

    respond_to do |format|
      format.json {
        render json: {
          form: @form,
          responses: @form.submissions
        }
      }
    end
  end
end
