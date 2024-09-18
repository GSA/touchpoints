# frozen_string_literal: true

class SiteController < ApplicationController
  def index
    redirect_to admin_root_path if current_user
  end

  def agencies; end

  def docs
    tables = ActiveRecord::Base.connection.tables
    tables_specific_to_rails = [
      "active_storage_variant_records",
      "active_storage_blobs",
      "active_storage_attachments",
      "schema_migrations",
      "ar_internal_metadata"
    ]
    @tables = tables - tables_specific_to_rails
  end

  def registry
    @results = nil
  end

  def status
    render json: {
      status: :success,
      services: {
        database: :operational,
      },
    }
  end

  def hello_stimulus; end

  def search_params
      params.require(:search).permit(
        :organization_id,
        :tags,
        :platform,
        :status
      )
    end
end
