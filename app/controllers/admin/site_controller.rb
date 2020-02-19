class Admin::SiteController < AdminController
  def index
  end

  def events
  end

  def events_export
    ExportEventsJob.perform_later(params[:uuid])
    render json: { result: :ok }
  end
end
