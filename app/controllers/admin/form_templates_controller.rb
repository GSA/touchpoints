class Admin::FormTemplatesController < AdminController
  before_action :ensure_admin, only: [:new, :create, :edit]
  before_action :set_form_template, only: [:show, :edit, :update, :destroy]

  def index
    @form_templates = FormTemplate.all
  end

  def show
  end

  def new
    @form_template = FormTemplate.new
  end

  def edit
  end

  def create
    @form_template = FormTemplate.new(form_template_params)

    respond_to do |format|
      if @form_template.save
        format.html { redirect_to admin_form_template_path(@form_template), notice: 'Form template was successfully created.' }
        format.json { render :show, status: :created, location: @form_template }
      else
        format.html { render :new }
        format.json { render json: @form_template.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @form_template.update(form_template_params)
        format.html { redirect_to admin_form_template_path(@form_template), notice: 'Form template was successfully updated.' }
        format.json { render :show, status: :ok, location: @form_template }
      else
        format.html { render :edit }
        format.json { render json: @form_template.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @form_template.destroy
    respond_to do |format|
      format.html { redirect_to admin_form_templates_url, notice: 'Form template was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    def set_form_template
      @form_template = FormTemplate.find(params[:id])
    end

    def form_template_params
      params.require(:form_template).permit(:name, :title, :instructions, :disclaimer_text, :kind, :notes, :status)
    end
end
