function subscribeExportChannel(uuid, url, completionCallback) {
  App.cable.subscriptions.create(
    { channel: "ExportChannel", uuid: uuid },
    {
      connected: function() {
        $.ajax(url)
          .fail(response => {
            this.unsubscribe();
            if (response.status === 400 && response.responseText) {
              this.downloadError(response.responseText);
            } else {
              this.downloadError();
            }
            completionCallback();
          });
      },

      // Called when the WebSocket connection is closed, either by server or by client-side stale connection monitor.
      // If the connection closes before we receive a response, count that as a failed export and unsubscribe.
      // Reconnecting is not useful because we can't tell whether the response was sent while we were disconnected.
      disconnected: function() {
        this.downloadError('Websocket disconnected unexpectedly.');

        // 'this' is the subscription object
        this.unsubscribe();
        completionCallback();
      },

      received: function(data) {
        const dataUrl = data.url;
        const filename = data.filename;
        $.ajax(dataUrl)
          .done(function(data) {
            const blob = new Blob([data], {
              type: "text/csv;charset=utf-8"
            });
            saveAs(blob, filename);
          })
          .fail(() => this.downloadError(`Invalid download link: ${dataUrl}`))
          .always(() => completionCallback());

        // 'this' is the subscription object
        this.unsubscribe();
      },

      downloadError: function(errorExplanation = '') {
        const errorText = `Your export failed.\n\n${errorExplanation}`

        const blob = new Blob([errorText], {
          type: "text/plain;charset=utf-8"
        });

        saveAs(blob, `touchpoints-failed-export-${(new Date().toISOString().slice(0, 19))}`);
      }
    }
  );
}
