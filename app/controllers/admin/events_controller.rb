# frozen_string_literal: true

module Admin
  class EventsController < AdminController
    before_action :ensure_admin

    def index
      @events = Event.limit(500).order('created_at DESC').page params[:page]
    end

    def show
      @event = Event.find_by_id(params[:id])
    end
  end
end
