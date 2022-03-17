// app/assets/javascripts/cable.js
//= require actioncable
//= require_self
//= require_tree ./channels

(function() {
  this.App || (this.App = {});
  App.cable = ActionCable.createConsumer();
}).call(this);
