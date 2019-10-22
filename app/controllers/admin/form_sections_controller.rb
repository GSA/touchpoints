class Admin::FormSectionsController < AdminController
  before_action :set_form, only: [:new, :create, :show, :edit, :update, :destroy]
  before_action :set_form_section, only: [:show, :edit, :update, :destroy]

  # GET /form_sections
  def index
    @form_sections = FormSection.all
  end

  # GET /form_sections/1
  def show
  end

  # GET /form_sections/new
  def new
    @form_section = FormSection.new
    @form_section.form = @form
  end

  # GET /form_sections/1/edit
  def edit
  end

  # POST /form_sections
  def create
    @form_section = FormSection.new(form_section_params)

    if @form_section.save
      redirect_to admin_form_form_section_path(@form, @form_section), notice: 'Form section was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /form_sections/1
  def update
    if @form_section.update(form_section_params)
      redirect_to admin_form_form_section_path(@form, @form_section), notice: 'Form section was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /form_sections/1
  def destroy
    @form_section.destroy
    redirect_to edit_admin_form_url(@form), notice: 'Form section was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_form_section
      @form_section = FormSection.find(params[:id])
    end

    def set_form
      @form = Form.find(params[:form_id])
    end

    # Only allow a trusted parameter "white list" through.
    def form_section_params
      params.require(:form_section).permit(:form_id, :title, :position, :next_section_id)
    end
end
