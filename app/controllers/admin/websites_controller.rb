class Admin::WebsitesController < AdminController
  before_action :ensure_admin
  before_action :set_admin_website, only: [:show, :edit, :update, :destroy]

  # GET /admin/websites
  def index
    @websites = Website.all
  end

  def gsa
    @websites = Website.all
  end

  def show
  end


  # GET /admin/websites/new
  def new
    @website = Website.new
  end

  # GET /admin/websites/1/edit
  def edit
  end

  # POST /admin/websites
  def create
    @website = Website.new(admin_website_params)

    if @website.save
      redirect_to admin_website_url(@website), notice: 'Website was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /admin/websites/1
  def update
    if @website.update(admin_website_params)
      redirect_to admin_website_url(@website), notice: 'Website was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /admin/websites/1
  def destroy
    @website.destroy
    redirect_to admin_websites_url, notice: 'Website was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_admin_website
      @website = Website.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def admin_website_params
      params.require(:website).permit(:domain, :parent_domain, :office, :office_id, :sub_office, :suboffice_id, :contact_email, :site_owner_email, :production_status, :type_of_site, :digital_brand_category, :redirects_to, :status_code, :cms_platform, :required_by_law_or_policy, :has_dap, :dap_gtm_code, :cost_estimator_url, :modernization_plan_url, :annual_baseline_cost, :modernization_cost, :analytics_url, :current_uswds_score, :uses_feedback, :feedback_tool, :sitemap_url, :mobile_friendly, :has_search, :uses_tracking_cookies, :has_authenticated_experience, :authentication_tool, :notes)
    end
end
