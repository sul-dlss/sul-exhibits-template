/* eslint-disable camelcase */
/* global Blacklight */

(function (global) {
  var RequestViewerState;

  RequestViewerState = {
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

                    console.log('Exhibits: received state:', parsedData.data);
                    let { viewers, windows, iiif_images, canvas_index } = parsedData.data;
                    if (document.querySelector('#page-2-placeholder')) document.querySelector('#page-2-placeholder').remove();
                    const viewer = Object.keys(viewers)[0];
                    const canvas_id = windows[viewer]['canvasId'];
                    const iiif_initial_viewer_config = JSON.stringify(viewers[viewer]);
                    const canvasField = document.querySelector(`#${this.formId} > input[name="item[${this.itemId}][iiif_canvas_id]"]`)
                    const configInput = document.querySelector(`#${this.formId} > input[name="item[${this.itemId}][iiif_initial_viewer_config]"]`)
                    canvasField.value = canvas_id;
                    configInput.value = iiif_initial_viewer_config;
                    document.querySelector(`#${this.formId} > input[name="item[${this.itemId}][full_image_url]"]`).value = iiif_images[0];
                    const thumbnail_size = iiif_images.length > 1 ? '!33,100' : '!100,100';
                    const thumbnail = iiif_images.map(image => image.replace('full', thumbnail_size))
                    document.querySelector(`#${this.formId} > input[name="item[${this.itemId}][thumbnail_image_url]"]`).value = thumbnail[0];
                    document.querySelector(`#${this.formId} img`).src = `${thumbnail[0]}?${new Date().getTime()}`;
                    if (thumbnail.length > 1){
                      if (!document.querySelector('#page-2')) {
                      document.querySelector(`#${this.formId} img`).insertAdjacentHTML('afterend', `<img id="page-2" src="${thumbnail[1]}?${new Date().getTime()}"/>`);
                      } else {
                        document.querySelector('#page-2').src = `${thumbnail[1]}?${new Date().getTime()}`;
                      }
                    } else if (document.querySelector('#page-2')) {
                      document.querySelector('#page-2').src = ''
                    }
                    let modal_link_element = document.querySelector(`#${this.formId} #select-image-area`);
                    let modal_link = this.updateQueryParameters(modal_link_element.href, canvas_id, iiif_initial_viewer_config);
                    const multi_page = document.querySelector('[data-current-image]');
                    if (multi_page) multi_page.innerText = canvas_index;
                    modal_link_element.href = modal_link;
                }
              }
          });
      },

      updateQueryParameters: function(url, canvas_id, iiif_initial_viewer_config) {
        const urlObj = new URL(url);
        urlObj.searchParams.set('canvas_id', canvas_id);
        urlObj.searchParams.set('iiif_initial_viewer_config', iiif_initial_viewer_config);
        return urlObj.href;
      },

      requestState: function() {
          const iframe = document.querySelector('.oembed-widget iframe, iframe.mirador-embed-wrapper');
          iframe.contentWindow.postMessage(JSON.stringify({ type: 'requestState' }), '*'); // Change '*' to a specific origin for security?
      }
  };

  global.RequestViewerState = RequestViewerState;
}(this));


Blacklight.onLoad(function () {
  'use strict';
  document.addEventListener('show.blacklight.blacklight-modal', function(event) {
    RequestViewerState.init()
  })
});