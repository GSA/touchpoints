# frozen_string_literal: true

class SubmissionsController < ApplicationController
  before_action :set_form, only: %i[new create]
  append_before_action :verify_authenticity_token, if: :form_requires_verification

  layout 'public', only: :new

  def new
    if @form.archived?
      # okay
    elsif !@form.deployable_form? && !current_user
      redirect_to index_path, alert: 'Form is not currently deployed.'
    end
    @form.increment!(:survey_form_activations) unless current_user
    @submission = Submission.new
    # set location code in the form based on `?location_code=`
    @submission.location_code = params[:location_code]
  end

  def create
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'POST'
    headers['Access-Control-Request-Method'] = '*'
    headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'

    # Catch SPAMMERS
    if @form && submission_params[:fba_directive].present?
      Rails.logger.warn("SPAM subverted from #{request.referer}")
      head :ok and return
    end

    # Prevent the Submission if this is a published Form and if:
    if @form &&
       request.referer &&
       # is not from the Form's whitelist URL
       (@form.whitelist_url.present? ? !request.referer.start_with?(@form.whitelist_url) : true) &&
       # is not from the Form's test whitelist URL
       (@form.whitelist_test_url.present? ? !request.referer.start_with?(@form.whitelist_test_url) : true) &&
       # is not from the Touchpoints app
       !request.referer.start_with?(root_url) &&
       # is not from the Organization URL
       !request.referer.start_with?(@form.organization.url)

      error_options = {
        custom_params: {
          referer: request.referer,
        },
        expected: true,
      }
      NewRelic::Agent.notice_error(ArgumentError, error_options)

      render json: {
        status: :unprocessable_entity,
        messages: { submission: [t('errors.request.unauthorized_host')] },
      }, status: :unprocessable_entity and return
    end

    @submission = Submission.new(submission_params)
    @submission.form = @form
    @submission.user_agent = request.user_agent
    @submission.referer = submission_params[:referer]
    @submission.page = submission_params[:page]

    @submission.ip_address = request.remote_ip if @form.organization.enable_ip_address?
    create_in_local_database(@submission)
  end

  private

  def create_in_local_database(submission)
    respond_to do |format|
      if submission.save
        format.html do
          redirect_to submit_touchpoint_path(submission.form),
                      notice: 'Thank You. Response was submitted successfully.'
        end
        format.json do
          render json: {
                   submission: {
                     id: submission.uuid,
                     answer_01: submission.answer_01,
                     answer_02: submission.answer_02,
                     answer_03: submission.answer_03,
                     answer_04: submission.answer_04,
                     answer_05: submission.answer_05,
                     answer_06: submission.answer_06,
                     answer_07: submission.answer_07,
                     answer_08: submission.answer_08,
                     answer_09: submission.answer_09,
                     answer_10: submission.answer_10,
                     answer_11: submission.answer_11,
                     answer_12: submission.answer_12,
                     answer_13: submission.answer_13,
                     answer_14: submission.answer_14,
                     answer_15: submission.answer_15,
                     answer_16: submission.answer_16,
                     answer_17: submission.answer_17,
                     answer_18: submission.answer_18,
                     answer_19: submission.answer_19,
                     answer_20: submission.answer_20,
                     form: {
                       id: submission.form.uuid,
                       name: submission.form.name,
                       organization_name: submission.organization_name,
                     },
                   },
                 },
                 status: :created
        end
      else
        format.html do
        end
        format.json do
          render json: {
            status: :unprocessable_entity,
            messages: submission.errors,
          }, status: :unprocessable_entity
        end
      end
    end
  end

  def set_form
    if params[:form]
      @short_uuid = params[:id].to_s
      @short_uuid = LEGACY_TOUCHPOINTS_URL_MAP[params[:id].to_s] if LEGACY_TOUCHPOINTS_URL_MAP.key?(params[:id].to_s)
    elsif params[:form_id]
      @short_uuid = params[:form_id].to_s
      @short_uuid = LEGACY_TOUCHPOINTS_URL_MAP[params[:form_id].to_s] if LEGACY_TOUCHPOINTS_URL_MAP.key?(params[:form_id].to_s)
    elsif params[:touchpoint_id]
      @short_uuid = params[:touchpoint_id].to_s
      @short_uuid = LEGACY_TOUCHPOINTS_URL_MAP[params[:touchpoint_id].to_s] if LEGACY_TOUCHPOINTS_URL_MAP.key?(params[:touchpoint_id].to_s)
    end
    @form = FormCache.fetch(@short_uuid)
    raise ActiveRecord::RecordNotFound, "no form with ID of #{@short_uuid}" if @form.blank?
  end

  def submission_params
    permitted_fields = @form.questions.collect(&:answer_field)
    permitted_fields << %i[language location_code referer page fba_directive]
    params.require(:submission).permit(permitted_fields)
  end

  def form_requires_verification
    @form.verify_csrf?
  end
end
