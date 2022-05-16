# frozen_string_literal: true

module Admin
  class DigitalServiceAccountsController < AdminController
    before_action :set_digital_service_account, only: %i[show edit update destroy]

    # GET /digital_service_accounts
    def index
      @digital_service_accounts = DigitalServiceAccount.all
    end

    # GET /digital_service_accounts/1
    def show; end

    # GET /digital_service_accounts/new
    def new
      @digital_service_account = DigitalServiceAccount.new
    end

    # GET /digital_service_accounts/1/edit
    def edit; end

    # POST /digital_service_accounts
    def create
      @digital_service_account = DigitalServiceAccount.new(digital_service_account_params)
      @digital_service_account.user = current_user

      if @digital_service_account.save
        Event.log_event(Event.names[:digital_service_account_created], 'DigitalServiceAccount',
                        @digital_service_account.id, "created by #{current_user.email} on #{Date.today}", current_user.id)
        redirect_to admin_digital_service_account_path(@digital_service_account),
                    notice: 'Digital service account was successfully created.'
      else
        render :new
      end
    end

    # PATCH/PUT /digital_service_accounts/1
    def update
      if @digital_service_account.update(digital_service_account_params)
        Event.log_event(Event.names[:digital_service_account_created], 'DigitalServiceAccount',
                        @digital_service_account.id, "updated by #{current_user.email} on #{Date.today}", current_user.id)
        redirect_to admin_digital_service_account_path(@digital_service_account),
                    notice: 'Digital service account was successfully updated.'
      else
        render :edit
      end
    end

    # DELETE /digital_service_accounts/1
    def destroy
      @digital_service_account.destroy
      redirect_to admin_digital_service_accounts_url, notice: 'Digital service account was successfully destroyed.'
    end

    private

    # Use callbacks to share common setup or constraints between actions.
    def set_digital_service_account
      @digital_service_account = DigitalServiceAccount.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
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
        :tags
      )
    end
  end
end
