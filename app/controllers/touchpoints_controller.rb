class TouchpointsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:js]
  before_action :set_touchpoint

  def js
    render(partial: "components/widget/fba.js", locals: { form: @form })
  end

  def show
    redirect_to submit_touchpoint_path(@form.short_uuid) # instead of rendering #show
  end


  private
    def set_touchpoint
      @form = (params[:id].to_s.length == 8) ?
        (Form.find_by_legacy_touchpoints_uuid(params[:id]) || Form.find_by_short_uuid(params[:id])) :
        (Form.find_by_legacy_touchpoints_id(params[:id]) || Form.find_by_id(params[:id]))

      raise ActiveRecord::RecordNotFound, "no form with ID of #{params[:id]}" unless @form.present?
    end
end
