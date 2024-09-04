# frozen_string_literal: true

module Api
  module V1
    class ServicesStagesController < ::ApiController
      def index
        respond_to do |format|
          format.json do
            if params[:hisp].present? && params[:hisp].to_s == '1'
              render json: ServiceStage.hisp.order(:id), each_serializer: ServiceStageSerializer
            else
              render json: ServiceStage.all.order(:id), each_serializer: ServiceStageSerializer
            end
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
