# frozen_string_literal: true

module Api
  module V1
    class CxResponsesController < ::ApiController
      def index
        page = (params[:page].present? ? params[:page].to_i : 0)
        size = (params[:size].present? ? params[:size].to_i : 500)
        size = 5000 if size > 5000

        begin
          start_date = params[:start_date] ? Date.parse(params[:start_date]).to_date : Date.parse("2023-10-01").to_date
          end_date = params[:end_date] ? Date.parse(params[:end_date]).to_date : 1.day.from_now
        rescue StandardError
          render json: { error: { message: "invalid date format, should be 'YYYY-MM-DD'", status: 400 } }, status: :bad_request and return
        end

        cx_responses = CxResponse.limit(size)

        respond_to do |format|
          format.json do
            render json: cx_responses, each_serializer: CxResponseSerializer,
              links: links(cx_responses, page, size),
              page: page,
              size: size,
              start_date: start_date,
              end_date: end_date
          end
        end

      end

      def links(cx_responses, page, size)
        ret = {}
        if params[:page].present?
          ret['first'] = request.original_url.gsub(/page=[0-9]+/i, 'page=0')
          ret['next'] = request.original_url.gsub(/page=[0-9]+/i, "page=#{page + 1}") if cx_responses.size > ((page + 1) * size)
          ret['prev'] = request.original_url.gsub(/page=[0-9]+/i, "page=#{page - 1}") if page.positive?
          ret['last'] = request.original_url.gsub(/page=[0-9]+/i, "page=#{(cx_responses.size / size).floor}")
        else
          ret['first'] = "#{request.original_url}&page=0"
          ret['next'] = "#{request.original_url}&page=1" if cx_responses.size > size
          ret['last'] = "#{request.original_url}&page=#{(cx_responses.size / size).floor}"
        end
        ret
      end
    end
  end
end
