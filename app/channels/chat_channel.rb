class ChatChannel < ApplicationCable::Channel
  def subscribed
    # stream_from "kenpi_channel"
    stream_from "chat_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

 def speak(data)
    ActionCable.server.broadcast "chat_channel", message: data["message"], sent_by: data["name"]
  end
end
