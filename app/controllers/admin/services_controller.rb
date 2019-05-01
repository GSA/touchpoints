class Admin::ServicesController < AdminController
  before_action :set_user, only: [:add_user, :remove_user]
  before_action :set_service, only: [:show, :edit, :update, :add_user, :remove_user, :destroy]

  def index
    if current_user.admin?
      @services = Service.all
    else
      @services = current_user.services
    end
  end

  def show
    excluded_members = @service.users + [current_user]
    @available_members = @service.organization.users - excluded_members
  end

  # Associate a user with a Service
  def add_user
    @user_service = UserService.new({
      user_id: @user.id,
      service_id: @service.id
    })

    if @user_service.save
      flash[:notice] = "User successfully added"

      render json: {
          email: @user.email,
          service: @service.id
        }
    else
      render json: @user_service.errors, status: :unprocessable_entity
    end
  end

  # Disassociate a user with a Service
  def remove_user
    @user_service = @service.user_services.find_by_user_id(params[:user_id])

    if @user_service.destroy
      flash[:notice] = "User successfully removed"

      render json: {
          email: @user.email,
          service: @service.id
        }
    else
      render json: @user_service.errors, status: :unprocessable_entity
    end
  end

  def new
    @service = Service.new
  end

  def edit
  end

  def create
    @service = Service.new(service_params)

    respond_to do |format|
      if @service.save
        UserService.create!({
          service: @service,
          user: current_user
        })
        @service.create_container!

        format.html { redirect_to admin_service_path(@service), notice: 'Service was successfully created.' }
        format.json { render :show, status: :created, location: @service }
      else
        format.html { render :new }
        format.json { render json: @service.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @service.update(service_params)
        format.html { redirect_to admin_service_path(@service), notice: 'Service was successfully updated.' }
        format.json { render :show, status: :ok, location: @service }
      else
        format.html { render :edit }
        format.json { render json: @service.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @service.destroy
    respond_to do |format|
      format.html { redirect_to admin_services_url, notice: 'Service was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    def set_service
      @service = Service.find(params[:id])
    end

    def set_user
      @user = User.find(params[:user_id])
    end

    def service_params
      params.require(:service).permit(
        :name,
        :description,
        :notes,
        :organization_id,
        :service_manager
      )
    end
end
