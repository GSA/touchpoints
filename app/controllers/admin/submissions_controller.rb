class Admin::SubmissionsController < AdminController
  protect_from_forgery only: []
  before_action :set_form, only: [:index, :flag, :unflag, :destroy]
  before_action :set_submission, only: [:flag, :unflag, :destroy]

  def index
    @submissions = @form.submissions.includes(:organization)
  end

  def flag
    @submission.update_attribute(:flagged, true)
    respond_to do |format|
      format.html { redirect_to admin_form_url(@form), notice: "Response #{@submission.id} was successfully flagged." }
      format.json { head :no_content }
    end
  end

  def unflag
    @submission.update_attribute(:flagged, false)
    respond_to do |format|
      format.html { redirect_to admin_form_url(@form), notice: "Response #{@submission.id} was successfully unflagged." }
      format.json { head :no_content }
    end
  end

  def destroy
    ensure_form_manager(form: @form)

    Event.log_event(Event.names[:response_deleted], "Submission", @submission.id, "Submission #{@submission.id} deleted at #{DateTime.now}", current_user.id)

    @submission.destroy
    respond_to do |format|
      format.html { redirect_to admin_form_url(@form), notice: "Response #{@submission.id} was successfully destroyed." }
      format.json { head :no_content }
    end
  end


  private

    def set_form
      @form = current_user.forms.find_by_short_uuid(params[:form_id]) || current_user.forms.find(params[:form_id])
      raise ActiveRecord::RecordNotFound, "no form with ID of #{params[:form_id]}" unless @form
    end

    def set_submission
      @submission = @form.submissions.find(params[:id])
    end
end
