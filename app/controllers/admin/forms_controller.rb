# frozen_string_literal: true

require 'csv'

module Admin
  class FormsController < AdminController
    respond_to :html, :js, :docx

    skip_before_action :verify_authenticity_token, only: [:js]
    before_action :set_user, only: %i[add_user remove_user]
    before_action :set_form, only: %i[
      show edit update destroy
      compliance
      permissions questions responses delivery
      copy copy_by_id
      invite
      notifications
      export
      export_pra_document
      export_submissions
      export_a11_header
      export_a11_submissions
      example js trigger
      add_user remove_user
      publish
      archive
      reset
      update_ui_truncation
      update_title update_instructions update_disclaimer_text
      update_success_text update_display_logo
      update_admin_options update_form_manager_options
      events
    ]

    def index
      if admin_permissions?
        if params[:all]
          @forms = Form.non_templates.order('organization_id ASC').order('name ASC')
        else
          @forms = Form.non_archived.non_templates.order('organization_id ASC').order('name ASC')
          @archived_forms = Form.archived.order('organization_id ASC').order('name ASC')
        end
      elsif params[:all]
        @forms = current_user.forms.non_templates.order('organization_id ASC').order('name ASC').entries
      else
        @forms = current_user.forms.non_archived.non_templates.order('organization_id ASC').order('name ASC').entries
        @archived_forms = current_user.forms.archived.order('organization_id ASC').order('name ASC')
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

      render json: { form: @form, questions: }
    end

    def invite
      invitee = invite_params[:refer_user]

      if invitee.present? && invitee =~ URI::MailTo::EMAIL_REGEXP && (ENV['GITHUB_CLIENT_ID'].present? ? true : APPROVED_DOMAINS.any? { |word| invitee.end_with?(word) })
        if User.exists?(email: invitee)
          redirect_to permissions_admin_form_path(@form), alert: "User with email #{invitee} already exists"
        else
          UserMailer.invite(current_user, invitee).deliver_later
          redirect_to permissions_admin_form_path(@form), notice: "Invite sent to #{invitee}"
        end
      elsif ENV['GITHUB_CLIENT_ID'].present?
        redirect_to permissions_admin_form_path(@form), alert: 'Please enter a valid email address'
      else
        redirect_to permissions_admin_form_path(@form), alert: 'Please enter a valid .gov or .mil email address'
      end
    end

    def publish
      Event.log_event(Event.names[:form_published], 'Form', @form.uuid, "Form #{@form.name} published at #{DateTime.now}", current_user.id)

      @form.publish!
      UserMailer.form_status_changed(form: @form, action: 'published').deliver_later
      redirect_to admin_form_path(@form), notice: 'Published'
    end

    def archive
      Event.log_event(Event.names[:form_archived], 'Form', @form.uuid, "Form #{@form.name} archived at #{DateTime.now}", current_user.id)

      @form.archive!
      UserMailer.form_status_changed(form: @form, action: 'archived').deliver_later
      redirect_to admin_form_path(@form), notice: 'Archived'
    end

    def reset
      Event.log_event(Event.names[:form_reset], 'Form', @form.uuid, "Form #{@form.name} reset at #{DateTime.now}", current_user.id)

      @form.reset!
      redirect_to admin_form_path(@form), notice: 'Form has been reset'
    end

    def update_title
      ensure_form_manager(form: @form)
      @form.update!(title: params[:title])
      render json: @form
    end

    def update_instructions
      ensure_form_manager(form: @form)
      @form.update!(instructions: params[:instructions])
      render json: @form
    end

    def update_disclaimer_text
      ensure_form_manager(form: @form)
      @form.update!(disclaimer_text: params[:disclaimer_text])
      render json: @form
    end

    def update_success_text
      ensure_form_manager(form: @form)
      @form.update!(success_text: params[:success_text], success_text_heading: params[:success_text_heading])
      render(partial: 'admin/questions/success_text', locals: { form: @form })
    end

    def update_display_logo
      ensure_form_manager(form: @form)
      @form.update(form_logo_params)
    end

    def update_admin_options
      ensure_form_manager(form: @form)
      @form.update(form_admin_options_params)
      flash.now[:notice] = 'Admin form options updated successfully'
    end

    def update_form_manager_options
      ensure_form_manager(form: @form)
      @form.update(form_admin_options_params)
      flash.now[:notice] = 'Form Manager forms options updated successfully'
    end

    def show
      ensure_response_viewer(form: @form) unless @form.template?
      @questions = @form.questions
    end

    def permissions
      ensure_form_manager(form: @form)
      if admin_permissions?
        @available_members = User.all.order(:email) - @form.users
      else
        @available_members = @form.organization.users.active.order(:email) - @form.users
      end
    end

    def questions
      ensure_form_manager(form: @form) unless @form.template?
      @questions = @form.questions
    end

    def responses
      FormCache.invalidate_reports(@form.short_uuid) if params['use_cache'].present? && params['use_cache'] == 'false'
      ensure_response_viewer(form: @form) unless @form.template?
    end

    def delivery
      ensure_form_manager(form: @form)
    end

    def example
      redirect_to touchpoint_path, notice: 'Previewing Touchpoint' and return if @form.delivery_method == 'touchpoints-hosted-only'
      redirect_to admin_forms_path, notice: "Form does not have a delivery_method of 'modal' or 'inline' or 'custom-button-modal'" and return unless @form.delivery_method == 'modal' || @form.delivery_method == 'inline' || @form.delivery_method == 'custom-button-modal'

      render layout: false
    end

    def js
      render(partial: 'components/widget/fba', formats: :js, locals: { form: @form })
    end

    def new
      @templates = Form.templates
      @form = Form.new
      @surveys = current_user.forms.non_templates.order('organization_id ASC').order('name ASC').entries
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
      @form.modal_button_text = t('form.help_improve')
      @form.success_text_heading = t('success')
      @form.success_text = t('form.submit_thankyou')
      @form.delivery_method = 'touchpoints-hosted-only'
      @form.load_css = true
      @form.user = current_user unless @form.user

      respond_to do |format|
        if @form.save
          Event.log_event(Event.names[:form_created], 'Form', @form.uuid, "Form #{@form.name} created at #{DateTime.now}", current_user.id)

          UserRole.create!({
                             user: current_user,
                             form: @form,
                             role: UserRole::Role::FormManager,
                           })

          format.html { redirect_to questions_admin_form_path(@form), notice: 'Form was successfully created.' }
          format.json { render :show, status: :created, location: @form }
        else
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @form.errors, status: :unprocessable_entity }
        end
      end
    end

    def copy
      respond_to do |format|
        new_form = @form.duplicate!(new_user: current_user)

        if new_form.valid?
          @role = UserRole.create!({
                                     user: current_user,
                                     form: new_form,
                                     role: UserRole::Role::FormManager,
                                   })

          Event.log_event(Event.names[:form_copied], 'Form', @form.uuid, "Form #{@form.name} copied at #{DateTime.now}", current_user.id)

          format.html { redirect_to admin_form_path(new_form), notice: 'Form was successfully copied.' }
          format.json { render :show, status: :created, location: new_form }
        else
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: new_form.errors, status: :unprocessable_entity }
        end
      end
    end

    def copy_by_id
      copy
    end

    def update_ui_truncation
      ensure_response_viewer(form: @form)

      respond_to do |format|
        if @form.update(ui_truncate_text_responses: !@form.ui_truncate_text_responses)
          format.json { render json: {}, status: :ok, location: @form }
        else
          format.json { render json: @form.errors, status: :unprocessable_entity }
        end
      end
    end

    def update
      ensure_form_manager(form: @form)

      transition_state

      respond_to do |format|
        if @form.update(form_params)
          format.html do
            redirect_to get_edit_path(@form), notice: 'Form was successfully updated.'
          end
          format.json { render :show, status: :ok, location: @form }
        else
          format.html { render (params[:form][:delivery_method].present? ? :delivery : :edit), status: :unprocessable_entity }
          format.json { render json: @form.errors, status: :unprocessable_entity }
        end
      end
    end

    # Start building our wizard workflow
    def get_edit_path(form)
      if params[:form][:delivery_method].present?
        delivery_admin_form_path(form)
      else
        admin_form_path(form)
      end
    end

    def destroy
      ensure_form_manager(form: @form)

      respond_to do |format|
        format.html do
          if @form.destroy
            Event.log_event(Event.names[:form_deleted], 'Form', @form.uuid, "Form #{@form.name} deleted at #{DateTime.now}", current_user.id)
            redirect_to admin_forms_url, notice: 'Form was successfully destroyed.'
          else
            redirect_to edit_admin_form_url(@form), notice: @form.errors.full_messages.to_sentence
          end
        end
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
        flash[:notice] = 'User Role successfully added to Form'

        render json: {
          email: @user.email,
          form: @form.short_uuid,
        }
      else
        render json: @role.errors, status: :unprocessable_entity
      end
    end

    # Disassociate a user with a Form
    def remove_user
      @role = @form.user_roles.find_by_user_id(params[:user_id])

      if @role.destroy
        flash[:notice] = 'User Role successfully removed from Form'

        render json: {
          email: @user.email,
          form: @form.short_uuid,
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
        format.html do
          redirect_to admin_form_path(@form)
        end
        format.docx do
          docx = PraForm.part_a(form: @form)
          send_data docx.render.string, filename: "pra-part-a-#{timestamp_string}.docx"
        end
      end
    end

    def export_submissions
      start_date = params[:start_date] ? Date.parse(params[:start_date]).to_date : Time.zone.now.beginning_of_quarter
      end_date = params[:end_date] ? Date.parse(params[:end_date]).to_date : Time.zone.now.end_of_quarter

      respond_to do |format|
        format.csv do
          csv_content = Form.find_by_short_uuid(@form.short_uuid).to_csv(start_date:, end_date:)
          send_data csv_content
        end
        format.json do
          ExportJob.perform_later(params[:uuid], @form.short_uuid, start_date.to_s, end_date.to_s, "touchpoints-form-responses-#{timestamp_string}.csv")
          render json: { result: :ok }
        end
      end
    end

    # A-11 Header report. File 1 of 2
    #
    def export_a11_header
      start_date = params[:start_date] ? Date.parse(params[:start_date]).to_date : Time.zone.now.beginning_of_quarter
      end_date = params[:end_date] ? Date.parse(params[:end_date]).to_date : Time.zone.now.end_of_quarter

      respond_to do |format|
        format.csv do
          send_data @form.to_a11_header_csv(start_date:, end_date:), filename: "a11-header-#{timestamp_string}.csv"
        end
      end
    end

    # A-11 Detail report. File 2 of 2
    #
    def export_a11_submissions
      start_date = Date.parse(params[:start_date]).to_date || Time.zone.now.beginning_of_quarter
      end_date = Date.parse(params[:end_date]).to_date || Time.zone.now.end_of_quarter

      respond_to do |format|
        format.csv do
          send_data @form.to_a11_submissions_csv(start_date:, end_date:), filename: "A-11-Responses-#{timestamp_string}.csv"
        end
      end
    end

    def events
      @events = Event.where(object_type: 'Form', object_id: @form.uuid).order(:created_at)
    end

    private

    def set_form
      @form = Form.find_by_short_uuid(params[:id])
      redirect_to admin_forms_path, notice: "no form with ID of #{params[:id]}" unless @form
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
        :time_zone,
        :delivery_method,
        :element_selector,
        :notification_emails,
        :notification_frequency,
        :logo,
        :modal_button_text,
        :success_text_heading,
        :success_text,
        :instructions,
        :display_header_logo,
        :display_header_square_logo,
        :whitelist_url,
        :whitelist_test_url,
        :disclaimer_text,
        :success_text,
        :success_text_heading,
        :service_id,
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
        :verify_csrf,
        :ui_truncate_text_responses,
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
        :question_text_20,
      )
    end

    def form_logo_params
      params.require(:form).permit(
        :logo,
        :display_header_logo,
        :display_header_square_logo,
      )
    end

    def form_admin_options_params
      params.require(:form).permit(
        :name,
        :time_zone,
        :organization_id,
        :user_id,
        :template,
        :kind,
        :aasm_state,
        :early_submission,
        :notes,
        :status,
        :title,
        :load_css,
        :omb_approval_number,
        :expiration_date,
        :service_id,
      )
    end

    # Add rules for AASM state transitions here
    def transition_state
      Event.log_event(Event.names[:form_published], 'Form', @form.uuid, "Form #{@form.name} published at #{DateTime.now}", current_user.id) if (params['form']['aasm_state'] == 'live') && !@form.live?
      Event.log_event(Event.names[:form_archived], 'Form', @form.uuid, "Form #{@form.name} archived at #{DateTime.now}", current_user.id) if (params['form']['aasm_state'] == 'archived') && !@form.archived?
    end

    def invite_params
      params.require(:user).permit(:refer_user)
    end
  end
end
