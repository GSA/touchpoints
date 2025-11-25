# frozen_string_literal: true

module Admin
  class SubmissionsController < AdminController
    before_action :ensure_admin, only: %i[
      feed
      export_feed
    ]
    before_action :set_form, except: %i[
      feed
      export_feed
    ]
    before_action :set_submission, except: %i[
      feed
      export_feed
      search
      a11_chart
      a11_analysis
      responses_per_day
      responses_by_status
      performance_gov
      submissions_table
      bulk_update
    ]

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
          format.json { render json: @form.errors, status: :unprocessable_content }
        end
      end
    end

    def search
      @all_submissions = @form.submissions.ordered
      @all_submissions = @all_submissions.where(":tags = ANY (tags)", tags: params[:tag]) if params[:tag]
      if params[:archived]
        @submissions = @all_submissions.page params[:page]
      else
        @submissions = @all_submissions.active.page params[:page]
      end
    end

    def flag
      Event.log_event(Event.names[:response_flagged], 'Submission', @submission.id, "Submission #{@submission.id} flagged at #{DateTime.now}", current_user.id)
      @submission.update_attribute(:flagged, true)
    end

    def unflag
      Event.log_event(Event.names[:response_unflagged], 'Submission', @submission.id, "Submission #{@submission.id} unflagged at #{DateTime.now}", current_user.id)
      @submission.update_attribute(:flagged, false)
    end

    def add_tag
      tag = tag_params[:tag]

      if !tag.strip.empty? && !@submission.tags.include?(tag)
        unique_tags = (@submission.tags.clone << tag.strip.downcase).uniq
        @submission.update_attribute(:tags, unique_tags)
        @submission.form.update_submission_tags!(@submission.tags)
      end
    end

    def remove_tag
      tag = tag_params[:tag]

      if @submission.tags.include?(tag)
        @submission.tags -= [tag]
        @submission.save!
      end
    end

    def a11_analysis
      @report = FormCache.fetch_a11_analysis(@form.short_uuid)
    end

    def a11_chart
      @report = FormCache.fetch_a11_analysis(@form.short_uuid)
    end

    def responses_per_day
      @dates = (45.days.ago.to_date..Date.today).map { |date| date }

      @response_groups = Submission
        .where(form_id: @form.id)
        .where("created_at >= ?", 45.days.ago)
        .group(Arel.sql("DATE(created_at)"))
        .count.sort

      # Add in 0 count days to fetched analytics
      @dates.each do |date|
        @response_groups << [date, 0] unless @response_groups.detect { |row| row[0].strftime('%m %d %Y') == date.strftime('%m %d %Y') }
      end
      @response_groups = @response_groups.sort
    end

    def responses_by_status
      form_submissions = @form.submissions

      responses_by_aasm = form_submissions.group(:aasm_state).count
      flagged_count = form_submissions.flagged.count
      archived_count = form_submissions.archived.count
      marked_count = form_submissions.marked_as_spam.count
      deleted_count = form_submissions.deleted.count
      @responses_by_status = { **responses_by_aasm,
        'flagged' => flagged_count,
        'marked' => marked_count,
        'archived' => archived_count,
        'deleted' => deleted_count,
        'total' => responses_by_aasm.values.sum }
      @responses_by_status.default = 0
    end

    def performance_gov
      @report = FormCache.fetch_performance_gov_analysis(@form.short_uuid)
    end

    def submissions_table
      @show_flagged = search_params[:flagged] == "1"
      @show_marked_as_spam = search_params[:spam] == "1"
      @show_archived = search_params[:archived] == "1"
      @show_deleted = search_params[:deleted] == "1"

      @submissions = @form.submissions

      # Apply filters based on query params
      if search_params[:tag]
        @submissions = @submissions.where(":tags = ANY (tags)", tags: search_params[:tag])
      end

      if @show_flagged
        @submissions = @submissions.flagged.non_deleted
      elsif @show_marked_as_spam
        @submissions = @submissions.marked_as_spam.non_deleted
      elsif @show_archived
        @submissions = @submissions.archived.non_deleted
      elsif @show_deleted
        @submissions = @submissions.deleted
      else
        @submissions = @submissions.active
      end

      @submissions = @submissions.ordered.page(params[:page])
    end

    def archive
      ensure_form_manager(form: @form)

      Event.log_event(Event.names[:response_archived], 'Submission', @submission.id, "Submission #{@submission.id} archived at #{DateTime.now}", current_user.id)
      @submission.update_attribute(:archived, true)
    end

    def unarchive
      ensure_form_manager(form: @form)

      Event.log_event(Event.names[:response_unarchived], 'Submission', @submission.id, "Submission #{@submission.id} unarchived at #{DateTime.now}", current_user.id)
      @submission.update_attribute(:archived, false)
    end

    def mark
      ensure_form_manager(form: @form)

      Event.log_event(Event.names[:response_marked_as_spam], 'Submission', @submission.id, "Submission #{@submission.id} marked as spam at #{DateTime.now}", current_user.id)
      @submission.update_attribute(:spam, true)
    end

    def unmark
      ensure_form_manager(form: @form)

      Event.log_event(Event.names[:response_unmarked_as_spam], 'Submission', @submission.id, "Submission #{@submission.id} unmarked as spam at #{DateTime.now}", current_user.id)
      @submission.update_attribute(:spam, false)
    end

    def delete
      ensure_form_manager(form: @form)

      Event.log_event(Event.names[:response_deleted], 'Submission', @submission.id, "Submission #{@submission.id} undeleted at #{DateTime.now}", current_user.id)
      @submission.update(deleted: true, deleted_at: Time.now)
    end

    def destroy
      ensure_form_manager(form: @form)

      Event.log_event(Event.names[:response_deleted], 'Submission', @submission.id, "Submission #{@submission.id} undeleted at #{DateTime.now}", current_user.id)
      @submission.update(deleted: true, deleted_at: Time.now)

      respond_to do |format|
        format.js { render :destroy }
      end
    end

    def undelete
      ensure_form_manager(form: @form)

      Event.log_event(Event.names[:response_undeleted], 'Submission', @submission.id, "Submission #{@submission.id} deleted at #{DateTime.now}", current_user.id)
      @submission.update(deleted: false, deleted_at: nil)
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
        submissions = form.submissions.ordered
        submissions = submissions.where('created_at >= ?', days_limit.days.ago) if days_limit.positive?
        submissions.each do |submission|
          form.ordered_questions.each do |question|
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

    def bulk_update
      submission_ids = params[:submission_ids] # Array of selected submission_ids
      bulk_action = params[:bulk_action] # The selected action ('flag', 'archive', or 'spam')

      if submission_ids.present?
        submissions = @form.submissions
          .where(id: submission_ids)
          .ordered

        case bulk_action
        when 'archive'
          submissions.each do |submission|
            Event.log_event(Event.names[:response_archived], 'Submission', submission.id, "Submission #{submission.id} archived at #{DateTime.now}", current_user.id)
            submission.update_attribute(:archived, true)
          end
          flash[:notice] = "#{view_context.pluralize(submissions.count, 'Submission')} archived."
        when 'flag'
          submissions.each do |submission|
            Event.log_event(Event.names[:response_flagged], 'Submission', submission.id, "Submission #{submission.id} flagged at #{DateTime.now}", current_user.id)
            submission.update_attribute(:flagged, true)
          end
          flash[:notice] = "#{view_context.pluralize(submissions.count, 'Submission')} flagged."
        when 'spam'
          submissions.each do |submission|
            Event.log_event(Event.names[:response_marked_as_spam], 'Submission', submission.id, "Submission #{submission.id} marked as spam at #{DateTime.now}", current_user.id)
            submission.update_attribute(:spam, true)
          end
          flash[:notice] = "#{view_context.pluralize(submissions.count, 'Submission')} marked as spam."
        when 'delete'
          submissions.each do |submission|
            Event.log_event(Event.names[:response_deleted], 'Submission', submission.id, "Submission #{submission.id} deleted at #{DateTime.now}", current_user.id)
            submission.update(deleted: true, deleted_at: Time.now)
          end
          flash[:notice] = "#{view_context.pluralize(submissions.count, 'Submission')} deleted."
        else
          flash[:alert] = "Invalid action selected."
        end
      else
        flash[:alert] = "No Submissions selected."
      end

      redirect_to responses_admin_form_path(@form)
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
      permitted_params = params.permit(:aasm_state)

      if permitted_params[:aasm_state].present?
        unless Submission.aasm.states.map(&:name).include?(permitted_params[:aasm_state].to_sym)
          raise ActionController::ParameterMissing, "Invalid state: #{permitted_params[:aasm_state]}"
        end
      else
        raise ActionController::ParameterMissing, "aasm_state parameter is missing"
      end

      permitted_params
    end

    def tag_params
      params.require(:submission).permit(:tag)
    end

    def search_params
      params.permit(
        :form_id,
        :flagged,
        :spam,
        :archived,
        :deleted,
        :tags,
      )
    end
  end
end
