require 'csv'

class Admin::FormsController < AdminController
  respond_to :html, :js, :docx

  skip_before_action :verify_authenticity_token, only: [:js]
  before_action :set_user, only: [:add_user, :remove_user]
  before_action :set_form, only: [
    :show, :edit, :update, :destroy,
    :compliance,
    :permissions, :questions, :responses,
    :copy, :copy_by_id,
    :notifications,
    :export,
    :export_pra_document,
    :export_submissions,
    :export_a11_header,
    :export_a11_submissions,
    :example, :js, :trigger,
    :add_user, :remove_user,
    :publish, :update_title
  ]

  def index
    if admin_permissions?
      @forms = Form.non_templates.order("organization_id ASC").order("name ASC")
    else
      @forms = current_user.forms.non_templates.order("organization_id ASC").order("name ASC").entries
    end
  end

  def export
    questions = []
    @form.questions.each do |q|
      attrs = q.attributes

      if q.question_options.present?
        attrs[:question_options] = []
        q.question_options.each do |qo|
          attrs[:question_options] << qo.attributes
        end
      end

      questions << attrs
    end

    render json: { form: @form, questions: questions }
  end

  def publish
    Event.log_event(Event.names[:form_published], "Form", @form.uuid,"Form #{@form.name} published at #{DateTime.now}", current_user.id)

    @form.update_attribute(:aasm_state, :live)
    redirect_to admin_form_path(@form), notice: "Published"
  end

  def update_title
    return unless params[:title] && params[:title].length > 1
    @form.update!(title: params[:title], name: params[:title])

    head :ok
  end

  def show
    ensure_response_viewer(form: @form) unless @form.template?
    @questions = @form.questions
  end

  def permissions
    ensure_form_manager(form: @form)
    if admin_permissions?
      @available_members = User.all - @form.users
    else
      @available_members = @form.organization.users - @form.users
    end
  end

  def questions
    ensure_form_manager(form: @form) unless @form.template?
    @questions = @form.questions
  end

  def responses
    ensure_response_viewer(form: @form) unless @form.template?
    @response_groups = @form.submissions.group("date(created_at)").size.sort.last(45)
  end

  def example
    redirect_to touchpoint_path, notice: "Previewing Touchpoint" and return if @form.delivery_method == "touchpoints-hosted-only"
    redirect_to admin_forms_path, notice: "Form does not have a delivery_method of 'modal' or 'inline' or 'custom-button-modal'" and return unless @form.delivery_method == "modal" || @form.delivery_method == "inline" || @form.delivery_method == "custom-button-modal"

    render layout: false
  end

  def js
    render(partial: "components/widget/fba.js", locals: { form: @form })
  end

  def new
    @templates = Form.templates
    @form = Form.new
    @surveys = current_user.forms.non_templates.order("organization_id ASC").order("name ASC").entries
  end

  def edit
    ensure_form_manager(form: @form)
  end

  def notifications
    ensure_form_manager(form: @form)
  end

  def create
    ensure_form_manager(form: @form)

    @form = Form.new(form_params)

    @form.organization_id = current_user.organization_id
    @form.user_id = current_user.id
    @form.title = @form.name
    @form.modal_button_text = I18n.t('form.help_improve')
    @form.success_text = I18n.t('form.submit_thankyou')
    @form.delivery_method = "touchpoints-hosted-only"
    @form.load_css = true
    unless @form.user
      @form.user = current_user
    end

    respond_to do |format|
      if @form.save
        UserRole.create!({
          user: current_user,
          form: @form,
          role: UserRole::Role::FormManager
        })

        format.html { redirect_to questions_admin_form_path(@form), notice: 'Survey was successfully created.' }
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
        @role = UserRole.create!({
          user: current_user,
          form: new_form,
          role: UserRole::Role::FormManager
        })

        Event.log_event(Event.names[:form_copied], "Form", @form.uuid, "Form #{@form.name} copied at #{DateTime.now}", current_user.id)

        format.html { redirect_to questions_admin_form_path(new_form), notice: 'Survey was successfully copied.' }
        format.json { render :show, status: :created, location: new_form }
      else
        format.html { render :new }
        format.json { render json: new_form.errors, status: :unprocessable_entity }
      end
    end
  end

  def copy_by_id
    copy
  end

  def update
    ensure_form_manager(form: @form)

    transition_state

    respond_to do |format|
      if @form.update(form_params)
        format.html {
          redirect_to admin_form_path(@form), notice: 'Survey was successfully updated.'
        }
        format.json { render :show, status: :ok, location: @form }
      else
        format.html { render :edit }
        format.json { render json: @form.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    ensure_form_manager(form: @form)

    respond_to do |format|
      format.html {
        if @form.destroy
          Event.log_event(Event.names[:form_deleted], "Form", @form.uuid,"Form #{@form.name} deleted at #{DateTime.now}", current_user.id)
          redirect_to admin_forms_url, notice: 'Survey was successfully destroyed.'
        else
          redirect_to edit_admin_form_url(@form), notice: @form.errors.full_messages.to_sentence
        end
      }
      format.json { head :no_content }
    end
  end


  # Roles and Permissions
  #
  # Associate a user with a Form
  def add_user
    raise ArgumentException unless current_user.admin? || (@form.user_role?(user: current_user) == UserRole::Role::FormManager)
    raise ArgumentException unless UserRole::ROLES.include?(params[:role])

    @role = UserRole.new({
      user: @user,
      form: @form,
      role: params[:role],
    })

    if @role.save
      flash[:notice] = "User Role successfully added to Form"

      render json: {
          email: @user.email,
          form: @form.short_uuid
        }
    else
      render json: @role.errors, status: :unprocessable_entity
    end
  end

  # Disassociate a user with a Form
  def remove_user
    @role = @form.user_roles.find_by_user_id(params[:user_id])

    if @role.destroy
      flash[:notice] = "User Role successfully removed from Form"

      render json: {
        email: @user.email,
        form: @form.short_uuid
      }
    else
      render json: @role.errors, status: :unprocessable_entity
    end
  end


  # Data reporting
  #
  #
  def export_pra_document
    respond_to do |format|
      format.html {
        redirect_to admin_form_path(@form)
      }
      format.docx {
        docx = PraForm.part_a(form: @form)
        send_data docx.render.string, filename: "pra-part-a-#{timestamp_string}.docx"
      }
    end
  end

  def export_submissions
    start_date = params[:start_date] ? Date.parse(params[:start_date]).to_date : Time.now.beginning_of_quarter
    end_date = params[:end_date] ? Date.parse(params[:end_date]).to_date : Time.now.end_of_quarter

    respond_to do |format|
      format.csv {
        csv_content = Form.find_by_short_uuid(@form.short_uuid).to_csv(start_date: start_date, end_date: end_date)
        send_data csv_content
      }
      format.json {
        ExportJob.perform_later(params[:uuid], @form.short_uuid, start_date.to_s, end_date.to_s, "touchpoints-form-responses-#{timestamp_string}.csv")
        render json: { result: :ok }
      }
    end
  end

  # A-11 Header report. File 1 of 2
  #
  def export_a11_header
    start_date = params[:start_date] ? Date.parse(params[:start_date]).to_date : Time.now.beginning_of_quarter
    end_date = params[:end_date] ? Date.parse(params[:end_date]).to_date : Time.now.end_of_quarter

    respond_to do |format|
      format.csv {
        send_data @form.to_a11_header_csv(start_date: start_date, end_date: end_date), filename: "a11-header-#{timestamp_string}.csv"
      }
    end
  end

  # A-11 Detail report. File 2 of 2
  #
  def export_a11_submissions
    start_date = Date.parse(params[:start_date]).to_date || Time.now.beginning_of_quarter
    end_date = Date.parse(params[:end_date]).to_date || Time.now.end_of_quarter

    respond_to do |format|
      format.csv {
        send_data @form.to_a11_submissions_csv(start_date: start_date, end_date: end_date), filename: "A-11-Responses-#{timestamp_string}.csv"
      }
    end
  end


  private
    def set_form
      @form = Form.find_by_short_uuid(params[:id])
      redirect_to admin_forms_path, notice: "no survey with ID of #{params[:id]}" unless @form
    end

    def set_user
      @user = User.find(params[:user_id])
    end

    def form_params
      params.require(:form).permit(
        :name,
        :aasm_state,
        :organization_id,
        :user_id,
        :hisp,
        :template,
        :kind,
        :early_submission,
        :notes,
        :status,
        :title,
        :delivery_method,
        :element_selector,
        :notification_emails,
        :logo,
        :modal_button_text,
        :success_text,
        :instructions,
        :display_header_logo,
        :display_header_square_logo,
        :whitelist_url,
        :whitelist_test_url,
        :disclaimer_text,

        # PRA Info
        :omb_approval_number,
        :expiration_date,
        :medium,
        :occasion,
        :federal_register_url,
        :anticipated_delivery_count,
        :service_name,
        :data_submission_comment,
        :survey_instrument_reference,
        :agency_poc_email,
        :agency_poc_name,
        :department,
        :bureau,

        :load_css,

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

    # Add rules for AASM state transitions here
    def transition_state
      if params["form"]["omb_approval_number"].present? and !@form.omb_approval_number.present?
        params["form"]["aasm_state"] = "PRA_approved"
      end
      if params["form"]["aasm_state"] == "live" and !@form.live?
        Event.log_event(Event.names[:form_published], "Form", @form.uuid, "Form #{@form.name} published at #{DateTime.now}", current_user.id)
      end
      if params["form"]["aasm_state"] == "archived" and !@form.archived?
        Event.log_event(Event.names[:form_archived], "Form", @form.uuid, "Form #{@form.name} archived at #{DateTime.now}", current_user.id)
      end
    end
end
