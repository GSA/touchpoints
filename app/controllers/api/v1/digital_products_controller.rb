# frozen_string_literal: true

module Api
  module V1
    class DigitalProductsController < ::UnauthenticatedApiController
      def index
        respond_to do |format|
          format.json do
            render json: DigitalProduct.all.order(:id), each_serializer: DigitalProductSerializer
          end
        end
      end

      def show
        @digital_product = DigitalProduct.find(params[:id])

        respond_to do |format|
          format.json do
            render json: @digital_product, serializer: DigitalProductSerializer
          end
        end
      end
    end
  end
end
