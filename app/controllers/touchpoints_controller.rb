# frozen_string_literal: true

class TouchpointsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :set_touchpoint

  def show
    respond_to do |format|
      format.html do
        redirect_to submit_touchpoint_path(@form) # instead of rendering #show
      end
      format.js do
        js
      end
    end
  end

  def js
    @form.increment!(:survey_form_activations)
    render(partial: 'components/widget/fba', formats: :js, locals: { form: @form })
  end

  private

  def set_touchpoint
    @form = if params[:id].to_s.length == 8
              (Form.find_by_legacy_touchpoints_uuid(params[:id]) || Form.find_by_short_uuid(params[:id]))
            else
              Form.find_by_legacy_touchpoints_id(params[:id])
            end

    raise ActiveRecord::RecordNotFound, "no form with ID of #{params[:id]}" if @form.blank?
  end
end
