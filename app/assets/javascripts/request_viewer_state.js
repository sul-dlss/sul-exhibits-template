/* eslint-disable camelcase */
/* global RequestViewerState */

(function (global) {
  const RequestViewerState = {
      init: function() {
        this.setupIframeMessageListener();
        this.setupRequestButton();
        $('[data-embed-url]').oEmbed();
      },

      setupRequestButton: function() {
        document.querySelector('#request-state').addEventListener('click', (event) => {
          this.formId = event.target.dataset.formId;
          this.itemId = event.target.dataset.itemId;
          this.requestState();
        });
      },

      setupIframeMessageListener: function() {
          window.addEventListener('message', (event) => {
              if (event && event.data) {
                // avoid development issues
                if (event.data == "recaptcha-setup" || event.data.source == "react-devtools-content-script") { return; }
                let parsedData;
                try {
                    parsedData = typeof event.data === 'string' ? JSON.parse(event.data) : event.data;
                } catch (error) {
                    console.error('Failed to parse event data:', error);
                    return; // Exit if parsing fails
                }

                if (parsedData.type === "stateResponse" && parsedData.source === "sul-embed-m3") {
                  this.updateForm(parsedData.data);
                }
              }
          });
      },

      updateForm: function(data) {
        console.log('Exhibits: received state:', data);
        let { viewers, windows, iiif_images, canvas_index } = data;
        if (document.querySelector('#page-2-placeholder')) document.querySelector('#page-2-placeholder').remove();
        const viewer = Object.keys(viewers)[0];
        const canvasId = windows[viewer]['canvasId'];
        const iiifInitialViewerConfig = JSON.stringify(viewers[viewer]);
        const formNode = document.getElementById(this.formId);
        const canvasField = formNode.querySelector(`input[name="item[${this.itemId}][iiif_canvas_id]"]`)
        const configInput = formNode.querySelector(`input[name="item[${this.itemId}][iiif_initial_viewer_config]"]`)
        canvasField.value = canvasId;
        configInput.value = iiifInitialViewerConfig;
        formNode.querySelector(`input[name="item[${this.itemId}][full_image_url]"]`).value = iiif_images[0];
        const thumbnailSize = iiif_images.length > 1 ? '!33,100' : '!100,100';
        const thumbnail = iiif_images.map(image => image.replace('full', thumbnailSize))
        formNode.querySelector(`input[name="item[${this.itemId}][thumbnail_image_url]"]`).value = thumbnail[0];
        formNode.querySelector('img').src = `${thumbnail[0]}?${new Date().getTime()}`;
        if (thumbnail.length > 1){
          if (!document.querySelector('#page-2')) {
            formNode.querySelector('img').insertAdjacentHTML('afterend', `<img id="page-2" src="${thumbnail[1]}?${new Date().getTime()}"/>`);
          } else {
            document.querySelector('#page-2').src = `${thumbnail[1]}?${new Date().getTime()}`;
          }
        } else if (document.querySelector('#page-2')) {
          document.querySelector('#page-2').src = ''
        }
        let modalLinkElement = formNode.querySelector('#select-image-area');
        let modalLink = this.updateQueryParameters(modalLinkElement.href, canvasId, iiifInitialViewerConfig);
        const multiPage = document.querySelector('[data-current-image]');
        if (multiPage) multiPage.innerText = canvas_index;
        modalLinkElement.href = modalLink;
      },

      updateQueryParameters: function(url, canvasId, iiifInitialViewerConfig) {
        const urlObj = new URL(url);
        urlObj.searchParams.set('canvas_id', canvasId);
        urlObj.searchParams.set('iiif_initial_viewer_config', iiifInitialViewerConfig);
        return urlObj.href;
      },

      requestState: function() {
        const iframe = document.querySelector('.oembed-widget iframe, iframe.mirador-embed-wrapper');
        iframe.contentWindow.postMessage(JSON.stringify({ type: 'requestState' }), '*'); // Change '*' to a specific origin for security?
      }
  };

  global.RequestViewerState = RequestViewerState;
}(this));


document.addEventListener('loaded.blacklight.blacklight-modal', function() {
  if (document.querySelector('#request-state')) RequestViewerState.init()
})