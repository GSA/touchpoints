class Api::V1::OrganizationsController < ::ApiController
  def index
    respond_to do |format|
      format.json {
        render json: Organization.all.order(:id), each_serializer: OrganizationSerializer
      }
    end
  end
end
