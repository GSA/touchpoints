class Admin::FormsController < AdminController
  before_action :set_form, only: [:show, :edit, :update, :copy, :destroy]
  before_action :set_touchpoint, only: [:show, :edit]

  def index
    if admin_permissions?
      @forms = Form.all.order("name ASC")
    else
      @forms = current_user.forms.order("name ASC").entries
      @forms = @forms + current_user.managed_forms
      @forms = @forms + Form.templates
    end
  end

  def show
    ensure_touchpoint_manager(touchpoint: @touchpoint) unless @form.template?
    @touchpoint = @form.touchpoint
    @questions = @form.questions
  end

  def new
    @form = Form.new
    @form.modal_button_text = I18n.t('form.help_improve')
    @form.success_text = I18n.t('form.submit_thankyou')
  end

  def edit
    ensure_touchpoint_manager(touchpoint: @touchpoint)
  end

  def create
    ensure_touchpoint_manager(touchpoint: @touchpoint)

    @form = Form.new(form_params)
    unless @form.user
      @form.user = current_user
    end

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

  def copy
    respond_to do |format|
      new_form = @form.duplicate!(user: current_user)

      if new_form.valid?
        format.html { redirect_to admin_form_path(new_form), notice: 'Form was successfully copied.' }
        format.json { render :show, status: :created, location: new_form }
      else
        format.html { render :new }
        format.json { render json: new_form.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    ensure_touchpoint_manager(touchpoint: @touchpoint)

    respond_to do |format|
      if @form.update(form_params)
        format.html {
          if @form.touchpoint
            redirect_to admin_touchpoint_form_path(@form.touchpoint, @form), notice: 'Form was successfully updated.'
          else
            redirect_to admin_form_path(@form), notice: 'Form was successfully updated.'
          end
        }
        format.json { render :show, status: :ok, location: @form }
      else
        format.html { render :edit }
        format.json { render json: @form.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    ensure_touchpoint_manager(touchpoint: @touchpoint)

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

    def set_touchpoint
      @touchpoint = Touchpoint.find_by_id(params[:touchpoint_id])
    end

    def form_params
      params.require(:form).permit(
        :user_id,
        :template,
        :name,
        :kind,
        :early_submission,
        :character_limit,
        :notes,
        :status,
        :title,
        :modal_button_text,
        :success_text,
        :instructions,
        :display_header_logo,
        :display_header_square_logo,
        :whitelist_url,
        :whitelist_test_url,
        :disclaimer_text,
        :question_text_01,
        :question_text_02,
        :question_text_03,
        :question_text_04,
        :question_text_05,
        :question_text_06,
        :question_text_07,
        :question_text_08,
        :question_text_09,
        :question_text_10,
        :question_text_11,
        :question_text_12,
        :question_text_13,
        :question_text_14,
        :question_text_15,
        :question_text_16,
        :question_text_17,
        :question_text_18,
        :question_text_19,
        :question_text_20
      )
    end
end
