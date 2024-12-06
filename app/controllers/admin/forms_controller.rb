# frozen_string_literal: true

require 'csv'

module Admin
  class FormsController < AdminController
    respond_to :html, :js

    skip_before_action :verify_authenticity_token, only: [:js]
    before_action :set_user, only: %i[add_user remove_user]
    before_action :set_form, only: %i[
      show edit update destroy
      compliance
      permissions questions responses delivery
      copy copy_by_id
      notifications
      export
      export_a11_v2_submissions
      export_form_and_a11_v2_submissions
      export_a11_header
      export_a11_submissions
      example js
      add_user remove_user
      submit
      approve
      publish
      archive
      reset
      add_tag remove_tag
      update_ui_truncation
      update_title update_instructions update_disclaimer_text
      update_success_text update_display_logo
      update_notification_emails
      update_admin_options update_form_manager_options
      events
    ]

    # Maximum number of rows that may be exported to csv
    MAX_ROWS_TO_EXPORT = 300_000

    def index
      if form_search_params[:aasm_state].present?
        @status = form_search_params[:aasm_state]
      else
        @status = "published"
        params[:aasm_state] = @status # set the filter and dropdown by default
      end

      @forms = Form.filtered_forms(@current_user, @status)
      @tags = @forms.collect(&:tag_list).flatten.uniq.sort
    end

    def submit
      ensure_form_manager(form: @form)
      @event = Event.log_event(Event.names[:form_submitted], 'Form', @form.uuid, "Form #{@form.name} submitted at #{DateTime.now}", current_user.id)

      @form.submit!
      UserMailer.form_status_changed(form: @form, action: 'submitted', event: @event).deliver_later
      redirect_to admin_form_path(@form), notice: 'This form has been Submitted successfully.'
    end

    def approve
      ensure_form_approver_permissions
      @event = Event.log_event(Event.names[:form_approved], 'Form', @form.uuid, "Form #{@form.name} approved at #{DateTime.now}", current_user.id)

      @form.approve!
      UserMailer.form_status_changed(form: @form, action: 'approved', event: @event).deliver_later
      redirect_to admin_form_path(@form), notice: 'This form has been Approved successfully.'
    end

    def publish
      ensure_form_manager(form: @form)
      @event = Event.log_event(Event.names[:form_published], 'Form', @form.uuid, "Form #{@form.name} published at #{DateTime.now}", current_user.id)

      @form.publish!
      UserMailer.form_status_changed(form: @form, action: 'published', event: @event).deliver_later
      redirect_to admin_form_path(@form), notice: 'This form has been Published successfully.'
    end

    def archive
      ensure_form_manager(form: @form)
      @event = Event.log_event(Event.names[:form_archived], 'Form', @form.uuid, "Form #{@form.name} archived at #{DateTime.now}", current_user.id)

      @form.archive!
      UserMailer.form_feedback(form_id: @form.id, email: current_user.email).deliver_later if (@form.response_count >= 10 && @form.created_at < Time.now - 7.days)
      UserMailer.form_status_changed(form: @form, action: 'archived', event: @event).deliver_later
      redirect_to admin_form_path(@form), notice: 'This form has been Archived successfully.'
    end

    def reset
      Event.log_event(Event.names[:form_reset], 'Form', @form.uuid, "Form #{@form.name} reset at #{DateTime.now}", current_user.id)

      @form.reset!
      redirect_to admin_form_path(@form), notice: 'This form has been reset.'
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
      if params[:form][:logo_kind] == "square"
        @form.update({
          display_header_square_logo: true,
          display_header_logo: false
        })
      elsif params[:form][:logo_kind] == "banner"
        @form.update({
          display_header_square_logo: false,
          display_header_logo: true
        })
      end
      @form.update(form_logo_params)
    end

    def update_notification_emails
      ensure_form_manager(form: @form)
      notification_emails = params[:emails]
      @form.update_attribute(:notification_emails, notification_emails)
      render json: @form
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
      respond_to do |format|
        format.html do
          ensure_response_viewer(form: @form) unless @form.template?
          @questions = @form.ordered_questions
          @events = @events = Event.where(object_type: 'Form', object_uuid: @form.uuid).order("created_at DESC")
        end

        format.json do
          questions = []
          @form.ordered_questions.each do |q|
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
      end
    end

    def export
      start_date = params[:start_date] ? Date.parse(params[:start_date]).to_date : Time.zone.now.beginning_of_quarter
      end_date = params[:end_date] ? Date.parse(params[:end_date]).to_date : Time.zone.now.end_of_quarter

      count = Form.find_by_short_uuid(@form.short_uuid).non_flagged_submissions(start_date:, end_date:).count
      if count > MAX_ROWS_TO_EXPORT
        render status: :bad_request, plain: "Your response set contains #{helpers.number_with_delimiter count} responses and is too big to be exported from the Touchpoints app. Consider using the Touchpoints API to download large response sets (over #{helpers.number_with_delimiter MAX_ROWS_TO_EXPORT} responses)."
        return
      end

      # for a relatively small download (that doesn't need to be a background job)
      if 1_000 > count
        csv_content = @form.to_csv(start_date:, end_date:)
        send_data csv_content, filename: "touchpoints-form-#{@form.short_uuid}-#{@form.name.parameterize}-responses-#{timestamp_string}.csv"
        return
      else
        ExportJob.perform_later(current_user.email, @form.short_uuid, start_date.to_s, end_date.to_s)
        flash[:success] = UserMailer::ASYNC_JOB_MESSAGE
      end

      redirect_to responses_admin_form_path(@form)
    end

    def permissions
      ensure_form_manager(form: @form)
      if admin_permissions?
        @available_members = User.all.order(:email) - @form.users
      else
        @available_members = current_user.organization.users.active.order(:email) - @form.users
      end
    end

    def questions
      @form.warn_about_not_too_many_questions
      @form.ensure_a11_v2_format if @form.kind == "a11_v2"
      ensure_form_manager(form: @form) unless @form.template?
      @questions = @form.ordered_questions
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
      @templates = Form.templates.order(:name)
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
      @form.title = @form.name
      @form.modal_button_text = t('form.help_improve')
      @form.success_text_heading = t('success')
      @form.success_text = t('form.submit_thankyou')
      @form.delivery_method = 'touchpoints-hosted-only'
      @form.kind = 'custom'
      @form.load_css = true

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

    def export_form_and_a11_v2_submissions
      start_date = params[:start_date] ? Date.parse(params[:start_date]).to_date : Time.zone.now.beginning_of_quarter
      end_date = params[:end_date] ? Date.parse(params[:end_date]).to_date : Time.zone.now.end_of_quarter
      ExportFormAndA11V2Job.perform_later(email: current_user.email, form_uuid: @form.short_uuid, start_date:, end_date:)
      flash[:success] = UserMailer::ASYNC_JOB_MESSAGE
      redirect_to responses_admin_form_path(@form)
    end

    def export_a11_v2_submissions
      start_date = params[:start_date] ? Date.parse(params[:start_date]).to_date : Time.zone.now.beginning_of_quarter
      end_date = params[:end_date] ? Date.parse(params[:end_date]).to_date : Time.zone.now.end_of_quarter
      ExportA11V2Job.perform_later(email: current_user.email, form_uuid: @form.short_uuid, start_date:, end_date:)
      flash[:success] = UserMailer::ASYNC_JOB_MESSAGE
      redirect_to responses_admin_form_path(@form)
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
      @events = @form.events
    end

    def add_tag
      ensure_form_manager(form: @form)
      @form.tag_list.add(form_params[:tag_list].split(','))
      @form.save
    end

    def remove_tag
      ensure_form_manager(form: @form)
      @form.tag_list.remove(form_params[:tag_list].split(','))
      @form.save
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
        :logo_kind,
        :modal_button_text,
        :success_text_heading,
        :success_text,
        :instructions,
        :whitelist_url,
        :whitelist_url_1,
        :whitelist_url_2,
        :whitelist_url_3,
        :whitelist_url_4,
        :whitelist_url_5,
        :whitelist_url_6,
        :whitelist_url_7,
        :whitelist_url_8,
        :whitelist_url_9,
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
        :tag_list,
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
      )
    end

    def form_search_params
      params.permit(
        :aasm_state,
      )
    end

    def form_admin_options_params
      params.require(:form).permit(
        :audience,
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
      Event.log_event(Event.names[:form_published], 'Form', @form.uuid, "Form #{@form.name} published at #{DateTime.now}", current_user.id) if (params['form']['aasm_state'] == 'published') && !@form.published?
      Event.log_event(Event.names[:form_archived], 'Form', @form.uuid, "Form #{@form.name} archived at #{DateTime.now}", current_user.id) if (params['form']['aasm_state'] == 'archived') && !@form.archived?
    end

    def invite_params
      params.require(:user).permit(:refer_user)
    end
  end
end
