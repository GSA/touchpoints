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
    @page_num = (params[:page].present? ? params[:page].to_i : 0)
    @page_size = (params[:page_size].present? ? params[:page_size].to_i : 500)
    @page_size = 5000 if @page_size > 5000

    respond_to do |format|
      format.json {
        if @form
          render json: {
            form: @form,
            responses: @form.submissions.limit(@page_size).offset(@page_size * @page_num)
          }
        else
          render json: { error: { message: "no form with Short UUID of #{params[:id]}", status: 404 } }, status: 404
        end
      }
    end
  end

end
