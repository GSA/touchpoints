# frozen_string_literal: true

module Api
  module V1
    class ServicesController < ::ApiController
      def index
        respond_to do |format|
          format.json do
            if params[:hisp].present? && params[:hisp].to_s == '1'
              render json: Service.hisp.order(:id), each_serializer: ServiceSerializer
            else
              render json: Service.order(:id), each_serializer: ServiceSerializer
            end
          end
        end
      end

      def show
        respond_to do |format|
          format.json do
            render json: Service.find(params[:id]), serializer: ServiceSerializer
          end
        end
      end
    end
  end
end
