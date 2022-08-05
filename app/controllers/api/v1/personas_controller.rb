# frozen_string_literal: true

module Api
  module V1
    class PersonasController < ::ApiController
      def index
        respond_to do |format|
          format.json do
            render json: Persona.all, each_serializer: PersonaSerializer
          end
        end
      end
    end
  end
end
