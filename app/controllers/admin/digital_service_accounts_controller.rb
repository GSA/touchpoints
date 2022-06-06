# frozen_string_literal: true

module Admin
  class DigitalServiceAccountsController < AdminController

  before_action :set_digital_service_account, only: [
    :show, :edit, :update, :destroy,
    :add_tag, :remove_tag,
    :add_user, :remove_user,
    :add_organization, :remove_organization,
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
      Event.log_event(Event.names[:digital_service_account_updated], 'DigitalServiceAccount',
        @digital_service_account.id, "updated by #{current_user.email} on #{Date.today}", current_user.id)
      redirect_to admin_digital_service_account_path(@digital_service_account),
                  notice: 'Digital service account was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @digital_service_account.destroy
    Event.log_event(Event.names[:digital_service_account_deleted], 'DigitalServiceAccount',
      @digital_service_account.id, "deleted by #{current_user.email} on #{Date.today}", current_user.id)
    redirect_to admin_digital_service_accounts_url, notice: 'Digital service account was deleted.'
  end

  def add_tag
    @digital_service_account.tag_list.add(digital_service_account_params[:tag_list].split(','))
    @digital_service_account.save
  end

  def remove_tag
    @digital_service_account.tag_list.remove(digital_service_account_params[:tag_list].split(','))
    @digital_service_account.save
  end

  def add_organization
    @organization = Organization.find_by_id(params[:organization][:id])

    if @organization
      @organization.add_role(:sponsor, @digital_service_account)
    end
  end

  def remove_organization
    @organization = Organization.find_by_id(params[:organization][:id])

    if @organization
      @organization.remove_role(:sponsor, @digital_service_account)
    end
  end

  def add_user
    @user = User.find_by_email(params[:user][:email])

    if @user
      @user.add_role(:contact, @digital_service_account)
    end
  end

  def remove_user
    @user = User.find_by_id(params[:user][:id])

    if @user
      @user.remove_role(:contact, @digital_service_account)
    end
  end

  def certify
    ensure_digital_service_account_permissions(digital_service_account: @digital_service_account)
    @digital_service_account.certify!

    if @digital_service_account.save
      Event.log_event(Event.names[:digital_service_account_certified], "Digital Service Account", @digital_service_account.id, "Digital Service Account #{@digital_service_account.name} certified at #{DateTime.now}", current_user.id)
      redirect_to admin_digital_service_account_path(@digital_service_account), notice: "Digital Service Account #{@digital_service_account.name} was certified."
    else
      render :edit
    end
  end

  def publish
    ensure_digital_service_account_permissions(digital_service_account: @digital_service_account)
    @digital_service_account.publish!

    if @digital_service_account.save
      Event.log_event(Event.names[:digital_service_account_published], "Digital Service Account", @digital_service_account.id, "Digital Service Account #{@digital_service_account.name} published at #{DateTime.now}", current_user.id)
      redirect_to admin_digital_service_account_path(@digital_service_account), notice: "Digital Service Account #{@digital_service_account.name} was published."
    else
      render :edit
    end
  end

  def archive
    ensure_digital_service_account_permissions(digital_service_account: @digital_service_account)
    @digital_service_account.archive!

    if @digital_service_account.save
      Event.log_event(Event.names[:digital_service_account_archived], "Digital Service Account", @digital_service_account.id, "Digital Service Account #{@digital_service_account.name} archived at #{DateTime.now}", current_user.id)
      redirect_to admin_digital_service_account_path(@digital_service_account), notice: "Digital Service Account #{@digital_service_account.name} was archived."
    else
      render :edit
    end
  end

  def reset
    ensure_digital_service_account_permissions(digital_service_account: @digital_service_account)
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
end
