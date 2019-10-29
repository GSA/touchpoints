require 'csv'

class Admin::TouchpointsController < AdminController
  respond_to :html, :js, :docx

  skip_before_action :verify_authenticity_token, only: [:js]
  before_action :set_touchpoint, only: [
    :show, :edit, :update, :destroy,
    :export_pra_document, :export_submissions,
    :example, :js, :trigger
  ]

  def export_pra_document
    respond_to do |format|
      format.html {
        redirect_to admin_touchpoint_path(@touchpoint)
      }
      format.docx {
        docx = PraForm.part_a(touchpoint: @touchpoint)
        send_data docx.render.string, filename: "pra-part-a-#{timestamp_string}.docx"
      }
    end
  end

  def index
    if admin_permissions?
      @touchpoints = Touchpoint.all
    else
      @touchpoints = current_user.touchpoints
    end
    @pra_contacts = PraContact.where("email LIKE ?", "%#{current_user.organization.domain}")
  end

  def export_submissions
    respond_to do |format|
      #  Export to CSV
      format.csv {
        send_data @touchpoint.to_csv, filename: "touchpoint-submissions-#{timestamp_string}.csv"
      }
    end
  end

  def show
    @pra_contacts = PraContact.where("email LIKE ?", "%#{current_user.organization.domain}")
  end

  def new
    @touchpoint = Touchpoint.new
  end

  def edit
  end

  def create
    @touchpoint = Touchpoint.new(touchpoint_params)

    respond_to do |format|
      if @touchpoint.save

        # Create a Form based on the Form Template
        if !form_template_params.empty?
          form_template = FormTemplate.find(form_template_params[:form_template_id])

          if form_template
            new_form = Form.create({
              name: form_template.name,
              title: form_template.title,
              instructions: form_template.instructions,
              disclaimer_text: form_template.disclaimer_text,
              kind: form_template.kind,
              character_limit: 6000
            })
            @touchpoint.update_attribute(:form, new_form)
          end
        end

        format.html { redirect_to admin_touchpoint_path(@touchpoint), notice: 'Touchpoint was successfully created.' }
        format.json { render :show, status: :created, location: @touchpoint }
      else
        format.html { render :new }
        format.json { render json: @touchpoint.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    if !form_template_params.empty? && !@touchpoint.form
      form_template = FormTemplate.find(form_template_params[:form_template_id])

      if form_template
        @touchpoint.form = Form.create({
          name: form_template.name,
          title: form_template.title,
          instructions: form_template.instructions,
          disclaimer_text: form_template.disclaimer_text,
          kind: form_template.kind,
          character_limit: 6000
        })
      end
    end

    respond_to do |format|
      if @touchpoint.update(touchpoint_params)
        format.html { redirect_to admin_touchpoint_path(@touchpoint), notice: 'Touchpoint was successfully updated.' }
        format.json { render :show, status: :ok, location: @touchpoint }
      else
        format.html { render :edit }
        format.json { render json: @touchpoint.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    redirect_to(admin_touchpoints_path, alert: "Cannot delete Touchpoint because it has one or more Submissions") and return if @touchpoint.submissions.present?

    @touchpoint.destroy
    respond_to do |format|
      format.html { redirect_to admin_touchpoints_url, notice: 'Touchpoint was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def example
    redirect_to admin_touchpoints_path, notice: "Touchpoint does not have a delivery_method of 'modal' or 'inline' or 'custom-button-modal'" and return unless @touchpoint.delivery_method == "modal" || @touchpoint.delivery_method == "inline" || @touchpoint.delivery_method == "custom-button-modal"

    render layout: false
  end

  def js
    render(partial: "components/widget/fba.js", locals: { touchpoint: @touchpoint })
  end

  private
    def set_touchpoint
      if admin_permissions?
        @touchpoint = Touchpoint.find(params[:id])
      else
        @touchpoint = current_user.touchpoints.find(params[:id])
      end
    end

    def touchpoint_params
      params.require(:touchpoint).permit(
        :name,
        :organization_id,
        :service_id,
        :form_id,
        :expiration_date,
        :purpose,
        :meaningful_response_size,
        :behavior_change,
        :notification_emails,
        :omb_approval_number,
        :delivery_method,
        :element_selector
      )
    end

    def form_template_params
      params.require(:touchpoint).permit(
        :form_template_id
      )
    end
end
