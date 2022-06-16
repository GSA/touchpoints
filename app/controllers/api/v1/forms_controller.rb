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
    page = (params[:page].present? ? params[:page].to_i : 0)
    size = (params[:size].present? ? params[:size].to_i : 500)
    size = 5000 if size > 5000
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
          render json: form, include: [:questions, :submissions], serializer: FullFormSerializer, links: links(form, page, size), page: page, size: size, start_date: start_date, end_date: end_date
        else
          render json: { error: { message: "no form with Short UUID of #{params[:id]}", status: 404 } }, status: 404
        end
      }
    end
  end

  def links(form, page, size)
    ret = {}
    if params[:page].present?
      ret["first"] = request.original_url.gsub(/page=[0-9]+/i, "page=0")
      ret["next"] = request.original_url.gsub(/page=[0-9]+/i, "page=" + (page + 1).to_s) if (form.submissions.size > ((page + 1) * size))
      ret["prev"] = request.original_url.gsub(/page=[0-9]+/i, "page=" + (page - 1).to_s) if page > 0
      ret["last"] = request.original_url.gsub(/page=[0-9]+/i, "page=" + (form.submissions.size / size).floor.to_s)
    else
      ret["first"] = request.original_url + "&page=0"
      ret["next"] = request.original_url + "&page=1" if form.submissions.size > size
      ret["last"] = request.original_url + "&page=" + (form.submissions.size / size).floor.to_s
    end
    ret
  end
end
