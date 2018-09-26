class SubmissionsController < ApplicationController
  before_action :ensure_admin, only: [:index, :show, :update, :destroy]
  before_action :set_submission, only: [:show, :edit, :update, :destroy]

  def index
    @submissions = Submission.all.includes(:organization)
  end

  def show
  end

  def edit
  end

  def create
    raise "Invalid Touchpoint" unless touchpoint = Touchpoint.find(params["touchpoint_id"])

    @submission = Submission.new(submission_params)
    @submission.touchpoint_id = touchpoint.id
    @submission.organization_id = touchpoint.organization_id

    if @submission.save
      render json: {
        submission: {
          id: @submission.id,
          first_name: @submission.first_name,
          last_name: @submission.last_name,
          email: @submission.email,
          phone_number: @submission.phone_number
        }
      },
      status: :created, location: @submission
    else
      render json: @submission.errors, status: :unprocessable_entity
    end
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
    def set_submission
      @submission = Submission.find(params[:id])
    end

    def submission_params
      params.require(:submission).permit(:first_name, :last_name, :phone_number, :email, :body, :user_id, :organization_id, :touchpoint_id)
    end
end
