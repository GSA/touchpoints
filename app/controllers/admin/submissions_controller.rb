class Admin::SubmissionsController < AdminController
  before_action :ensure_admin, only: [:feed, :export_feed]
  before_action :set_form, except: [:feed, :export_feed]
  before_action :set_submission, except: [:feed, :export_feed]

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
    ensure_form_manager(form: @form)

    Event.log_event(Event.names[:response_archived], "Submission", @submission.id, "Submission #{@submission.id} archived at #{DateTime.now}", current_user.id)
    @submission.update(archived: true)
  end

  def unarchive
    ensure_form_manager(form: @form)

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

  def feed
    @days_limit = (params[:days_limit].present? ? params[:days_limit].to_i : 1)
    @feed = get_feed_data(@days_limit)
  end

  def export_feed
    @days_limit = (params[:days_limit].present? ? params[:days_limit].to_i : 1)
    @feed = get_feed_data(@days_limit)
    respond_to do |format|
      format.csv {
        send_data to_csv(@feed), :type => 'text/csv; charset=utf-8; header=present', :disposition => "attachment; filename=touchpoints-feed-#{Date.today}.csv"
      }
      format.json {
        render json: @feed.to_json
      }
    end
  end

  def to_csv(hash_rows)
    CSV.generate(headers: true) do |csv|
      csv << hash_rows.first.keys
      hash_rows.each do | hash_row |
        csv << hash_row.values
      end
    end
  end

  def get_feed_data(days_limit)
    all_question_responses = []

    Form.all.each do |form|
      submissions = form.submissions
      submissions = submissions.where("created_at >= ?",days_limit.days.ago) if days_limit > 0
      submissions.each do |submission|
        form.questions.each do |question|
          @hash = {
            organization_id: form.organization_id,
            organization_name: form.organization.name,
            form_id: form.id,
            form_name: form.name,
            submission_id: submission.id,
            question_id: question.id,
            user_id: submission.user_id,
            question_text: question.text.to_s,
            response_text: submission.send(question.answer_field.to_sym).to_s,
            question_with_response_text: question.text.to_s + ': ' + submission.send(question.answer_field.to_sym).to_s,
            created_at: submission.created_at
          }
          all_question_responses << @hash
        end
      end
    end

    all_question_responses
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
