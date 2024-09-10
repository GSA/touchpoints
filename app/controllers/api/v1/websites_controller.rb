# frozen_string_literal: true

module Api
  module V1
    class WebsitesController < ::ApiController
      def index
        respond_to do |format|
          format.json do
            if params[:all].present? && params[:all].to_s == '1'
              render json: Website.order(:id), each_serializer: WebsiteSerializer
            else
              render json: Website.published.order(:id), each_serializer: WebsiteSerializer
            end
          end
        end
      end
    end
  end
end
