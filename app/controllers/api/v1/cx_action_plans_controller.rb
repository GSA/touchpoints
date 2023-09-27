# frozen_string_literal: true

module Api
  module V1
    class CxActionPlansController < ::ApiController
      def index
        respond_to do |format|
          format.json do
            render json: CxActionPlan.order(:id), each_serializer: CxActionPlanSerializer
          end
        end
      end

      def show
        respond_to do |format|
          format.json do
            render json: CxActionPlan.find(params[:id]), serializer: CxActionPlanSerializer
          end
        end
      end
    end
  end
end
