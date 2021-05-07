class Admin::SubmissionsController < AdminController
  before_action :set_form
  before_action :set_submission

  def show
  end

  def update
    respond_to do |format|
      if @submission.update(status_params)
        Event.log_event(Event.names[:response_status_changed], "Submission", @submission.id, "Submission #{@submission.id} changed status to #{status_params[:aasm_state]} at #{DateTime.now}", current_user.id)

        format.html {
          redirect_to admin_form_submission_path(@form, @submission), notice: 'Response was successfully updated.'
        }
        format.json { render :show, status: :ok, location: @form }
      else
        format.html {
          redirect_to admin_form_submission_path(@form, @submission), alert: 'Response could not be updated.'
        }
        format.json { render json: @form.errors, status: :unprocessable_entity }
      end
    end
  end

  def flag
    Event.log_event(Event.names[:response_flagged], "Submission", @submission.id, "Submission #{@submission.id} flagged at #{DateTime.now}", current_user.id)
    @submission.update(flagged: true)
  end

  def unflag
    Event.log_event(Event.names[:response_unflagged], "Submission", @submission.id, "Submission #{@submission.id} unflagged at #{DateTime.now}", current_user.id)
    @submission.update(flagged: false)
  end

  def archive
    Event.log_event(Event.names[:response_archived], "Submission", @submission.id, "Submission #{@submission.id} archived at #{DateTime.now}", current_user.id)
    @submission.update(archived: true)
  end

  def unarchive
    Event.log_event(Event.names[:response_unarchived], "Submission", @submission.id, "Submission #{@submission.id} unarchived at #{DateTime.now}", current_user.id)
    @submission.update(archived: false)
  end

  def destroy
    ensure_form_manager(form: @form)

    Event.log_event(Event.names[:response_deleted], "Submission", @submission.id, "Submission #{@submission.id} deleted at #{DateTime.now}", current_user.id)

    @submission.destroy
    respond_to do |format|
      format.js { render :destroy }
    end
  end


  private

    def set_form
      if admin_permissions?
        @form = Form.find_by_short_uuid(params[:form_id])
      else
        @form = current_user.forms.find_by_short_uuid(params[:form_id])
      end
      raise ActiveRecord::RecordNotFound, "no form with ID of #{params[:form_id]}" unless @form
    end

    def set_submission
      @submission = @form.submissions.find(params[:id])
    end

    def status_params
    	params.require(:submission).permit(:aasm_state)
    end
end
