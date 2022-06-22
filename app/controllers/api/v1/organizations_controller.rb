# frozen_string_literal: true

module Api
  module V1
    class OrganizationsController < ::ApiController
      def index
        respond_to do |format|
          format.json do
            render json: Organization.all.order(:id), each_serializer: OrganizationSerializer
          end
        end
      end
    end
  end
end
