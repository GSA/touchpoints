# frozen_string_literal: true

module Admin
  class SubmissionsController < AdminController
    before_action :ensure_admin, only: %i[feed export_feed]
    before_action :set_form, except: %i[feed export_feed]
    before_action :set_submission, except: %i[feed export_feed search a11_chart a11_analysis responses_per_day responses_by_status performance_gov submissions_table]

    def show; end

    def update
      respond_to do |format|
        if @submission.update(status_params)
          Event.log_event(Event.names[:response_status_changed], 'Submission', @submission.id, "Submission #{@submission.id} changed status to #{status_params[:aasm_state]} at #{DateTime.now}", current_user.id)

          format.html do
            redirect_to admin_form_submission_path(@form, @submission), notice: 'Response was successfully updated.'
          end
          format.json { render :show, status: :ok, location: @form }
        else
          format.html do
            redirect_to admin_form_submission_path(@form, @submission), alert: 'Response could not be updated.'
          end
          format.json { render json: @form.errors, status: :unprocessable_entity }
        end
      end
    end

    def search
      @all_submissions = @form.submissions
      @all_submissions = @all_submissions.tagged_with(params[:tag]) if params[:tag]
      if params[:archived]
        @submissions = @all_submissions.order('submissions.created_at DESC').page params[:page]
      else
        @submissions = @all_submissions.non_archived.order('submissions.created_at DESC').page params[:page]
      end
    end

    def flag
      Event.log_event(Event.names[:response_flagged], 'Submission', @submission.id, "Submission #{@submission.id} flagged at #{DateTime.now}", current_user.id)
      @submission.update(flagged: true)
    end

    def unflag
      Event.log_event(Event.names[:response_unflagged], 'Submission', @submission.id, "Submission #{@submission.id} unflagged at #{DateTime.now}", current_user.id)
      @submission.update(flagged: false)
    end

    def add_tag
      @submission.tag_list.add(admin_submission_params[:tag_list].split(','))
      @submission.save!
    end

    def remove_tag
      @submission.tag_list.remove(admin_submission_params[:tag_list].split(','))
      @submission.save!
    end

    def a11_analysis
      @report = FormCache.fetch_a11_analysis(@form.short_uuid)
    end

    def a11_chart
      @report = FormCache.fetch_a11_analysis(@form.short_uuid)
    end

    def responses_per_day
      @dates = (45.days.ago.to_date..Date.today).map { |date| date }
      @response_groups = @form.submissions.group('date(created_at)').size.sort.last(45)
      # Add in 0 count days to fetched analytics
      @dates.each do |date|
        @response_groups << [date, 0] unless @response_groups.detect { |row| row[0].strftime('%m %d %Y') == date.strftime('%m %d %Y') }
      end
      @response_groups = @response_groups.sort
    end

    def responses_by_status; end

    def performance_gov
      @report = FormCache.fetch_performance_gov_analysis(@form.short_uuid)
    end

    def submissions_table
      @show_archived = true if params[:archived]
      @all_submissions = @form.submissions
      @all_submissions = @all_submissions.tagged_with(params[:tag]) if params[:tag]
      if params[:archived]
        @submissions = @all_submissions.order('submissions.created_at DESC').page params[:page]
      else
        @submissions = @all_submissions.non_archived.order('submissions.created_at DESC').page params[:page]
      end
    end

    def archive
      ensure_form_manager(form: @form)

      Event.log_event(Event.names[:response_archived], 'Submission', @submission.id, "Submission #{@submission.id} archived at #{DateTime.now}", current_user.id)
      @submission.update(archived: true)
    end

    def unarchive
      ensure_form_manager(form: @form)

      Event.log_event(Event.names[:response_unarchived], 'Submission', @submission.id, "Submission #{@submission.id} unarchived at #{DateTime.now}", current_user.id)
      @submission.update(archived: false)
    end

    def destroy
      ensure_form_manager(form: @form)

      Event.log_event(Event.names[:response_deleted], 'Submission', @submission.id, "Submission #{@submission.id} deleted at #{DateTime.now}", current_user.id)

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
        format.csv do
          send_data to_csv(@feed), type: 'text/csv; charset=utf-8; header=present', disposition: "attachment; filename=touchpoints-feed-#{Date.today}.csv"
        end
        format.json do
          render json: @feed.to_json
        end
      end
    end

    def to_csv(hash_rows)
      CSV.generate(headers: true) do |csv|
        csv << hash_rows.first.keys
        hash_rows.each do |hash_row|
          csv << hash_row.values
        end
      end
    end

    def get_feed_data(days_limit)
      all_question_responses = []

      Form.all.each do |form|
        submissions = form.submissions
        submissions = submissions.where('created_at >= ?', days_limit.days.ago) if days_limit.positive?
        submissions.each do |submission|
          form.questions.each do |question|
            question_text = question.text.to_s
            answer_text = Logstop.scrub(submission.send(question.answer_field.to_sym).to_s)
            @hash = {
              organization_id: form.organization_id,
              organization_name: form.organization.name,
              form_id: form.id,
              form_name: form.name,
              submission_id: submission.id,
              question_id: question.id,
              user_id: submission.user_id,
              question_text:,
              response_text: answer_text,
              question_with_response_text: "#{question_text}: #{answer_text}",
              created_at: submission.created_at,
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

    def admin_submission_params
      params.require(:submission).permit(:tag_list)
    end
  end
end
