class Admin::FormsController < AdminController
  before_action :set_form, only: [:show, :edit, :update, :destroy]
  before_action :ensure_admin

  def index
    @forms = Form.all
  end

  def show
  end

  def new
    @form = Form.new
  end

  def edit
  end

  def create
    @form = Form.new(form_params)

    respond_to do |format|
      if @form.save
        format.html { redirect_to admin_form_path(@form), notice: 'Form was successfully created.' }
        format.json { render :show, status: :created, location: @form }
      else
        format.html { render :new }
        format.json { render json: @form.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @form.update(form_params)
        format.html { redirect_to admin_form_path(@form), notice: 'Form was successfully updated.' }
        format.json { render :show, status: :ok, location: @form }
      else
        format.html { render :edit }
        format.json { render json: @form.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @form.destroy
    respond_to do |format|
      format.html { redirect_to admin_forms_url, notice: 'Form was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    def set_form
      @form = Form.find(params[:id])
    end

    def form_params
      params.require(:form).permit(:name, :notes, :status, :title, :instructions, :disclaimer_text)
    end
end
