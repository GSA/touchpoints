# frozen_string_literal: true

module Api
  module V1
    class UsersController < ::ApiController
      def index
        respond_to do |format|
          format.json do
            render json: User.active.order(:id), each_serializer: UserSerializer
          end
        end
      end
    end
  end
end
