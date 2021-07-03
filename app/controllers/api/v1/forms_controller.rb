class Api::V1::FormsController < ::ApiController
  def index
    respond_to do |format|
      format.json {
        render json: current_user.forms.limit(100), each_serializer: FormSerializer
      }
    end
  end

  def show
    form = current_user.forms.find_by_short_uuid(params[:id])
    page_num = (params[:page].present? ? params[:page].to_i : 0)
    page_size = (params[:page_size].present? ? params[:page_size].to_i : 500)
    page_size = 5000 if page_size > 5000
    # Date filter defaults to 1 year ago and 1 day from now
    # Is there ever a case where we'd want to see submissions older than a year via the API?
    begin
      start_date = params[:start_date] ? Date.parse(params[:start_date]).to_date : 1.year.ago
      end_date = params[:end_date] ? Date.parse(params[:end_date]).to_date : 1.day.from_now
    rescue
      render json: { error: { message: "invalid date format, should be 'YYYY-MM-DD'", status: 400 } }, status: 400 and return
    end
    respond_to do |format|
      format.json {
        if form
          render json: form, include: [:questions, :submissions], serializer: FullFormSerializer, page_num: page_num, page_size: page_size, start_date: start_date, end_date: end_date
        else
          render json: { error: { message: "no form with Short UUID of #{params[:id]}", status: 404 } }, status: 404
        end
      }
    end
  end
end
