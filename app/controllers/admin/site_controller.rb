class Admin::SiteController < AdminController
  def index
    @forms = Form.non_templates
  end

  def events
  end

  def events_export
    ExportEventsJob.perform_later(params[:uuid])
    render json: { result: :ok }
  end

  def management
    ensure_admin
  end
end
