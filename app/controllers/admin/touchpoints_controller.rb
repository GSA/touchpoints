class Admin::TouchpointsController < AdminController
  skip_before_action :verify_authenticity_token, only: [:js]
  before_action :set_touchpoint, only: [:show, :edit, :update, :export_submissions, :destroy, :example, :gtm_example, :js, :trigger]

  def index
    if current_user && current_user.admin?
      @touchpoints = Touchpoint.all
    else
      @touchpoints = current_user.touchpoints
    end
  end

  def export_submissions
    sheet = @touchpoint.export_to_google_sheet!
    redirect_to sheet.spreadsheet_url
  end

  def show
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
        format.html { redirect_to admin_touchpoint_path(@touchpoint), notice: 'Touchpoint was successfully created.' }
        format.json { render :show, status: :created, location: @touchpoint }
      else
        format.html { render :new }
        format.json { render json: @touchpoint.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
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
    @touchpoint.destroy
    respond_to do |format|
      format.html { redirect_to touchpoints_url, notice: 'Touchpoint was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def example
    render layout: false
  end

  def gtm_example
    render layout: false
  end

  def js
    render(partial: "components/widget/fba.js", locals: { touchpoint: @touchpoint })
  end

  private
    def set_touchpoint
      if current_user && current_user.admin?
        @touchpoint = Touchpoint.find(params[:id])
      else
        @touchpoint = current_user.touchpoints.find(params[:id])
      end
    end

    def touchpoint_params
      params.require(:touchpoint).permit(
        :name,
        :service_id,
        :organization_id,
        :expiration_date,
        :form_template_id,
        :purpose,
        :meaningful_response_size,
        :behavior_change,
        :notification_emails,
        :omb_approval_number,
        :user_agent,
        :referer,
        :page
      )
    end
end
