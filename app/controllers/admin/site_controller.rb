class Admin::SiteController < AdminController
  def index
    @forms = Form.non_templates
    @response_groups = Submission.group("date(created_at)").size.sort.last(45)

    @days_since = params[:recent] && params[:recent].to_i <= 30 ? params[:recent].to_i : 3
    todays_submissions = Submission.where("created_at > ?", Time.now - @days_since.days)
    form_ids = todays_submissions.collect(&:form_id).uniq
    @recent_forms = Form.find(form_ids)
  end

  def events
    @events = Event.limit(500).order("created_at DESC").page params[:page]
  end

  def a11
  end

  def events_export
    ExportEventsJob.perform_later(params[:uuid])
    render json: { result: :ok }
  end

  def management
    ensure_admin
  end
end
