# frozen_string_literal: true

module Admin
  class DigitalServiceAccountsController < AdminController
    before_action :set_digital_service_account, only: %i[
      show edit update destroy
      add_tag remove_tag
      add_user remove_user
      add_organization remove_organization
      submit publish archive reset
    ]

    def index
      respond_to do |format|
        if admin_permissions?
          @digital_service_accounts = DigitalServiceAccount.all
        else
          @digital_service_accounts = DigitalServiceAccount.with_role(:contact, current_user)
        end

        @digital_service_accounts = @digital_service_accounts
          .order(:name)
          .page(params[:page])

        format.html {}

        format.csv do
          csv_content = DigitalServiceAccount.to_csv
          send_data csv_content
        end
      end
    end

    def review
      if admin_permissions?
        @digital_service_accounts = DigitalServiceAccount.all
      else
        @digital_service_accounts = DigitalServiceAccount.with_role(:contact, current_user)
      end

      @digital_service_accounts = @digital_service_accounts
        .where("aasm_state = 'created' OR aasm_state = 'updated' OR aasm_state = 'submitted'")
        .order(:name)
        .page(params[:page])
    end

    def show; end

    def new
      @digital_service_account = DigitalServiceAccount.new
    end

    def edit
      ensure_digital_service_account_permissions(digital_service_account: @digital_service_account)
    end

    def create
      @digital_service_account = DigitalServiceAccount.new(digital_service_account_params)
      @digital_service_account.organization_list.add(current_user.organization_id)

      if @digital_service_account.save
        current_user.add_role(:contact, @digital_service_account)

        Event.log_event(Event.names[:digital_service_account_created], 'Digital Service Account', @digital_service_account.id, "Digital Service Account #{@digital_service_account.name} created at #{DateTime.now}", current_user.id)

        UserMailer.notification(
          title: 'Digital Service Account was created',
          body: "Digital Service Account #{@digital_service_account.name} created at #{DateTime.now} by #{current_user.email}",
          path: admin_digital_service_account_url(@digital_service_account),
          emails: (User.admins.collect(&:email) + User.registry_managers.collect(&:email)).uniq,
        ).deliver_later

        redirect_to admin_digital_service_account_path(@digital_service_account), notice: 'Digital service account was successfully created.'
      else
        render :new
      end
    end

    def update
      ensure_digital_service_account_permissions(digital_service_account: @digital_service_account)
      if @digital_service_account.update(digital_service_account_params)
        Event.log_event(Event.names[:digital_service_account_updated], 'DigitalServiceAccount',
                        @digital_service_account.id, "updated by #{current_user.email} on #{Date.today}", current_user.id)
        @digital_service_account.update_state!
        redirect_to admin_digital_service_account_path(@digital_service_account),
                    notice: 'Digital service account was successfully updated.'
      else
        render :edit
      end
    end

    def destroy
      ensure_digital_service_account_permissions(digital_service_account: @digital_service_account)
      @digital_service_account.destroy
      Event.log_event(Event.names[:digital_service_account_deleted], 'DigitalServiceAccount',
                      @digital_service_account.id, "deleted by #{current_user.email} on #{Date.today}", current_user.id)
      redirect_to admin_digital_service_accounts_url, notice: 'Digital service account was deleted.'
    end

    def add_tag
      ensure_digital_service_account_permissions(digital_service_account: @digital_service_account)
      @digital_service_account.tag_list.add(digital_service_account_params[:tag_list].split(','))
      @digital_service_account.save
    end

    def remove_tag
      ensure_digital_service_account_permissions(digital_service_account: @digital_service_account)
      @digital_service_account.tag_list.remove(digital_service_account_params[:tag_list].split(','))
      @digital_service_account.save
    end

    def add_organization
      ensure_digital_service_account_permissions(digital_service_account: @digital_service_account)
      @digital_service_account.organization_list.add(params[:organization_id])
      @digital_service_account.save
      set_sponsoring_agency_options
    end

    def remove_organization
      ensure_digital_service_account_permissions(digital_service_account: @digital_service_account)
      @digital_service_account.organization_list.remove(params[:organization_id])
      @digital_service_account.save
      set_sponsoring_agency_options
    end

    def add_user
      ensure_digital_service_account_permissions(digital_service_account: @digital_service_account)
      @user = User.find_by_email(params[:user][:email])

      @user&.add_role(:contact, @digital_service_account)
    end

    def remove_user
      ensure_digital_service_account_permissions(digital_service_account: @digital_service_account)
      @user = User.find_by_id(params[:user][:id])

      @user&.remove_role(:contact, @digital_service_account)
    end

    def submit
      ensure_digital_service_account_permissions(digital_service_account: @digital_service_account)

      if @digital_service_account.submit!
        Event.log_event(Event.names[:digital_service_account_submitted], 'Digital Service Account', @digital_service_account.id, "Digital Service Account #{@digital_service_account.name} submitted at #{DateTime.now}", current_user.id)

        UserMailer.notification(
          title: 'Digital Service Account was submitted',
          body: "Digital Service Account #{@digital_service_account.name} submitted at #{DateTime.now} by #{current_user.email}",
          path: admin_digital_service_account_url(@digital_service_account),
          emails: (User.admins.collect(&:email) + User.registry_managers.collect(&:email)).uniq,
        ).deliver_later

        redirect_to admin_digital_service_account_path(@digital_service_account), notice: "Digital Service Account #{@digital_service_account.name} was submitted."
      else
        render :edit
      end
    end

    def publish
      ensure_digital_service_account_permissions(digital_service_account: @digital_service_account)

      if @digital_service_account.publish!
        Event.log_event(Event.names[:digital_service_account_published], 'Digital Service Account', @digital_service_account.id, "Digital Service Account #{@digital_service_account.name} published at #{DateTime.now}", current_user.id)

        UserMailer.notification(
          title: 'Digital Service Account was published',
          body: "Digital Service Account #{@digital_service_account.name} published at #{DateTime.now} by #{current_user.email}",
          path: admin_digital_service_account_url(@digital_service_account),
          emails: (User.admins.collect(&:email) + User.registry_managers.collect(&:email) + @digital_service_account.roles.first.users.collect(&:email)).uniq,
        ).deliver_later

        redirect_to admin_digital_service_account_path(@digital_service_account), notice: "Digital Service Account #{@digital_service_account.name} was published."
      else
        render :edit
      end
    end

    def archive
      ensure_digital_service_account_permissions(digital_service_account: @digital_service_account)

      if @digital_service_account.archive!
        Event.log_event(Event.names[:digital_service_account_archived], 'Digital Service Account', @digital_service_account.id, "Digital Service Account #{@digital_service_account.name} archived at #{DateTime.now}", current_user.id)

        UserMailer.notification(
          title: 'Digital Service Account was archived',
          body: "Digital Service Account #{@digital_service_account.name} archived at #{DateTime.now} by #{current_user.email}",
          path: admin_digital_service_account_url(@digital_service_account),
          emails: (User.admins.collect(&:email) + User.registry_managers.collect(&:email)).uniq,
        ).deliver_later

        redirect_to admin_digital_service_account_path(@digital_service_account), notice: "Digital Service Account #{@digital_service_account.name} was archived."
      else
        render :edit
      end
    end

    def reset
      ensure_digital_service_account_permissions(digital_service_account: @digital_service_account)

      if @digital_service_account.reset!
        Event.log_event(Event.names[:digital_service_account_reset], 'Digital Service Account', @digital_service_account.id, "Digital Service Account #{@digital_service_account.name} reset at #{DateTime.now}", current_user.id)
        redirect_to admin_digital_service_account_path(@digital_service_account), notice: "Digital Service Account #{@digital_service_account.name} was reset."
      else
        render :edit
      end
    end

    def search
      search_text = params[:search]
      organization_id = params[:organization_id]

      @digital_service_accounts = DigitalServiceAccount.all
      @digital_service_accounts = @digital_service_accounts.where("name ilike '%#{search_text}%' OR account ilike '%#{search_text}%' OR short_description ilike '%#{search_text}%'") if search_text && search_text.length >= 3
      @digital_service_accounts = @digital_service_accounts.tagged_with(organization_id, context: 'organizations') if organization_id.present? && organization_id != ''
      @digital_service_accounts = @digital_service_accounts.where(service: params[:service].downcase) if params[:service].present? && params[:service] != 'All'
      @digital_service_accounts = @digital_service_accounts.where(aasm_state: params[:aasm_state].downcase) if params[:aasm_state].present? && params[:aasm_state] != 'All'
      @digital_service_accounts
    end

    private

    def set_digital_service_account
      @digital_service_account = DigitalServiceAccount.find(params[:id])
      set_sponsoring_agency_options
    end

    def set_sponsoring_agency_options
      @sponsoring_agency_options = Organization.all.order(:name)
      @sponsoring_agency_options -= @digital_service_account.sponsoring_agencies if @sponsoring_agency_options && @digital_service_account
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
        :tag_list,
        :organization_list,
      )
    end
  end
end
