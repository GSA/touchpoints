class Admin::SubmissionsController < AdminController
  protect_from_forgery only: []
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
    @submission.user_agent = request.user_agent


    create_in_local_database(@submission)
  end

  def update
    respond_to do |format|
      if @submission.update(submission_params)
        format.html { redirect_to admin_submission_path(@submission), notice: 'Submission was successfully updated.' }
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
      format.html { redirect_to admin_touchpoint_submissions_url(@touchpoint.id), notice: 'Submission was successfully destroyed.' }
      format.json { head :no_content }
    end
  end


  private

    def create_in_local_database(submission)
      respond_to do |format|
        if submission.save
          format.html {
            redirect_to admin_touchpoint_submission_path(submission.touchpoint, submission), notice: 'Submission was successfully created.' }
          format.json {
            render json: {
              submission: {
                id: submission.id,
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
            render json: submission.errors, status: :unprocessable_entity
          }
        end
      end
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
          :answer_01,
          :answer_02,
          :answer_03,
          :answer_04
        )
      elsif @touchpoint.form.kind == "open-ended"
        params.require(:submission).permit(
          :answer_01,
        )
      elsif @touchpoint.form.kind == "open-ended-with-contact-info"
        params.require(:submission).permit(
          :answer_01,
          :answer_02,
          :answer_03
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
