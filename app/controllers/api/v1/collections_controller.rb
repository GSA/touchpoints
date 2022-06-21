# frozen_string_literal: true

module Api
  module V1
    class CollectionsController < ::ApiController
      def index
        respond_to do |format|
          format.json do
            render json: Collection.all.order(:id), each_serializer: CollectionSerializer
          end
        end
      end
    end
  end
end
