class SubmissionsController < ApplicationController
  before_action :ensure_admin, only: [:index, :new, :show, :update, :destroy]
  before_action :set_touchpoint, only: [:index, :new, :create, :show, :edit, :update, :destroy]
  before_action :set_submission, only: [:show, :edit, :update, :destroy]


  def index
    # @submissions = Submission.all.includes(:organization)
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
                  organization_name: submission.touchpoint.organization.name
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
      values = [
        params[:submission][:first_name],
        params[:submission][:last_name],
        params[:submission][:email]
      ]
      response = google_service.add_row(spreadsheet_id: spreadsheet_id, values: values)

      render json: { status: :success, message: "Google Sheet created" }
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
          :user_id,
          :touchpoint_id
        )
      elsif @touchpoint.form.kind == "open-ended"
        params.require(:submission).permit(
          :body,
          :touchpoint_id
        )
      elsif @touchpoint.form.kind == "a11"
        params.require(:submission).permit(
          :overall_satisfaction,
          :service_confidence,
          :service_effectiveness,
          :process_ease,
          :process_efficiency,
          :process_transparency,
          :people_employees,
          :touchpoint_id
        )
      else
        raise InvalidArgument("#{@touchpoint.name} has a Form with an unsupported Kind")
      end
    end
end
