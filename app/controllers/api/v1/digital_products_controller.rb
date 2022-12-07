# frozen_string_literal: true

module Api
  module V1
    class DigitalProductsController < ::UnauthenticatedApiController
      def index
        respond_to do |format|
          format.json do
            page = (params[:page].present? ? params[:page].to_i : 0)
            size = (params[:size].present? ? params[:size].to_i : 100)
            size = 100 if size > 100

            @total_count = DigitalProduct.active.count
            @digital_products = DigitalProduct.active
              .limit(size)
              .offset(size * page)
              .order(:id)

            render json: @digital_products,
              meta: {
                size: size,
                page: page,
                totalPages: (@total_count / size).floor
              },
              links: links(page, size),
              each_serializer: DigitalProductSerializer
          end
        end
      end

      def show
        @digital_product = DigitalProduct.find(params[:id])

        respond_to do |format|
          format.json do
            render json: @digital_product,
              serializer: DigitalProductSerializer
          end
        end
      end

      def links(page, size)
        ret = {}
        if params[:page].present?
          ret['first'] = request.original_url.gsub(/page=[0-9]+/i, 'page=0')
          ret['next'] = request.original_url.gsub(/page=[0-9]+/i, "page=#{page + 1}") if @digital_products.size > ((page + 1) * size)
          ret['prev'] = request.original_url.gsub(/page=[0-9]+/i, "page=#{page - 1}") if page.positive?
          ret['last'] = request.original_url.gsub(/page=[0-9]+/i, "page=#{(@total_count / size).floor}")
        else
          ret['first'] = "#{request.original_url}&page=0"
          ret['next'] = "#{request.original_url}&page=1" if @digital_products.size > size
          ret['last'] = "#{request.original_url}&page=#{(@total_count / size).floor}"
        end
        ret
      end

    end
  end
end
