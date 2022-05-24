class Admin::DigitalServiceAccountsController < AdminController
  before_action :set_digital_service_account, only: [
    :show, :edit, :update, :destroy,
    :add_tag, :remove_tag,
    :certify, :publish, :archive, :reset
  ]

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
    @digital_service_account.organization = current_user.organization
  end

  def edit
  end

  def create
    @digital_service_account = DigitalServiceAccount.new(digital_service_account_params)
    @digital_service_account.user = current_user

    if @digital_service_account.save
      Event.log_event(Event.names[:digital_service_account_created], "Digital Service Account", @digital_service_account.id, "Digital Service Account #{@digital_service_account.name} created at #{DateTime.now}", current_user.id)
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

  def add_tag
    @digital_service_account.tag_list.add(digital_service_account_params[:tag_list].split(','))
    @digital_service_account.save
  end

  def remove_tag
    @digital_service_account.tag_list.remove(digital_service_account_params[:tag_list].split(','))
    @digital_service_account.save
  end

  def certify
    # ensure_digital_service_account_admin(website: @website, user: current_user)
    @digital_service_account.certify!
    if @digital_service_account.save
      Event.log_event(Event.names[:digital_service_account_certified], "Digital Service Account", @digital_service_account.id, "Digital Service Account #{@digital_service_account.name} certified at #{DateTime.now}", current_user.id)
      redirect_to admin_digital_service_account_path(@digital_service_account), notice: "Digital Service Account #{@digital_service_account.name} was certified."
    else
      render :edit
    end
  end

  def publish
    # ensure_digital_service_account_admin(website: @website, user: current_user)
    @digital_service_account.publish!
    if @digital_service_account.save
      Event.log_event(Event.names[:digital_service_account_published], "Digital Service Account", @digital_service_account.id, "Digital Service Account #{@digital_service_account.name} published at #{DateTime.now}", current_user.id)
      redirect_to admin_digital_service_account_path(@digital_service_account), notice: "Digital Service Account #{@digital_service_account.name} was published."
    else
      render :edit
    end
  end

  def archive
    # ensure_digital_service_account_admin(website: @website, user: current_user)
    @digital_service_account.archive!
    if @digital_service_account.save
      Event.log_event(Event.names[:digital_service_account_archived], "Digital Service Account", @digital_service_account.id, "Digital Service Account #{@digital_service_account.name} archived at #{DateTime.now}", current_user.id)
      redirect_to admin_digital_service_account_path(@digital_service_account), notice: "Digital Service Account #{@digital_service_account.name} was archived."
    else
      render :edit
    end
  end

  def reset
    # ensure_digital_service_account_admin(website: @website, user: current_user)
    @digital_service_account.reset!
    if @digital_service_account.save
      Event.log_event(Event.names[:digital_service_account_reset], "Digital Service Account", @digital_service_account.id, "Digital Service Account #{@digital_service_account.name} reset at #{DateTime.now}", current_user.id)
      redirect_to admin_digital_service_account_path(@digital_service_account), notice: "Digital Service Account #{@digital_service_account.name} was reset."
    else
      render :edit
    end
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
        :tags,
        :tag_list)
    end
end
