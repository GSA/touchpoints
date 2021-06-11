class SubmissionsController < ApplicationController
  protect_from_forgery only: []
  before_action :set_form, only: %i[new create]
  before_action :ensure_user, only: [:feed]

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
          referer: request.referer
        },
        expected: true
      }
      NewRelic::Agent.notice_error(ArgumentError, error_options)

      render json: {
        status: :unprocessable_entity,
        messages: { "submission": ['request made from non-authorized host'] }
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

  def feed
    @days_limit = (params[:days_limit].present? ? params[:days_limit].to_i : 1)
    @feed = get_feed_data(@days_limit)
  end

  def export_feed
    @days_limit = (params[:days_limit].present? ? params[:days_limit].to_i : 1)
    @feed = get_feed_data(@days_limit)
    respond_to do |format|
      format.csv {
        send_data to_csv(@feed), :type => 'text/csv; charset=utf-8; header=present', :disposition => "attachment; filename=touchpoints-feed-#{Date.today}.csv"
      }
      format.json {
        render json: @feed.to_json
      }
    end
  end

  def to_csv(hash_rows)
    CSV.generate(headers: true) do |csv|
      csv << hash_rows.first.keys
      hash_rows.each do | hash_row |
        csv << hash_row.values
      end
    end
  end

  def get_feed_data(days_limit)
    all_question_responses = []

    Form.all.each do |form|
      submissions = form.submissions
      submissions = submissions.where("created_at >= ?",days_limit.days.ago) if days_limit > 0
      submissions.each do |submission|
        form.questions.each do |question|
          @hash = {
            organization_id: form.organization_id,
            organization_name: form.organization.name,
            form_id: form.id,
            form_name: form.name,
            submission_id: submission.id,
            question_id: question.id,
            user_id: submission.user_id,
            question_text: question.text.to_s,
            response_text: submission.send(question.answer_field.to_sym).to_s,
            question_with_response_text: question.text.to_s + ': ' + submission.send(question.answer_field.to_sym).to_s,
            created_at: submission.created_at
          }
          all_question_responses << @hash
        end
      end
    end

    all_question_responses
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
              id: submission.id,
              first_name: submission.answer_01,
              last_name: submission.answer_02,
              email: submission.answer_03,
              phone_number: submission.answer_04,
              form: {
                id: submission.form.uuid,
                name: submission.form.name,
                organization_name: submission.organization_name
              }
            }
          },
                 status: :created
        end
      else
        format.html do
        end
        format.json do
          render json: {
            status: :unprocessable_entity,
            messages: submission.errors
          }, status: :unprocessable_entity
        end
      end
    end
  end

  def set_form
    if params[:form]
      @short_uuid = params[:id].to_s
      if LEGACY_TOUCHPOINTS_URL_MAP.has_key?(params[:id].to_s)
        @short_uuid = LEGACY_TOUCHPOINTS_URL_MAP[params[:id].to_s]
      end
    elsif params[:form_id]
      @short_uuid = params[:form_id].to_s
      if LEGACY_TOUCHPOINTS_URL_MAP.has_key?(params[:form_id].to_s)
        @short_uuid = LEGACY_TOUCHPOINTS_URL_MAP[params[:form_id].to_s]
      end
    elsif params[:touchpoint_id]
      @short_uuid = params[:touchpoint_id].to_s
      if LEGACY_TOUCHPOINTS_URL_MAP.has_key?(params[:touchpoint_id].to_s)
        @short_uuid = LEGACY_TOUCHPOINTS_URL_MAP[params[:touchpoint_id].to_s]
      end
    end
    @form = FormCache.fetch(@short_uuid)
    raise ActiveRecord::RecordNotFound, "no form with ID of #{@short_uuid}" unless @form.present?
  end

  def submission_params
    permitted_fields = @form.questions.collect(&:answer_field)
    permitted_fields << %i[language location_code referer page]
    params.require(:submission).permit(permitted_fields)
  end
end
