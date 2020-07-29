class Admin::FormSectionsController < AdminController
  before_action :set_form, only: [:new, :create, :index, :show, :edit, :update, :destroy]
  before_action :set_form_section, only: [:show, :edit, :update, :destroy]

  def index
    @form_sections = @form.form_sections
  end

  def show
  end

  def new
    @form_section = @form.form_sections.new
  end

  def edit
    render layout: false
  end

  def create
    @form_section = @form.form_sections.new(form_section_params)

    if @form_section.save
      redirect_to questions_admin_form_path(@form), notice: 'Form section was successfully created.'
    else
      render :new
    end
  end

  def update
    if @form_section.update(form_section_params)
      redirect_to questions_admin_form_url(@form), notice: 'Form section was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    if @form.form_sections.count > 1
      @form_section.destroy
      redirect_to edit_admin_form_url(@form), notice: 'Form section was successfully destroyed.'
    else
      redirect_to edit_admin_form_url(@form), alert: 'Cannot delete only remaining Form section'
    end
  end

  private
    def set_form_section
      @form_section = FormSection.find(params[:id])
    end

    def set_form
      @form = Form.find_by_short_uuid(params[:form_id])
    end

    def form_section_params
      params.require(:form_section).permit(:title, :position, :next_section_id)
    end
end
