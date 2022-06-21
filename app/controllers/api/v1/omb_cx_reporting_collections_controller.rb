# frozen_string_literal: true

module Api
  module V1
    class OmbCxReportingCollectionsController < ::ApiController
      def index
        respond_to do |format|
          format.json do
            render json: OmbCxReportingCollection.all.order(:id), each_serializer: OmbCxReportingCollectionSerializer
          end
        end
      end
    end
  end
end
