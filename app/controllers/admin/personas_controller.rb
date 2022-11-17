# frozen_string_literal: true

module Admin
  class PersonasController < AdminController
    before_action :set_persona, only: %i[show edit update destroy add_tag remove_tag]

    def index
      @personas = Persona.all.order(:name)
    end

    def show; end

    def new
      @persona = Persona.new
    end

    def edit; end

    def create
      @persona = Persona.new(persona_params)

      if @persona.save!
        redirect_to admin_persona_path(@persona), notice: 'Persona was successfully created.'
      else
        render :new
      end
    end

    def update
      if @persona.update(persona_params)
        redirect_to admin_persona_path(@persona), notice: 'Persona was successfully updated.'
      else
        render :edit
      end
    end

    def destroy
      @persona.destroy
      redirect_to admin_personas_url, notice: 'Persona was successfully destroyed.'
    end

    def add_tag
      @persona.tag_list.add(persona_params[:tag_list].split(','))
      @persona.save
    end

    def remove_tag
      @persona.tag_list.remove(persona_params[:tag_list].split(','))
      @persona.save
    end

    private

    def set_persona
      @persona = Persona.find(params[:id])
    end

    def persona_params
      params.require(:persona).permit(
        :name,
        :description,
        :notes,
        :user_id,
        :tag_list,
      )
    end
  end
end
