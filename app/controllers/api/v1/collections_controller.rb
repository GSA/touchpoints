# frozen_string_literal: true

module Api
  module V1
    class CollectionsController < ::ApiController
      def index
        respond_to do |format|
          format.json do
            if params[:all].present? && params[:all].to_s == '1'
              render json: Collection.order(:id), each_serializer: CollectionSerializer
            else
              render json: Collection.published.order(:id), each_serializer: CollectionSerializer
            end
          end
        end
      end
    end
  end
end
