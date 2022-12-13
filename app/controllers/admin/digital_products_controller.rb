# frozen_string_literal: true

module Admin
  class DigitalProductsController < AdminController
    before_action :set_digital_product, only: %i[
      show edit update destroy
      add_tag remove_tag
      add_organization remove_organization
      add_user remove_user
      submit publish archive reset
    ]

    def index

      respond_to do |format|
        format.html do
          if admin_permissions?
            @digital_products = DigitalProduct.all
          else
            @digital_products = DigitalProduct.with_role(:contact, current_user)
          end

          @digital_products = @digital_products
            .order(:name, :service)
            .page(params[:page])
        end

        format.csv do
          csv_content = DigitalProduct.to_csv
          send_data csv_content
        end
      end
    end

    def review
      if admin_permissions?
        @digital_products = DigitalProduct.all
      else
        @digital_products = DigitalProduct.with_role(:contact, current_user)
      end

      @digital_products = @digital_products
        .where("aasm_state = 'created' OR aasm_state = 'updated' OR aasm_state = 'submitted'")
        .order(:name, :service)
        .page(params[:page])
    end

    def show; end

    def new
      @digital_product = DigitalProduct.new
    end

    def edit
      ensure_digital_product_permissions(digital_product: @digital_product)
    end

    def create
      @digital_product = DigitalProduct.new(digital_product_params)
      @digital_product.organization_list.add(current_user.organization_id)

      if @digital_product.save
        Event.log_event(Event.names[:digital_product_created], 'Digital Product', @digital_product.id, "Digital Product #{@digital_product.name} created at #{DateTime.now}", current_user.id)

        UserMailer.notification(
          title: 'Digital Product has been created',
          body: "Digital Product #{@digital_product.name} created at #{DateTime.now} by #{current_user.email}",
          path: admin_digital_product_url(@digital_product),
          emails: (User.admins.collect(&:email) + User.registry_managers.collect(&:email)).uniq,
        ).deliver_later

        current_user.add_role(:contact, @digital_product)
        redirect_to admin_digital_product_path(@digital_product), notice: 'Digital product was successfully created.'
      else
        render :new
      end
    end

    def update
      if @digital_product.update(digital_product_params)
        Event.log_event(Event.names[:digital_product_updated], 'Digital Product', @digital_product.id, "Digital Product #{@digital_product.name} updated at #{DateTime.now}", current_user.id)

        redirect_to admin_digital_product_path(@digital_product), notice: 'Digital product was successfully updated.'
      else
        render :edit
      end
    end

    def destroy
      ensure_digital_product_permissions(digital_product: @digital_product)
      @digital_product.destroy
      Event.log_event(Event.names[:digital_product_deleted], 'Digital Product', @digital_product.id, "Digital Product #{@digital_product.name} deleted at #{DateTime.now}", current_user.id)
      redirect_to admin_digital_products_url, notice: 'Digital product was deleted.'
    end

    def add_tag
      ensure_digital_product_permissions(digital_product: @digital_product)
      @digital_product.tag_list.add(digital_product_params[:tag_list].split(','))
      @digital_product.save
    end

    def remove_tag
      ensure_digital_product_permissions(digital_product: @digital_product)
      @digital_product.tag_list.remove(digital_product_params[:tag_list].split(','))
      @digital_product.save
    end

    def add_organization
      ensure_digital_product_permissions(digital_product: @digital_product)
      @digital_product.organization_list.add(params[:organization_id])
      @digital_product.save
      set_sponsoring_agency_options
    end

    def remove_organization
      ensure_digital_product_permissions(digital_product: @digital_product)
      @digital_product.organization_list.remove(params[:organization_id])
      @digital_product.save
      set_sponsoring_agency_options
    end

    def add_user
      ensure_digital_product_permissions(digital_product: @digital_product)
      @user = User.find_by_email(params[:user][:email])
      @user&.add_role(:contact, @digital_product)
    end

    def remove_user
      ensure_digital_product_permissions(digital_product: @digital_product)
      @user = User.find_by_id(params[:user][:id])
      @user&.remove_role(:contact, @digital_product)
    end

    def submit
      ensure_digital_product_permissions(digital_product: @digital_product)
      if @digital_product.submit!
        Event.log_event(Event.names[:digital_product_submitted], 'Digital Product', @digital_product.id, "Digital Product #{@digital_product.name} submitted at #{DateTime.now}", current_user.id)

        UserMailer.notification(
          title: 'Digital Product has been submitted',
          body: "Digital Product #{@digital_product.name} submitted at #{DateTime.now} by #{current_user.email}",
          path: admin_digital_product_url(@digital_product),
          emails: (User.admins.collect(&:email) + User.registry_managers.collect(&:email)).uniq,
        ).deliver_later

        redirect_to admin_digital_product_path(@digital_product), notice: 'Digital product was successfully submitted.'
      else
        render :edit
      end
    end

    def publish
      ensure_digital_product_permissions(digital_product: @digital_product)

      if @digital_product.publish!
        Event.log_event(Event.names[:digital_product_published], 'Digital Product', @digital_product.id, "Digital Product #{@digital_product.name} published at #{DateTime.now}", current_user.id)

        UserMailer.notification(
          title: 'Digital Product has been published',
          body: "Digital Product #{@digital_product.name} published at #{DateTime.now} by #{current_user.email}",
          path: admin_digital_product_url(@digital_product),
          emails: (User.admins.collect(&:email) + User.registry_managers.collect(&:email) + @digital_product.roles.first.users.collect(&:email)).uniq,
        ).deliver_later

        redirect_to admin_digital_product_path(@digital_product), notice: "Digital Product #{@digital_product.name} was published."
      else
        render :edit
      end
    end

    def archive
      ensure_digital_product_permissions(digital_product: @digital_product)

      if @digital_product.archive!
        Event.log_event(Event.names[:digital_product_archived], 'Digital Product', @digital_product.id, "Digital Product #{@digital_product.name} archived at #{DateTime.now}", current_user.id)

        UserMailer.notification(
          title: 'Digital Product has been archived',
          body: "Digital Product #{@digital_product.name} archived at #{DateTime.now} by #{current_user.email}",
          path: admin_digital_product_url(@digital_product),
          emails: (User.admins.collect(&:email) + User.registry_managers.collect(&:email)).uniq,
        ).deliver_later

        redirect_to admin_digital_product_path(@digital_product), notice: "Digital Product #{@digital_product.name} was archived."
      else
        render :edit
      end
    end

    def reset
      ensure_digital_product_permissions(digital_product: @digital_product)

      if @digital_product.reset!
        Event.log_event(Event.names[:digital_product_reset], 'Digital Product', @digital_product.id, "Digital Product #{@digital_product.name} reset at #{DateTime.now}", current_user.id)
        redirect_to admin_digital_product_path(@digital_product), notice: "Digital Product #{@digital_product.name} was reset."
      else
        render :edit
      end
    end

    def search
      search_text = params[:search]
      organization_id = params[:organization_id]

      @digital_products = DigitalProduct.all
      @digital_products = @digital_products.where("name ilike '%#{search_text}%'") if search_text && search_text.length >= 3
      @digital_products = @digital_products.tagged_with(organization_id, context: 'organizations') if organization_id.present? && organization_id != ''
      @digital_products = @digital_products.where(service: params[:service]) if params[:service].present? && params[:service] != 'All'
      @digital_products = @digital_products.where(aasm_state: params[:aasm_state].downcase) if params[:aasm_state].present? && params[:aasm_state] != 'All'
      @digital_products
    end

    private

    def set_digital_product
      @digital_product = DigitalProduct.find(params[:id])
      set_sponsoring_agency_options
    end

    def set_sponsoring_agency_options
      @sponsoring_agency_options = Organization.all.order(:name)
      @sponsoring_agency_options -= @digital_product.sponsoring_agencies if @sponsoring_agency_options && @digital_product
    end

    def digital_product_params
      params.require(:digital_product).permit(
        :organization_id,
        :user_id,
        :name,
        :service,
        :url,
        :code_repository_url,
        :language,
        :status,
        :aasm_state,
        :short_description,
        :long_description,
        :certified_at,
        :tag_list,
        :organization_list,
      )
    end
  end
end
