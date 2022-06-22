# frozen_string_literal: true

module Api
  module V1
    class GoalsController < ::ApiController
      def index
        respond_to do |format|
          format.json do
            render json: Goal.all.order(:id), each_serializer: GoalSerializer
          end
        end
      end
    end
  end
end
