# frozen_string_literal: true

module Api
  module V1
    class ServicesStagesController < ::ApiController
      def index
        respond_to do |format|
          format.json do
            render json: ServiceStage.order(:id), each_serializer: ServiceStageSerializer
          end
        end
      end

      def show
        respond_to do |format|
          format.json do
            render json: ServiceStage.find(params[:id]), serializer: ServiceStageSerializer
          end
        end
      end
    end
  end
end
