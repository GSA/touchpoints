# frozen_string_literal: true

module Api
  module V1
    class WebsitesController < ::ApiController
      def index
        respond_to do |format|
          format.json do
            render json: Website.active, each_serializer: WebsiteSerializer
          end
        end
      end
    end
  end
end
