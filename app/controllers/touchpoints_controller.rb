class TouchpointsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:js]
  before_action :set_touchpoint, only: [:show, :edit, :update, :destroy, :example, :gtm_example, :js, :trigger]

  layout 'public', only: :index

  def index
    @touchpoints = Touchpoint.active.all
  end

  def show
    redirect_to submit_touchpoint_path(@touchpoint) # instead of rendering #show
  end

  private
    def set_touchpoint
      @touchpoint = Touchpoint.find(params[:id])
    end
end
