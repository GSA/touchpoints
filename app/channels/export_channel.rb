class ExportChannel < ApplicationCable::Channel
  def subscribed
    stream_from "exports_channel_#{params[:uuid]}"
  end

  def unsubscribed; end
end