class SubmissionsController < ApplicationController
  protect_from_forgery only: []
  before_action :set_touchpoint, only: [:index, :new, :create, :show, :edit, :update, :destroy]
  before_action :set_submission, only: [:show, :edit, :update, :destroy]

  def index
    @submissions = @touchpoint.submissions.includes(:organization)
  end

  layout 'public', :only => :new

  def new
    unless @touchpoint.deployable_touchpoint?
      redirect_to root_path, alert: "Touchpoint does not have a Service specified"
    end
    @submission = Submission.new
  end

  def show
  end

  def edit
  end

  def create
    # TODO: Restrict access
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'POST, PUT, OPTIONS'
    headers['Access-Control-Request-Method'] = '*'
    headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'

    @submission = Submission.new(submission_params)
    @submission.touchpoint_id = @touchpoint.id

    create_in_local_database(@submission)
  end

  def update
    respond_to do |format|
      if @submission.update(submission_params)
        format.html { redirect_to @submission, notice: 'Submission was successfully updated.' }
        format.json { render :show, status: :ok, location: @submission }
      else
        format.html { render :edit }
        format.json { render json: @submission.errors, status: :unprocessable_entity }
      end
    end
  end

  private

    def create_in_local_database(submission)
      respond_to do |format|
        if submission.save
          format.html {
            redirect_to touchpoint_submission_path(submission.touchpoint, submission), notice: 'Submission was successfully created.' }
          format.json {
            render json: {
              submission: {
                id: submission.id,
                first_name: submission.first_name,
                last_name: submission.last_name,
                email: submission.email,
                phone_number: submission.phone_number,
                touchpoint: {
                  id: submission.touchpoint.id,
                  name: submission.touchpoint.name,
                  organization_name: submission.touchpoint.service.organization.name
                }
              }
            },
            status: :created
          }
        else
          format.html {
          }
          format.json {
            render json: submission.errors, status: :unprocessable_entity
          }
        end
      end
    end

    def create_in_google_sheets(submission)
      google_service = GoogleSheetsApi.new
      spreadsheet_id = submission.touchpoint.google_sheet_id
      range = 'A1'
      request_body = Google::Apis::SheetsV4::ValueRange.new

      form = submission.touchpoint.form
      raise InvalidArgument("Could not find Submission's Touchpoint's Form") unless form

      if form.kind == "recruiter"
        values = [
          params[:submission][:first_name],
          params[:submission][:last_name],
          params[:submission][:email]
        ]
      end
      if form.kind == "open-ended"
        values = [
          params[:submission][:body],
        ]
      end
      if form.kind == "open-ended-with-contact-info"
        values = [
          params[:submission][:body],
          params[:submission][:first_name],
          params[:submission][:email],
          params[:submission][:referer],
          request.user_agent,
          params[:submission][:page],
          Time.now,
        ]
      end
      if form.kind == "a11"
        values = [
          params[:submission][:overall_satisfaction],
          params[:submission][:service_confidence],
          params[:submission][:service_effectiveness],
          params[:submission][:process_ease],
          params[:submission][:process_efficiency],
          params[:submission][:process_transparency],
          params[:submission][:people_employees]
        ]
      end
      response = google_service.add_row(spreadsheet_id: spreadsheet_id, values: values)

      render json: { message: "Submission created in Google Sheet" }, status: :created
    end

    def set_touchpoint
      if params[:touchpoint] # coming from /touchpoints/:id/submit
        @touchpoint = Touchpoint.find(params[:id])
      else
        @touchpoint = Touchpoint.find(params[:touchpoint_id])
      end
      raise InvalidArgument("Touchpoint does not exist") unless @touchpoint
    end

    def set_submission
      @submission = Submission.find(params[:id])
    end

    def submission_params
      if @touchpoint.form.kind == "recruiter"
        params.require(:submission).permit(
          :first_name,
          :last_name,
          :phone_number,
          :email,
          :user_id
        )
      elsif @touchpoint.form.kind == "open-ended"
        params.require(:submission).permit(
          :body,
        )
      elsif @touchpoint.form.kind == "open-ended-with-contact-info"
        params.require(:submission).permit(
          :body,
          :first_name,
          :email
        )
      elsif @touchpoint.form.kind == "a11"
        params.require(:submission).permit(
          :overall_satisfaction,
          :service_confidence,
          :service_effectiveness,
          :process_ease,
          :process_efficiency,
          :process_transparency,
          :people_employees
        )
      else
        raise InvalidArgument("#{@touchpoint.name} has a Form with an unsupported Kind")
      end
    end
end
