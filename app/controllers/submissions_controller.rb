class SubmissionsController < ApplicationController
  protect_from_forgery only: []
  before_action :set_touchpoint, only: [:new, :create]

  layout 'public', :only => :new

  def new
    unless @touchpoint.deployable_touchpoint?
      redirect_to root_path, alert: "Touchpoint does not have a Service specified"
    end
    @submission = Submission.new
  end

  def create
    # TODO: Restrict access with a whitelist
    #   based on the Submission's Touchpoint's Service's
    #   Organization's domain - eg: gsa.gov
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'POST, PUT'
    headers['Access-Control-Request-Method'] = '*'
    headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'

    @submission = Submission.new(submission_params)
    @submission.touchpoint_id = @touchpoint.id
    @submission.user_agent = request.user_agent
    @submission.referer = submission_params[:referer]
    @submission.page = submission_params[:page]

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
          :referer,
          :page
        )
      elsif @touchpoint.form.kind == "open-ended"
        params.require(:submission).permit(
          :answer_01,
          :referer,
          :page
        )
      elsif @touchpoint.form.kind == "open-ended-with-contact-info"
        params.require(:submission).permit(
          :answer_01,
          :answer_02,
          :answer_03,
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
          :referer,
          :page
        )
      else
        raise InvalidArgument("#{@touchpoint.name} has a Form with an unsupported Kind")
      end
    end
end
