# frozen_string_literal: true

class SiteController < ApplicationController
  def index
    redirect_to admin_root_path if current_user
  end

  def agencies; end

  def registry; end

  def status
    render json: {
      status: :success,
      services: {
        database: :operational
      }
    }
  end

  def hello_stimulus; end
end
