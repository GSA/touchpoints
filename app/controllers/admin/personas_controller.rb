class Admin::PersonasController < AdminController
  before_action :set_persona, only: [:show, :edit, :update, :destroy]

  def index
    @personas = Persona.all
  end

  def show
  end

  def new
    @persona = Persona.new
  end

  def edit
  end

  def create
    @persona = Persona.new(persona_params)
    @persona.user = current_user


    if @persona.save
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

  private
    def set_persona
      @persona = Persona.find(params[:id])
    end

    def persona_params
      params.require(:persona).permit(:name, :description, :tags, :notes, :user_id)
    end
end
