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
    Rails.logger.info "DEBUG: TouchpointsController#js called for form #{@form.id}"
    @form.increment!(:survey_form_activations)

    # Use Rust widget renderer if available, otherwise fall back to ERB
    begin
      js_content = @form.touchpoints_js_string
      Rails.logger.info 'DEBUG: touchpoints_js_string success'
    rescue StandardError => e
      Rails.logger.error "DEBUG: touchpoints_js_string failed: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      raise e
    end

    render plain: js_content, content_type: 'application/javascript'
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
