function subscribeExportChannel(uuid, startExportJobFtn, completionCallback) {
  App.cable.subscriptions.create(
    { channel: "ExportChannel", uuid: uuid },
    {
      connected: function() {
        startExportJobFtn();
      },

      // Called when the WebSocket connection is closed, either by server or by client-side stale connection monitor.
      // If the connection closes before we receive a response, count that as a failed export and unsubscribe.
      // Reconnecting is not useful because we can't tell whether the response was sent while we were disconnected.
      disconnected: function() {
        const errorText = "We're sorry, your download has failed. That happens sometimes for response sets over several MB's in size.\n\n" +
          "We're working on fixing this problem. You can monitor our progress at https://github.com/GSA/touchpoints/issues/1446. " +
          "In the meantime, you can use our API to download large response sets. View API documentation at https://github.com/GSA/touchpoints/wiki/API.";

        const blob = new Blob([errorText], {
          type: "text/plain;charset=utf-8"
        });

        saveAs(blob, `touchpoints-failed-export-${(new Date().toISOString().slice(0, 19))}`);

        // 'this' is the subscription object
        this.unsubscribe();
        completionCallback();
      },

      received: function(data) {

        const blob = new Blob([data.csv], {
          type: "text/csv;charset=utf-8"
        });

        saveAs(blob, data.filename);

        // 'this' is the subscription object
        this.unsubscribe();
        completionCallback();
      },
    }
  );
}
