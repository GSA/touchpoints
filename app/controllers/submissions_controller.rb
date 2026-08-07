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

    @submission = Submission.new(submission_params)
    @submission.form = @form
    @submission.user_agent = request.user_agent
    @submission.referer = submission_params[:referer]
    @submission.page = submission_params[:page]
    @submission.ip_address = request.remote_ip if @form.organization.enable_ip_address?

    spam_result = SpamChecker.new.call(@submission, spam_context)
    if spam_result.verdict == :reject
      if Rails.configuration.x.silently_reject_spam
        skip_save = true
        @submission.uuid = SecureRandom.uuid
      else
        # Loud rejection is intended for dev/test/CI only (see config.x.silently_reject_spam),
        # so the response is deliberately explicit to aid debugging and test assertions.
        respond_to do |format|
          format.html { head :unprocessable_content }
          format.json do
            render json: {
              status: :unprocessable_content,
              messages: { submission: ['Submission rejected as spam'] },
            }, status: :unprocessable_content
          end
        end
        return
      end
    elsif spam_result.verdict == :surface
      # Likely automated but potentially a false positive the user can correct
      # (e.g. a missing/expired Turnstile token). Return a recoverable error so
      # the client can prompt them to try again rather than silently dropping it.
      respond_to do |format|
        format.html { head :unprocessable_content }
        format.json do
          render json: {
            status: :unprocessable_content,
            messages: { submission: [t('errors.request.try_again')] },
          }, status: :unprocessable_content
        end
      end
      return
    elsif spam_result.verdict == :flag
      @submission.spam = true
      @submission.spam_determination =
        {
          'source' => 'automated',
          'reasons' => spam_result.flagged,
          'context' => spam_result.flagged_context,
        }
    end

    @submission.spam_prevention_mechanism = spam_result.applicable.join(', ')

    respond_to do |format|
      if skip_save || @submission.save
        format.html do
          redirect_to submit_touchpoint_path(@submission.form),
                      notice: 'Thank You. Response was submitted successfully.'
        end
        format.json do
          form_success_text = if @submission.form.append_id_to_success_text?
                                (@submission.form.success_text || '') + "<br><br> Your Response ID is: <strong>#{@submission.uuid[-12..-1]}</strong>"
                              else
                                @submission.form.success_text
                              end

          render json: {
            submission: {
              id: @submission.uuid,
              answer_01: @submission.answer_01,
              answer_02: @submission.answer_02,
              answer_03: @submission.answer_03,
              answer_04: @submission.answer_04,
              answer_05: @submission.answer_05,
              answer_06: @submission.answer_06,
              answer_07: @submission.answer_07,
              answer_08: @submission.answer_08,
              answer_09: @submission.answer_09,
              answer_10: @submission.answer_10,
              answer_11: @submission.answer_11,
              answer_12: @submission.answer_12,
              answer_13: @submission.answer_13,
              answer_14: @submission.answer_14,
              answer_15: @submission.answer_15,
              answer_16: @submission.answer_16,
              answer_17: @submission.answer_17,
              answer_18: @submission.answer_18,
              answer_19: @submission.answer_19,
              answer_20: @submission.answer_20,
              answer_21: @submission.answer_21,
              answer_22: @submission.answer_22,
              answer_23: @submission.answer_23,
              answer_24: @submission.answer_24,
              answer_25: @submission.answer_25,
              answer_26: @submission.answer_26,
              answer_27: @submission.answer_27,
              answer_28: @submission.answer_28,
              answer_29: @submission.answer_29,
              answer_30: @submission.answer_30,
              form: {
                id: @submission.form.uuid,
                name: @submission.form.name,
                organization_name: @submission.organization_name,
                success_text_heading: @submission.form.success_text_heading,
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
            status: :unprocessable_content,
            messages: @submission.errors,
          }, status: :unprocessable_content
        end
      end
    end
  end

  private

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
    params.require(:submission).permit(permitted_fields)
  end

  def spam_context
    {
      referer: request.referer,
      remote_ip: request.remote_ip,
      cf_turnstile_response: params[:cf_turnstile_response],
      root_url: root_url,
    }
  end

  def form_requires_verification
    @form.verify_csrf?
  end
end
