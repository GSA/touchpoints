class Admin::DigitalProductsController < AdminController
  before_action :set_digital_product, only: [
    :show, :edit, :update, :destroy,
    :add_tag, :remove_tag,
    :add_organization, :remove_organization,
    :add_user, :remove_user,
    :certify, :publish, :archive, :reset
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
    @digital_product.organization_id = current_user.organization_id
  end

  def edit
  end

  def create
    @digital_product = DigitalProduct.new(digital_product_params)
    @digital_product.user = current_user

    if @digital_product.save
      @digital_product.user.add_role(:contact, @digital_product)
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
    @organization = Organization.find_by_id(params[:organization][:id])

    if @organization
      @organization.add_role(:sponsor, @digital_product)
    end
  end

  def remove_organization
    @organization = Organization.find_by_id(params[:organization][:id])

    if @organization
      @organization.remove_role(:sponsor, @digital_product)
    end
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

  def certify
    @digital_product.certify
    @digital_product.certified_at = Time.now

    if @digital_product.save!
      Event.log_event(Event.names[:digital_product_certified], "Digital Product", @digital_product.id, "Digital Product #{@digital_product.name} certified at #{DateTime.now}", current_user.id)
      redirect_to admin_digital_product_path(@digital_product), notice: 'Digital product was successfully certified.'
    else
      render :edit
    end
  end

  def publish
    ensure_digital_product_permissions(digital_product: @digital_product)

    @digital_product.publish
    if @digital_product.save
      Event.log_event(Event.names[:digital_product_published], "Digital Product", @digital_product.id, "Digital Product #{@digital_product.name} published at #{DateTime.now}", current_user.id)
      redirect_to admin_digital_product_path(@digital_product), notice: "Digital Product #{@digital_product.name} was published."
    else
      render :edit
    end
  end

  def archive
    ensure_digital_product_permissions(digital_product: @digital_product)

    @digital_product.archive

    if @digital_product.save!
      Event.log_event(Event.names[:digital_product_archived], "Digital Product", @digital_product.id, "Digital Product #{@digital_product.name} archived at #{DateTime.now}", current_user.id)
      redirect_to admin_digital_product_path(@digital_product), notice: "Digital Product #{@digital_product.name} was archived."
    else
      render :edit
    end
  end

  def reset
    ensure_digital_product_permissions(digital_product: @digital_product)
    @digital_product.reset

    if @digital_product.save!
      Event.log_event(Event.names[:digital_product_reset], "Digital Service Account", @digital_product.id, "Digital Product #{@digital_product.name} reset at #{DateTime.now}", current_user.id)
      redirect_to admin_digital_product_path(@digital_product), notice: "Digital Service Account #{@digital_product.name} was reset."
    else
      render :edit
    end
  end

  private
    def set_digital_product
      @digital_product = DigitalProduct.find(params[:id])
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
        :tag_list
      )
    end
end
