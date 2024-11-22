# frozen_string_literal: true

module Api
  module V1
    class PersonasController < ::ApiController
      def index
        respond_to do |format|
          format.json do
            render json: Persona.order(:id), each_serializer: PersonaSerializer
          end
        end
      end
    end
  end
end
