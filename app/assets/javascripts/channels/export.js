function subscribeExportChannel(uuid, callback) {
  App.download = App.cable.subscriptions.create(
    { channel: "ExportChannel", uuid: uuid },
    {
      connected: function() {
        callback();
      },

      disconnected: function() {},

      received: function(data) {

        var blob = new Blob([data.csv], {
          type: "text/csv;charset=utf-8"
        });

        saveAs(blob, data.filename);

        $(".export-btn.cursor-not-allowed")
          .html("Export FY Responses")
          .removeClass('cursor-not-allowed');

        $(".export-all-btn.cursor-not-allowed")
          .html("Export Responses to CSV")
          .removeClass('cursor-not-allowed');

        $(".export-a11-v2-btn.cursor-not-allowed")
          .html("Export A11v2 Responses to CSV")
          .removeClass('cursor-not-allowed');

        App.download.unsubscribe();
        App.cable.disconnect();
        delete App.download;
      }
    }
  );
}
