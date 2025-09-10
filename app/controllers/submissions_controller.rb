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
      ActiveSupport::Notifications.instrument('spam_subverted') do |payload|
        payload[:request] = request
      end

      head :ok and return
    end

    # Prevent the Submission if this is a published Form and if the form:
    if @form &&
       request.referer &&
       # is not from the Form's whitelist URLs
       (@form.whitelist_url.present? ? !request.referer.start_with?(@form.whitelist_url) : true) &&
       (@form.whitelist_url_1.present? ? !request.referer.start_with?(@form.whitelist_url_1) : true) &&
       (@form.whitelist_url_2.present? ? !request.referer.start_with?(@form.whitelist_url_2) : true) &&
       (@form.whitelist_url_3.present? ? !request.referer.start_with?(@form.whitelist_url_3) : true) &&
       (@form.whitelist_url_4.present? ? !request.referer.start_with?(@form.whitelist_url_4) : true) &&
       (@form.whitelist_url_5.present? ? !request.referer.start_with?(@form.whitelist_url_5) : true) &&
       (@form.whitelist_url_6.present? ? !request.referer.start_with?(@form.whitelist_url_6) : true) &&
       (@form.whitelist_url_7.present? ? !request.referer.start_with?(@form.whitelist_url_7) : true) &&
       (@form.whitelist_url_8.present? ? !request.referer.start_with?(@form.whitelist_url_8) : true) &&
       (@form.whitelist_url_9.present? ? !request.referer.start_with?(@form.whitelist_url_9) : true) &&
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
    if submission.form.enable_turnstile?
      if verify_turnstile(params['cf-turnstile-response'])
        submission.spam_prevention_mechanism = :turnstile
      else
        submission.errors.add(:base, 'Turnstile verification failed')
      end
    end

    respond_to do |format|
      if submission.errors.empty? && submission.save
        format.html do
          redirect_to submit_touchpoint_path(submission.form),
                      notice: 'Thank You. Response was submitted successfully.'
        end
        format.json do
          form_success_text = if submission.form.append_id_to_success_text?
                                submission.form.success_text + "<br><br> Your Response ID is: <strong>#{submission.uuid[-12..-1]}</strong>"
                              else
                                submission.form.success_text
                              end

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
                     answer_21: submission.answer_21,
                     answer_22: submission.answer_22,
                     answer_23: submission.answer_23,
                     answer_24: submission.answer_24,
                     answer_25: submission.answer_25,
                     answer_26: submission.answer_26,
                     answer_27: submission.answer_27,
                     answer_28: submission.answer_28,
                     answer_29: submission.answer_29,
                     answer_30: submission.answer_30,
                     form: {
                       id: submission.form.uuid,
                       name: submission.form.name,
                       organization_name: submission.organization_name,
                       success_text_heading: submission.form.success_text_heading,
                       success_text: form_success_text,
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
    permitted_fields << %i[language location_code referer hostname page query_string fba_directive]
    permitted_fields << %i[cf-turnstile-response]
    params.require(:submission).permit(permitted_fields)
  end

  def form_requires_verification
    @form.verify_csrf?
  end

  private

  def verify_turnstile(response_token)
    secret_key = ENV.fetch('TURNSTILE_SECRET_KEY', nil)
    uri = URI('https://challenges.cloudflare.com/turnstile/v0/siteverify')

    response = Net::HTTP.post_form(uri, {
                                     'secret' => secret_key,
                                     'response' => response_token,
                                     'remoteip' => request.remote_ip,
                                   })

    json = JSON.parse(response.body)
    json['success'] == true
  end
end
