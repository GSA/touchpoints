# frozen_string_literal: true

module Api
  module V1
    class CxCollectionDetailsController < ::ApiController
      def index
        respond_to do |format|
          format.json do
            render json: CxCollectionDetail.all.order(:id), each_serializer: CxCollectionDetailSerializer
          end
        end
      end
    end
  end
end
