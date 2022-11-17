# frozen_string_literal: true

module Admin
  class DigitalProductVersionsController < AdminController
    before_action :set_digital_product
    before_action :set_digital_product_version, only: %i[show edit update destroy]

    def index
      @digital_product_versions = DigitalProductVersion.where(digital_product_id: params[:digital_product_id])
    end

    def show; end

    def new
      @digital_product_version = DigitalProductVersion.new
    end

    def edit
      @digital_product_version = DigitalProductVersion.find(params[:id])
    end

    def create
      @digital_product_version = DigitalProductVersion.new(digital_product_version_params)

      if @digital_product_version.save
        redirect_to admin_digital_product_digital_product_versions_path(@digital_product)
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      @digital_product_version = DigitalProductVersion.find(params[:id])

      if @digital_product_version.update(digital_product_version_params)
        redirect_to admin_digital_product_digital_product_versions_path(@digital_product)
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      digital_product_version = DigitalProductVersion.destroy(params[:id])
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to admin_digital_product_digital_product_versions_path(@digital_product) }
      end
    end

    private

    # Use callbacks to share common setup or constraints between actions.
    def set_digital_product
      @digital_product = DigitalProduct.find(params[:digital_product_id])
    end

    def set_digital_product_version
      @digital_product_version = DigitalProductVersion.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def digital_product_version_params
      params.require(:digital_product_version).permit(:digital_product_id, :store_url, :platform, :version_number, :publish_date, :description, :whats_new, :screenshot_url, :device, :language, :average_rating, :number_of_ratings)
    end
  end
end
