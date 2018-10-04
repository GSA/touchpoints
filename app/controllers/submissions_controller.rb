class SubmissionsController < ApplicationController
  before_action :ensure_admin, only: [:index, :new, :show, :update, :destroy]
  before_action :set_touchpoint, only: [:index, :new, :show, :edit, :update, :destroy]
  before_action :set_submission, only: [:show, :edit, :update, :destroy]


  def index
    # @submissions = Submission.all.includes(:organization)
    @submissions = @touchpoint.submissions.includes(:organization)
  end

  def show
  end

  def new
    @submission = Submission.new
  end

  def edit
  end

  def create
    raise "Invalid Touchpoint" unless touchpoint = Touchpoint.find(params["touchpoint_id"])

    @submission = Submission.new(submission_params)
    @submission.touchpoint_id = touchpoint.id
    @submission.organization_id = touchpoint.organization_id

    ENV.fetch("GOOGLE_SHEETS_ENABLED") == "true" ?
      create_in_google_sheets(@submission) :
      create_in_local_database(@submission)
  end

  def create_in_local_database(submission)
    respond_to do |format|
      if submission.save
        format.html { redirect_to touchpoint_submission_path(submission.touchpoint, submission), notice: 'Submission was successfully created.' }
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
            status: :created, location: submission
          }
        }
      else
        render json: submission.errors, status: :unprocessable_entity
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

    render json: { status: :something_happened }
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
      format.html { redirect_to submissions_url, notice: 'Submission was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    def set_touchpoint
      @touchpoint = Touchpoint.find(params[:touchpoint_id])
      raise InvalidArgument("Touchpoint does not exist") unless @touchpoint
    end

    def set_submission
      @submission = Submission.find(params[:id])
    end

    def submission_params
      params.require(:submission).permit(:first_name, :last_name, :phone_number, :email, :body, :user_id, :organization_id, :touchpoint_id)
    end
end
