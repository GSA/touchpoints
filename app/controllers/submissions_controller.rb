class SubmissionsController < ApplicationController
  protect_from_forgery only: []
  before_action :set_touchpoint, only: [:new, :create]

  layout 'public', only: :new

  def new
    unless @touchpoint.deployable_touchpoint?
      redirect_to root_path, alert: "Touchpoint does not have a Service specified"
    end
    @submission = Submission.new
    # set location code in the form based on `?location_code=`
    @submission.location_code = params[:location_code]
  end

  def create
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'POST'
    headers['Access-Control-Request-Method'] = '*'
    headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'

    # Prevent the Submission if this is a published Touchpoint and if:
    if @touchpoint.service &&
      request.referer &&
      # is not from the Form's whitelist URL
      (@touchpoint.form.whitelist_url.present? ? !request.referer.start_with?(@touchpoint.form.whitelist_url) : true) &&
      # is not from the Form's test whitelist URL
      (@touchpoint.form.whitelist_test_url.present? ? !request.referer.start_with?(@touchpoint.form.whitelist_test_url) : true) &&
      # is not from the public Touchpoints page
      !request.referer.start_with?(submit_touchpoint_url(@touchpoint)) &&
      # is not from the example Touchpoints page
      !request.referer.start_with?(example_admin_touchpoint_url(@touchpoint)) &&
      # is not from the Organization URL
      !request.referer.start_with?(@touchpoint.service.organization.url)

      render json: {
        status: :unprocessable_entity,
        messages: {"submission": ["request made from non-authorized host"] }
        }, status: :unprocessable_entity and return
    end

    @submission = Submission.new(submission_params)
    @submission.touchpoint_id = @touchpoint.id
    @submission.user_agent = request.user_agent
    @submission.referer = submission_params[:referer]
    @submission.page = submission_params[:page]
    @submission.ip_address = request.remote_ip

    create_in_local_database(@submission)
  end


  private

    def create_in_local_database(submission)
      respond_to do |format|
        if submission.save
          format.html {
            redirect_to submit_touchpoint_path(submission.touchpoint), notice: 'Thank You. Submission was successfully created.' }
          format.json {
            render json: {
              submission: {
                id: submission.id,
                first_name: submission.answer_01,
                last_name: submission.answer_02,
                email: submission.answer_03,
                phone_number: submission.answer_04,
                touchpoint: {
                  id: submission.touchpoint.id,
                  name: submission.touchpoint.name,
                  organization_name: submission.organization_name
                }
              }
            },
            status: :created
          }
        else
          format.html {
          }
          format.json {
            render json: {
              status: :unprocessable_entity,
              messages: submission.errors
            }, status: :unprocessable_entity
          }
        end
      end
    end

    def set_touchpoint
      if params[:touchpoint] # coming from /touchpoints/:id/submit
        @touchpoint = Touchpoint.find(params[:id])
      else
        @touchpoint = Touchpoint.find(params[:touchpoint_id])
      end
      raise InvalidArgument("Touchpoint does not exist") unless @touchpoint
    end

    def submission_params
      # Accept submitted form parameters based on the Touchpoint's Form's properties
      # TODO: handle as a case statement
      # TODO: split Form-specific parameter whitelisting into Form's definitions
      # TODO: Consider Making `recruiter`, the Form.kind, a Class/Module, for better strictnesss/verbosity.
      if @touchpoint.form.kind == "recruiter"
        params.require(:submission).permit(
          :answer_01,
          :answer_02,
          :answer_03,
          :answer_04,
          :location_code,
          :referer,
          :page
        )
      elsif @touchpoint.form.kind == "open-ended"
        params.require(:submission).permit(
          :answer_01,
          :location_code,
          :referer,
          :page
        )
      elsif @touchpoint.form.kind == "open-ended-with-contact-info"
        params.require(:submission).permit(
          :answer_01,
          :answer_02,
          :answer_03,
          :location_code,
          :referer,
          :page
        )
      elsif @touchpoint.form.kind == "a11"
        params.require(:submission).permit(
          :answer_01,
          :answer_02,
          :answer_03,
          :answer_04,
          :answer_05,
          :answer_06,
          :answer_07,
          :answer_08,
          :answer_09,
          :answer_10,
          :answer_11,
          :answer_12,
          :location_code,
          :referer,
          :page
        )
      elsif @touchpoint.form.kind == "custom"
        permitted_fields = @touchpoint.form.questions.collect(&:answer_field)
        permitted_fields << [:location_code, :referer, :page]
        params.require(:submission).permit(permitted_fields)
      else
        raise InvalidArgument("#{@touchpoint.name} has a Form with an unsupported Kind")
      end
    end
end
