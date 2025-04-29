// htmx config
htmx.config.globalViewTransitions = true;

htmx.on("htmx:beforeSwap", (evt) => {
    const status = evt.detail.xhr.status;
    const contentType = evt.detail.xhr.getResponseHeader("Content-Type");

    if (status === 422 && contentType.startsWith("text/html")) {
        // allow 422 responses to swap as we are using this as a signal that
        // a form was submitted with bad data and want to rerender with the
        // errors
        evt.detail.shouldSwap = true;

        // set isError to false to avoid error logging in console
        evt.detail.isError = false;
    }
});
