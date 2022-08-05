# frozen_string_literal: true

module Api
  module V1
    class ServicesController < ::ApiController
      def index
        respond_to do |format|
          format.json do
            render json: Service.all.order(:id), each_serializer: ServiceSerializer
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
