# frozen_string_literal: true

module Api
  module V1
    class DigitalServiceAccountsController < ::UnauthenticatedApiController
      def index
        page = (params[:page].present? ? params[:page].to_i : 0)
        size = (params[:size].present? ? params[:size].to_i : 100)
        size = 100 if size > 100

        respond_to do |format|
          format.json do
            @total_count = DigitalServiceAccount.active.count

            @digital_service_accounts = DigitalServiceAccount.active
              .limit(size)
              .offset(size * page)
              .order(:id)

            render json: @digital_service_accounts,
              meta: {
                size: size,
                page: page,
                totalPages: (@total_count / size).floor
              },
              links: links(page, size),
              each_serializer: DigitalServiceAccountSerializer
          end
        end
      end

      def show
        @digital_service_account = DigitalServiceAccount.find(params[:id])

        respond_to do |format|
          format.json do
            render json: @digital_service_account,
              serializer: DigitalServiceAccountSerializer
          end
        end
      end

      def links(page, size)
        ret = {}
        if params[:page].present?
          ret['first'] = request.original_url.gsub(/page=[0-9]+/i, 'page=0')
          ret['next'] = request.original_url.gsub(/page=[0-9]+/i, "page=#{page + 1}") if @digital_service_accounts.size > ((page + 1) * size)
          ret['prev'] = request.original_url.gsub(/page=[0-9]+/i, "page=#{page - 1}") if page.positive?
          ret['last'] = request.original_url.gsub(/page=[0-9]+/i, "page=#{(@digital_service_accounts.size / size).floor}")
        else
          ret['first'] = "#{request.original_url}&page=0"
          ret['next'] = "#{request.original_url}&page=1" if @digital_service_accounts.size > size
          ret['last'] = "#{request.original_url}&page=#{(@digital_service_accounts.size / size).floor}"
        end
        ret
      end
    end
  end
end
