class Admin::OrganizationsController < AdminController
  before_action :ensure_admin
  before_action :set_organization, only: [
    :show,
    :performance,
    :edit,
    :update,
    :destroy,
    :add_tag,
    :remove_tag,
  ]

  def index
    @organizations = Organization.all.order(:name)
    @tags = Organization.tag_counts_by_name
  end

  def show
  end

  def new
    @organization = Organization.new
  end

  def edit
  end

  def performance
  end

  def create
    @organization = Organization.new(organization_params)

    respond_to do |format|
      if @organization.save
        format.html { redirect_to admin_organization_path(@organization), notice: 'Organization was successfully created.' }
        format.json { render :show, status: :created, location: @organization }
      else
        format.html { render :new }
        format.json { render json: @organization.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @organization.update(organization_params)
        format.html { redirect_to admin_organization_path(@organization), notice: 'Organization was successfully updated.' }
        format.json { render :show, status: :ok, location: @organization }
      else
        format.html { render :edit }
        format.json { render json: @organization.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @organization.destroy
    respond_to do |format|
      format.html { redirect_to admin_organizations_url, notice: 'Organization was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def search
    search_text = params[:search]
    tag_name = params[:tag]
    if search_text.present?
      search_text = "%" + search_text + "%"
      @organizations = Organization.where(" domain ilike ? or name ilike ? or abbreviation ilike ? or url ilike ?  ", search_text, search_text, search_text, search_text)
    elsif tag_name.present?
      @organizations = Organization.tagged_with(tag_name)
    else
      @organizations = Organization.all
    end
  end

  def add_tag
    @organization.tag_list.add(organization_params[:tag_list].split(","))
    @organization.save
  end

  def remove_tag
    @organization.tag_list.remove(organization_params[:tag_list].split(","))
    @organization.save
  end

  private
    def set_organization
      @organization = Organization.find_by_id(params[:id]) || Organization.find_by_abbreviation(params[:id].upcase)
    end

    def organization_params
      params.require(:organization).permit(
        :name,
        :domain,
        :logo,
        :url,
        :abbreviation,
        :notes,
        :external_id,
        :enable_ip_address,
        :digital_analytics_path,
        :mission_statement,
        :tag_list
      )
    end
end
