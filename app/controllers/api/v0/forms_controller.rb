class Api::V0::FormsController < ::ApiController
  def index
    respond_to do |format|
      format.json {
        render json: { forms: current_user.forms.limit(100) }
      }
    end
  end

  def show
    @form = current_user.forms.find_by_short_uuid(params[:id])

    respond_to do |format|
      format.json {
        if @form
          render json: {
            form: @form,
            responses: @form.submissions
          }
        else
          render json: { error: { message: "no form with Short UUID of #{params[:id]}", status: 404 } }, status: 404
        end
      }
    end
  end
end
