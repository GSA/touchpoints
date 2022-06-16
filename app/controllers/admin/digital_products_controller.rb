class Admin::DigitalProductsController < AdminController
  before_action :set_digital_product, only: [
    :show, :edit, :update, :destroy,
    :add_tag, :remove_tag,
    :add_organization, :remove_organization,
    :add_user, :remove_user,
    :submit, :publish, :archive, :reset
  ]

  def index
    @digital_products = DigitalProduct.order(:name, :service).page(params[:page])
  end

  def review
    @digital_products = DigitalProduct.where("aasm_state = 'created' OR aasm_state = 'edited'").order(:name, :service).page(params[:page])
  end

  def show
  end

  def new
    @digital_product = DigitalProduct.new
  end

  def edit
  end

  def create
    @digital_product = DigitalProduct.new(digital_product_params)

    if @digital_product.save
      current_user.add_role(:contact, @digital_product)
      current_user.organization.add_role(:sponsor, @digital_product)
      redirect_to admin_digital_product_path(@digital_product), notice: 'Digital product was successfully created.'
    else
      render :new
    end
  end

  def update
    if @digital_product.update(digital_product_params)
      redirect_to admin_digital_product_path(@digital_product), notice: 'Digital product was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @digital_product.destroy
    redirect_to admin_digital_products_url, notice: 'Digital product was successfully destroyed.'
  end

  def add_tag
    @digital_product.tag_list.add(digital_product_params[:tag_list].split(','))
    @digital_product.save
  end

  def remove_tag
    @digital_product.tag_list.remove(digital_product_params[:tag_list].split(','))
    @digital_product.save
  end

  def add_organization
    @digital_product.organization_list.add(params[:organization_id])
    @digital_product.save
    set_sponsoring_agency_options
  end

  def remove_organization
    @digital_product.organization_list.remove(params[:organization_id])
    @digital_product.save
    set_sponsoring_agency_options
  end

  def add_user
    @user = User.find_by_email(params[:user][:email])

    if @user
      @user.add_role(:contact, @digital_product)
    end
  end

  def remove_user
    @user = User.find_by_id(params[:user][:id])
    if @user
      @user.remove_role(:contact, @digital_product)
    end
  end

  def submit
    if @digital_product.submit!
      Event.log_event(Event.names[:digital_product_submitted], "Digital Product", @digital_product.id, "Digital Product #{@digital_product.name} submitted at #{DateTime.now}", current_user.id)

      UserMailer.notification(
        title: "Digital Product has been submitted",
        body: "Digital Product #{@digital_product.name} submitted at #{DateTime.now} by #{current_user.email}",
        path: admin_digital_product_url(@digital_product),
        emails: User.registry_managers.collect(&:email)
      ).deliver_later

      redirect_to admin_digital_product_path(@digital_product), notice: 'Digital product was successfully submitted.'
    else
      render :edit
    end
  end

  def publish
    ensure_digital_product_permissions(digital_product: @digital_product)

    if @digital_product.publish!
      Event.log_event(Event.names[:digital_product_published], "Digital Product", @digital_product.id, "Digital Product #{@digital_product.name} published at #{DateTime.now}", current_user.id)

      UserMailer.notification(
        title: "Digital Product has been published",
        body: "Digital Product #{@digital_product.name} published at #{DateTime.now} by #{current_user.email}",
        path: admin_digital_product_url(@digital_product),
        emails: User.registry_managers.collect(&:email) # + @digital_product.contact_emails
      ).deliver_later

      redirect_to admin_digital_product_path(@digital_product), notice: "Digital Product #{@digital_product.name} was published."
    else
      render :edit
    end
  end

  def archive
    ensure_digital_product_permissions(digital_product: @digital_product)

    if @digital_product.archive!
      Event.log_event(Event.names[:digital_product_archived], "Digital Product", @digital_product.id, "Digital Product #{@digital_product.name} archived at #{DateTime.now}", current_user.id)
      redirect_to admin_digital_product_path(@digital_product), notice: "Digital Product #{@digital_product.name} was archived."
    else
      render :edit
    end
  end

  def reset
    ensure_digital_product_permissions(digital_product: @digital_product)

    if @digital_product.reset!
      Event.log_event(Event.names[:digital_product_reset], "Digital Service Account", @digital_product.id, "Digital Product #{@digital_product.name} reset at #{DateTime.now}", current_user.id)
      redirect_to admin_digital_product_path(@digital_product), notice: "Digital Service Account #{@digital_product.name} was reset."
    else
      render :edit
    end
  end

  def search
    search_text = params[:search]
    organization_id = params[:organization_id]

    if search_text && search_text.length >= 3
      @digital_products = DigitalProduct.where("name ilike '%#{search_text}%'")
    elsif organization_id
      @digital_products = DigitalProduct.where("organization_id = ?", organization_id)
    else
      @digital_products = DigitalProduct.all
    end
  end

  private

  def set_digital_product
    @digital_product = DigitalProduct.find(params[:id])
    set_sponsoring_agency_options
  end

  def set_sponsoring_agency_options
    @sponsoring_agency_options = Organization.all.order(:name)
    if @sponsoring_agency_options && @digital_product
      @sponsoring_agency_options = @sponsoring_agency_options - @digital_product.sponsoring_agencies
    end
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
      :organization_list
    )
  end
end
