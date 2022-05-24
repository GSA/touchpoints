class Api::V1::DigitalProductsController < ::UnauthenticatedApiController
  def index
    respond_to do |format|
      format.json {
        render json: DigitalProduct.all.order(:id), each_serializer: DigitalProductSerializer
      }
    end
  end

  def show
    @digital_product = DigitalProduct.find(params[:id])

    respond_to do |format|
      format.json {
        render json: @digital_product, serializer: DigitalProductSerializer
      }
    end
  end
end
