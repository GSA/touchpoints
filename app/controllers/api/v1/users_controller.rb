class Api::V1::UsersController < ::ApiController
  def index
    respond_to do |format|
      format.json {
        render json: User.active, each_serializer: UserSerializer
      }
    end
  end
end
