class SubmissionsController < ApplicationController
  protect_from_forgery only: []
  before_action :ensure_admin, only: [:index, :new, :show, :update, :destroy]
  before_action :set_touchpoint, only: [:index, :new, :create, :show, :edit, :update, :destroy]
  before_action :set_submission, only: [:show, :edit, :update, :destroy]

  def index
    @submissions = @touchpoint.submissions.includes(:organization)
  end

  def new
    @submission = Submission.new
  end

  def show
  end

  def edit
  end

  def create
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'POST, PUT, DELETE, GET, OPTIONS'
    headers['Access-Control-Request-Method'] = '*'
    headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'

    @submission = Submission.new(submission_params)
    @submission.touchpoint_id = @touchpoint.id

    @touchpoint.enable_google_sheets ?
      create_in_google_sheets(@submission) :
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

  def destroy
    @submission.destroy
    respond_to do |format|
      format.html { redirect_to touchpoint_submissions_url(@touchpoint.id), notice: 'Submission was successfully destroyed.' }
      format.json { head :no_content }
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
                  organization_name: submission.touchpoint.container.organization.name
                }
              },
              status: :created
            }
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
          params[:submission][:name],
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

      render json: { status: :success, message: "Submission created in Google Sheet" }
    end

    def set_touchpoint
      @touchpoint = Touchpoint.find(params[:touchpoint_id])
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
