'use strict';

// send an activeSignal when fields lose focus
function setHeartbeat(url) {
  $('input, textarea, select, radio').on('blur', function(e) {
    return sendActiveSignal(url);
  });
}

//
// ActiveSignal
//
// ActiveSignal (or heartBeat) is used to prevent session timeouts on long-running pages;
// in a scenario where a user may take longer than 15 minutes from loading to clicking submit.
// eg: pages with 70 input fields
//
function sendActiveSignal(url) {
  console.log("sending Touchpoints ActiveSignal");

  return $.ajax({
    type: "GET",
    url: url
  }).done(function() {
    console.log("💗 web server acknowledges Touchpoints ActiveSignal")
  });
}
