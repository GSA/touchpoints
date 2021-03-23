class Admin::SubmissionsController < AdminController
  protect_from_forgery only: []
  before_action :set_form, only: [:index, :flag, :unflag, :destroy]
  before_action :set_submission, only: [:flag, :unflag, :destroy]

  def index
    @submissions = @form.submissions.includes(:organization).order("created_at desc").page params[:page]
  end

  def flag
    Event.log_event(Event.names[:response_flagged], "Submission", @submission.id, "Submission #{@submission.id} flagged at #{DateTime.now}", current_user.id)
    @submission.update_attribute(:flagged, true)
  end

  def unflag
    Event.log_event(Event.names[:response_unflagged], "Submission", @submission.id, "Submission #{@submission.id} unflagged at #{DateTime.now}", current_user.id)
    @submission.update_attribute(:flagged, false)
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
end
