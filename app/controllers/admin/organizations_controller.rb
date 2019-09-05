class Admin::OrganizationsController < AdminController
  before_action :ensure_admin
  before_action :set_organization, only: [:show, :edit, :update, :destroy]

  def index
    @organizations = Organization.all.order(:name)
  end

  def show
  end

  def new
    @organization = Organization.new
  end

  def edit
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

  private
    def set_organization
      @organization = Organization.find(params[:id])
    end

    def organization_params
      params.require(:organization).permit(
        :name,
        :domain,
        :logo,
        :url,
        :abbreviation,
        :notes,
        :external_id
      )
    end
end
