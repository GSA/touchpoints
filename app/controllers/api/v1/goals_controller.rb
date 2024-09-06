# frozen_string_literal: true

module Api
  module V1
    class GoalsController < ::ApiController
      def index
        respond_to do |format|
          format.json do
            if params[:include_users]
              render json: Goal.order(:id), each_serializer: GoalSerializer, include_users: true
            else
              render json: Goal.order(:id), each_serializer: GoalSerializer
            end
          end
        end
      end
    end
  end
end
