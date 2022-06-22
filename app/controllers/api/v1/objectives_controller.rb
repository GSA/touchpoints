# frozen_string_literal: true

module Api
  module V1
    class ObjectivesController < ::ApiController
      def index
        respond_to do |format|
          format.json do
            render json: Objective.all.order(:id), each_serializer: ObjectiveSerializer
          end
        end
      end
    end
  end
end
