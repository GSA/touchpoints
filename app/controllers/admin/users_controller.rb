# frozen_string_literal: true

module Admin
  class UsersController < AdminController
    before_action :ensure_admin, except: [:deactivate]
    before_action :set_user, only: %i[show edit update destroy]

    def index
      if current_user.admin? && params[:scope] == :all
        @users = User.all.includes(:organization).order('inactive DESC', :organization_id, :email)
      elsif current_user.admin? && params[:scope] == :inactive
        @users = User.all.includes(:organization).where('current_sign_in_at < ? OR current_sign_in_at ISNULL', 90.days.ago).order(:organization_id, :email)
      elsif current_user.admin?
        @users = User.active.includes(:organization).order('inactive DESC', :organization_id, :email)
      else
        organization = current_user.organization
        @users = organization.users.active.includes(:organization).order(:organization_id, :email)
      end

      respond_to do |format|
        format.csv { send_data @users.to_csv, filename: "users-#{Date.today}.csv" }
        format.html { render :index }
      end
    end

    def admins
      @users = User.all
      @admins = @users.select(&:admin?)
      @service_managers = @users.select(&:service_manager?)
      @performance_managers = @users.select(&:performance_manager?)
      @registry_managers = @users.select(&:registry_manager?)
      @website_managers = @users.select(&:organizational_website_manager?)
    end

    def inactivate!
      User.deactivate_inactive_accounts!
      redirect_to admin_users_path, notice: 'Users inactivated successfully.'
    end

    def show
      @forms = @user.forms
      @websites = Website.where(site_owner_email: @user.email)
      @collections = @user.collections.order(:year, :quarter)
      @user_events = Event.limit(100).where(user_id: @user.id).order('created_at DESC')
      @service_providers = ServiceProvider.with_role(:service_provider_manager, @user)
      @services = Service.with_role(:service_manager, @user)
      @digital_products = DigitalProduct.with_role(:contact, @user)
      @digital_service_accounts = DigitalServiceAccount.with_role(:contact, @user)
    end

    def new
      @user = User.new
    end

    def edit; end

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
          Event.log_event(Event.names[:user_update], 'User', @user.id, "User #{@user.email} was updated by #{current_user.email} on #{Date.today}")
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
      Event.log_event(Event.names[:user_deleted], 'User', @user.id, "User #{@user.email} was deleted by #{current_user.email} on #{Date.today}")
      respond_to do |format|
        format.html { redirect_to admin_users_url, notice: 'User was successfully destroyed.' }
        format.json { head :no_content }
      end
    end

    def deactivate
      uuid = get_uuid_from_request
      render json: { errors: 'Request must come from valid login.gov source', status: 403 } and return unless uuid

      user = User.where(uid: uuid).first
      # Do we care if the user account deleted from login.gov was not found in touchpoints?
      user&.deactivate!
      Event.log_event(Event.names[:user_deactivated], 'User', user.id, "User #{user.email} was deactivated on #{Date.today}")
      render json: { msg: 'User successfully deactivated.' }
    end

    private

    def get_uuid_from_request
      return nil if request.headers['HTTP_AUTHORIZATION'].blank?

      begin
        decoded = JWT.decode http_token, login_gov_public_key, true, { algorithm: 'RS256' }
        payload = decoded.first
        uuid = payload['events']['https://schemas.openid.net/secevent/risc/event-type/account-purged']['subject']['sub']
      rescue StandardError
        nil
      end
    end

    def login_gov_public_key
      return OpenSSL::PKey::RSA.new(ENV['LOGIN_GOV_PUBLIC_KEY']) if ENV['LOGIN_GOV_PUBLIC_KEY'].present?

      jwks_raw = Net::HTTP.get URI(ENV.fetch('LOGIN_GOV_OPENID_CERT_URL', nil))
      jwks_key = JSON.parse(jwks_raw)['keys'].first
      jwks_key[alg: 'RS256']
      jwk = JSON::JWK.new(jwks_key)
      public_key = jwk.to_key
    end

    def http_token
      request.headers['HTTP_AUTHORIZATION'].split.last if request.headers['HTTP_AUTHORIZATION'].present?
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
        :service_manager,
        :registry_manager,
        :email,
        :first_name,
        :last_name,
        :position_title,
        :profile_photo,
        :inactive,
      )
    end
  end
end
