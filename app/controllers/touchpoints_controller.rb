# frozen_string_literal: true

class TouchpointsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :set_touchpoint

  def show
    respond_to do |format|
      format.html do
        redirect_to submit_touchpoint_path(@form, response_params) # instead of rendering #show
      end
      format.js do
        js
      end
      format.css do
        render(partial: 'components/widget/widget', formats: :css, locals: { form: @form })
      end
    end
  end

  def js
    @form.increment!(:survey_form_activations)
    if @form.legacy_form_embed || (params[:legacy] && params[:legacy] == '1')
      render(partial: 'components/widget/fba', formats: :js, locals: { form: @form })
    else
      render(partial: 'components/widget/fba2', formats: :js, locals: { form: @form })
    end
  end

  private

  def set_touchpoint
    @form = if params[:id].to_s.length == 8
              Form.find_by_legacy_touchpoints_uuid(params[:id]) || Form.find_by_short_uuid(params[:id])
            else
              Form.find_by_legacy_touchpoints_id(params[:id])
            end

    raise ActiveRecord::RecordNotFound, "no form with ID of #{params[:id]}" if @form.blank?
  end

  def response_params
    params.permit(:location_code, :locale)
  end
end
