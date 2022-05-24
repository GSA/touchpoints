class Admin::DigitalProductsController < AdminController
  before_action :set_digital_product, only: [:show, :edit, :update, :destroy, :add_tag, :remove_tag, :certify, :archive]

  def index
    @digital_products = DigitalProduct.order(:name, :service).page(params[:page])
  end

  def review
    @digital_products = DigitalProduct.order(:name, :service).page(params[:page])
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

  def certify
    @digital_product.certify
    redirect_to admin_digital_product_url(@digital_product), notice: 'Digital product was successfully certified.'
  end

  def archive
    @digital_product.archive
    redirect_to admin_digital_product_url(@digital_product), notice: 'Digital product was successfully archiv ed.'
  end

  private
    def set_digital_product
      @digital_product = DigitalProduct.find(params[:id])
    end

    def digital_product_params
      params.require(:digital_product).permit(
        :organization_id,
        :user_id,
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
