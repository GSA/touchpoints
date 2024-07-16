# frozen_string_literal: true

module Api
  module V1
    class CxCollectionsController < ::ApiController
      def index
        respond_to do |format|
          format.json do
            if params[:all].present? && params[:all].to_s == '1'
              render json: CxCollection.all.order(:id), each_serializer: CxCollectionSerializer
            else
              render json: CxCollection.published.order(:id), each_serializer: CxCollectionSerializer
            end
          end
        end
      end
    end
  end
end
