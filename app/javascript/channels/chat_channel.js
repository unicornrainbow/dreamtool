import consumer from "./consumer"

const chatChannel = consumer.subscriptions.create("ChatChannel", {
  connected() {
    // Called when the subscription is ready for use on the server
    console.log("Connected to the chat! room!");
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  received(data) {
    // Called when there's incoming data on the websocket for this channel
    $('#messages').append('<p class="received"> ' + data.message + '</p>')
  },

  speak(message) {
    this.perform('speak', { message: message })
  }
});

export default chatChannel;
