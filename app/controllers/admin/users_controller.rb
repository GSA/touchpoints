class Admin::UsersController < AdminController
  before_action :ensure_organization_manager, except: [:deactivate]
  before_action :set_user, only: [:show, :edit, :update, :destroy, :deactivate]

  def index
    if current_user.admin?
      @users = User.all.includes(:organization)
    else
      organization = current_user.organization
      @users = organization.users.includes(:organization)
    end
  end

  def show
    @touchpoints = @user.touchpoints
  end

  def new
    @user = User.new
  end

  def edit
  end

  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to admin_user_path(@user), notice: 'User was successfully created.' }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    org_mgr = @user.organization_manager?
    respond_to do |format|
      if @user.update(user_params)
        send_notifications(@user, org_mgr)
        format.html { redirect_to admin_user_path(@user), notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    ensure_admin
    redirect_to(edit_admin_user_path(@user), alert: "Can't delete yourself") and return if @user == current_user

    @user.destroy
    respond_to do |format|
      format.html { redirect_to admin_users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def deactivate
    render json: { "errors": "Request must come from valid login.gov source", "status": 403} and return if !request_source_authorized?
    @user.deactivate
    render json: { "msg": "User #{@user.email} successfully deactivated." }
  end

  private
    # TODO Ensure request is coming from login.gov
    # Implementation details TBD, for now look for presence of secret key in header
    def request_source_authorized?
      (request.headers["HTTP_LOGIN_GOV_PRIVATE_KEY"].present? and request.headers["HTTP_LOGIN_GOV_PRIVATE_KEY"] == ENV["LOGIN_GOV_PRIVATE_KEY"]) ? true : false
    end

    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      if admin_permissions?
        params.require(:user).permit(
          :admin,
          :organization_id,
          :organization_manager,
          :email,
          :inactive
        )
      elsif organization_manager_permissions?
        params.require(:user).permit(
          :organization_id,
          :organization_manager,
          :email
        )
      end
    end

    def send_notifications(user, was_org_manager)
        if user.organization_manager? != was_org_manager
          change = user.organization_manager? ? 'added' : 'removed'
          Event.log_event(Event.names[:organization_manager_changed],  "User", user.id, "Organization manager #{change}", current_user.id)
          UserMailer.org_manager_change_notification(user, change).deliver_later
        end
    end
end
