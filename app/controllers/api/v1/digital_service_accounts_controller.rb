class Api::V1::DigitalServiceAccountsController < ::UnauthenticatedApiController
  def index
    page = (params[:page].present? ? params[:page].to_i : 0)
    size = (params[:size].present? ? params[:size].to_i : 100)
    size = 100 if size > 100

    respond_to do |format|
      format.json {
        render json: DigitalServiceAccount.limit(100).order(:id),
               each_serializer: DigitalServiceAccountSerializer,
               links: links(form, page, size),
               page: page,
               size: size
      }
    end
  end

  def show
    @digital_service_account = DigitalServiceAccount.find(params[:id])

    respond_to do |format|
      format.json {
        render json: @digital_service_account,
               serializer: DigitalServiceAccountSerializer
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
