require 'csv'

class Admin::TouchpointsController < AdminController
  respond_to :html, :js, :docx

  before_action :ensure_organization_manager, only: [:destroy]

  skip_before_action :verify_authenticity_token, only: [:js]
  before_action :set_user, only: [:add_user, :remove_user]
  before_action :set_touchpoint, only: [
    :show, :edit, :update, :destroy,
    :export_pra_document, :export_submissions,
    :export_a11_header,
    :export_a11_submissions,
    :example, :js, :trigger,
    :add_user, :remove_user
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
  end

  def export_submissions
    respond_to do |format|
      #  Export to CSV
      format.csv {
        send_data @touchpoint.to_csv, filename: "touchpoint-submissions-#{timestamp_string}.csv"
      }
    end
  end

  def export_a11_header
    current_reporting_quarter_start_date = Date.parse("2019-10-01")
    current_reporting_quarter_end_date = Date.parse("2020-01-31")

    start_date = params[:start_date] || current_reporting_quarter_start_date
    end_date = params[:end_date] || current_reporting_quarter_end_date

    respond_to do |format|
      format.csv {
        send_data @touchpoint.to_a11_header_csv(start_date: start_date, end_date: end_date), filename: "touchpoint-a11-header-#{timestamp_string}.csv"
      }
    end
  end

  def export_a11_submissions
    current_reporting_quarter_start_date = Date.parse("2019-10-01")
    current_reporting_quarter_end_date = Date.parse("2020-01-31")

    start_date = params[:start_date] || current_reporting_quarter_start_date
    end_date = params[:end_date] || current_reporting_quarter_end_date

    respond_to do |format|
      format.csv {
        send_data @touchpoint.to_a11_submissions_csv(start_date: start_date, end_date: end_date), filename: "touchpoint-a11-submissions-#{timestamp_string}.csv"
      }
    end
  end

  def show
    @available_members = (User.admins + @touchpoint.organization.users).uniq - @touchpoint.users
  end

  def new
    @touchpoint = Touchpoint.new
  end

  def edit
  end

  def create
    @touchpoint = Touchpoint.new(touchpoint_params)
    @touchpoint.organization_id = @touchpoint.organization_id || current_user.organization.id

    respond_to do |format|
      if @touchpoint.save
        UserRole.create!({
          touchpoint_id: @touchpoint.id,
          user: current_user,
          role: UserRole::Role::TouchpointManager
        })

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

  # Associate a user with a Touchpoint
  def add_user
    raise ArgumentException unless current_user.admin? || (@touchpoint.user_role?(user: current_user) == UserRole::Role::TouchpointManager)
    raise ArgumentException unless UserRole::ROLES.include?(params[:role])

    @role = UserRole.new({
      user_id: @user.id,
      touchpoint_id: @touchpoint.id,
      role: params[:role],
    })

    if @role.save
      flash[:notice] = "User Role successfully added to Touchpoint"

      render json: {
          email: @user.email,
          touchpoint: @touchpoint.id
        }
    else
      render json: @role.errors, status: :unprocessable_entity
    end
  end

  # Disassociate a user with a Touchpoint
  def remove_user
    @role = @touchpoint.user_roles.find_by_user_id(params[:user_id])

    if @role.destroy
      flash[:notice] = "User Role successfully removed from Touchpoint"

      render json: {
        email: @user.email,
        touchpoint: @touchpoint.id
      }
    else
      render json: @role.errors, status: :unprocessable_entity
    end
  end


  private
    def set_touchpoint
      if admin_permissions?
        @touchpoint = Touchpoint.find(params[:id])
      else
        @touchpoint = current_user.touchpoints.find(params[:id])
      end
    end

    def set_user
      @user = User.find(params[:user_id])
    end

    def touchpoint_params
      params.require(:touchpoint).permit(
        :name,
        :organization_id,
        :form_id,
        :expiration_date,
        :purpose,
        :meaningful_response_size,
        :behavior_change,
        :notification_emails,
        :omb_approval_number,
        :federal_register_url,
        :medium,
        :anticipated_delivery_count,
        :delivery_method,
        :element_selector,
        :hisp,
        :service_name,
        :data_submission_comment,
        :survey_instrument_reference,
        :agency_poc_email,
        :agency_poc_name,
        :department,
        :bureau,
      )
    end
end
