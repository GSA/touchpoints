'use strict';
window.sendHeartbeat = function(url) {
  $('input,textarea,select,radio').on('blur',function(e){
      $.ajax({
        type: "GET",
        url: url,
        success: function (data) {
          // console.log(data);
        }
      });

  });
}
