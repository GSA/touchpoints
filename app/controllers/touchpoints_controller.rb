class TouchpointsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:js]
  before_action :set_touchpoint, only: [:show, :js]

  layout 'public', only: :index

  def index
    @touchpoints = Touchpoint.active.all
  end

  def js
    render(partial: "components/widget/fba.js", locals: { touchpoint: @touchpoint })
  end

  def show
    redirect_to submit_touchpoint_path(@touchpoint.short_uuid) # instead of rendering #show
  end


  private
    def set_touchpoint
      @touchpoint = (params[:id].to_s.length == 8) ? Touchpoint.find_by_short_uuid(params[:id]) : Touchpoint.find(params[:id])
    end
end
