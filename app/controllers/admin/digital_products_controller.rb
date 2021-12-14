class Admin::DigitalProductsController < AdminController
  before_action :set_digital_product, only: [:show, :edit, :update, :destroy]

  # GET /digital_products
  def index
    @digital_products = DigitalProduct.all
  end

  # GET /digital_products/1
  def show
  end

  # GET /digital_products/new
  def new
    @digital_product = DigitalProduct.new
  end

  # GET /digital_products/1/edit
  def edit
  end

  # POST /digital_products
  def create
    @digital_product = DigitalProduct.new(digital_product_params)
    @digital_product.user = current_user

    if @digital_product.save
      redirect_to admin_digital_product_path(@digital_product), notice: 'Digital product was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /digital_products/1
  def update
    if @digital_product.update(digital_product_params)
      redirect_to admin_digital_product_path(@digital_product), notice: 'Digital product was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /digital_products/1
  def destroy
    @digital_product.destroy
    redirect_to admin_digital_products_url, notice: 'Digital product was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_digital_product
      @digital_product = DigitalProduct.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def digital_product_params
      params.require(:digital_product).permit(:organization_id, :user_id, :service, :url, :code_repository_url, :language, :status, :aasm_status, :short_description, :long_description, :tags, :certified_at)
    end
end
