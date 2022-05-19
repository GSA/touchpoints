class Admin::DigitalServiceAccountsController < AdminController
  before_action :set_digital_service_account, only: [:show, :edit, :update, :destroy]

  def index
    @digital_service_accounts = DigitalServiceAccount.order(:organization_id, :name).page(params[:page])
  end

  def review
    @digital_service_accounts = DigitalServiceAccount.order(:organization_id, :name).page(params[:page])
  end

  def show
  end

  def new
    @digital_service_account = DigitalServiceAccount.new
  end

  def edit
  end

  def create
    @digital_service_account = DigitalServiceAccount.new(digital_service_account_params)
    @digital_service_account.user = current_user

    if @digital_service_account.save
      redirect_to admin_digital_service_account_path(@digital_service_account), notice: 'Digital service account was successfully created.'
    else
      render :new
    end
  end

  def update
    if @digital_service_account.update(digital_service_account_params)
      redirect_to admin_digital_service_account_path(@digital_service_account), notice: 'Digital service account was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @digital_service_account.destroy
    redirect_to admin_digital_service_accounts_url, notice: 'Digital service account was successfully destroyed.'
  end

  private

    def set_digital_service_account
      @digital_service_account = DigitalServiceAccount.find(params[:id])
    end


    def digital_service_account_params
      params.require(:digital_service_account).permit(
        :name,
        :organization_id,
        :user_id,
        :service,
        :service_url,
        :account,
        :language,
        :status,
        :short_description,
        :long_description,
        :tags)
    end
end
