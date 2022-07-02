# frozen_string_literal: true

module Admin
  class OfferingsController < AdminController
    before_action :set_offering, only: %i[show edit update destroy add_offering_persona remove_offering_persona]

    before_action :set_offering_persona_options, only: %i[
      new
      create
      edit
      update
    ]

    def index
      @offerings = Offering.all.order(:name)
    end

    def show; end

    def new
      @offering = Offering.new
    end

    def edit; end

    def create
      @offering = Offering.new(offering_params)

      if @offering.save
        redirect_to admin_offering_path(@offering), notice: 'Offering was successfully created.'
      else
        render :new
      end
    end

    def update
      if @offering.update(offering_params)
        redirect_to admin_offering_path(@offering), notice: 'Offering was successfully updated.'
      else
        render :edit
      end
    end

    def destroy
      @offering.destroy
      redirect_to admin_offerings_url, notice: 'Offering was successfully destroyed.'
    end

    def add_offering_persona
      @offering.persona_list.add(params[:persona_id])
      @offering.save
      set_offering_persona_options
    end

    def remove_offering_persona
      @offering.persona_list.remove(params[:persona_id])
      @offering.save
      set_offering_persona_options
    end

    private

    def set_offering
      @offering = Offering.find(params[:id])
    end

    def offering_params
      params.require(:offering).permit(:name, :service_id)
    end

    def set_offering_persona_options
      @offering_persona_options = Persona.all.order(:name)
      @offering_persona_options -= @offering.offering_personas if @offering_persona_options && @offering
    end
  end
end
