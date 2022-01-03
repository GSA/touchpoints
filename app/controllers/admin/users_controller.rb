class Admin::UsersController < AdminController
  before_action :ensure_admin, except: [:deactivate]
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  def index
    if current_user.admin?
      @users = User.all.includes(:organization).order("inactive DESC", :organization_id, :email)
    else
      organization = current_user.organization
      @users = organization.users.includes(:organization).order(:organization_id, :email)
    end
  end

  def inactive
    @users = User.all.includes(:organization).where("last_sign_in_at < ? OR last_sign_in_at ISNULL", Time.now - 90.days).order(:organization_id, :email)
    render :index
  end

  def active
    respond_to do |format|
      format.csv { send_data User.active.to_csv, filename: "users-#{Date.today}.csv" }
    end
  end

  def show
    @forms = @user.forms
    @websites = Website.where(site_owner_email: @user.email)
    @collections = @user.collections.order(:year, :quarter)
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
    respond_to do |format|
      if @user.update(user_params)
        Event.log_event(Event.names[:user_update], "User", @user.id, "User #{@user.email} was updated by #{current_user.email} on #{Date.today}")
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
    Event.log_event(Event.names[:user_deleted], "User", @user.id, "User #{@user.email} was deleted by #{current_user.email} on #{Date.today}")
    respond_to do |format|
      format.html { redirect_to admin_users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def deactivate
    uuid = get_uuid_from_request
    render json: { "errors": "Request must come from valid login.gov source", "status": 403} and return if !uuid
    user = User.where(uid: uuid).first
    # Do we care if the user account deleted from login.gov was not found in touchpoints?
    user.deactivate if user
    Event.log_event(Event.names[:user_deactivated], "User", user.id, "User #{user.email} was deactivated on #{Date.today}")
    render json: { "msg": "User successfully deactivated." }
  end

  private
    def get_uuid_from_request
      return nil if !request.headers["HTTP_AUTHORIZATION"].present?
      begin
        decoded = JWT.decode http_token, login_gov_public_key, true, { algorithm: "RS256" }
        payload = decoded.first
        uuid = payload["events"]["https://schemas.openid.net/secevent/risc/event-type/account-purged"]["subject"]["sub"]
      rescue
        nil
      end
    end

    def login_gov_public_key
      return OpenSSL::PKey::RSA.new(ENV["LOGIN_GOV_PUBLIC_KEY"]) if ENV["LOGIN_GOV_PUBLIC_KEY"].present?
      jwks_raw = Net::HTTP.get URI(ENV["LOGIN_GOV_OPENID_CERT_URL"])
      jwks_key = JSON.parse(jwks_raw)["keys"].first
      jwks_key["alg": "RS256"]
      jwk = JSON::JWK.new(jwks_key)
      public_key = jwk.to_key
    end

    def http_token
      if request.headers['HTTP_AUTHORIZATION'].present?
        request.headers['HTTP_AUTHORIZATION'].split(' ').last
      end
    end

    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(
        :admin,
        :organization_id,
        :organizational_website_manager,
        :performance_manager,
        :registry_manager,
        :email,
        :inactive,
      )
    end
end
