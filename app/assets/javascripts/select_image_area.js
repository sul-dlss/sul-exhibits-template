/* eslint-disable camelcase */
/* global Blacklight */

(function (global) {
  var SelectImageArea;

  SelectImageArea = {
    init: function(el) {
      this.panel = $(el);
      this.addSelectImageAreaLink();
    },

    addSelectImageAreaLink: function() {
      const target = $('[data-panel-image-pagination]', this.panel);

      const resourceId = this.panel.data('resource-id');
      const itemId = this.panel.data('id');
      const exhibit_path = this.panel.closest('form')[0].dataset.exhibitPath;
      const iiif_initial_viewer_config = $(`input[name="item[${itemId}][iiif_initial_viewer_config]"]`, this.panel)[0].value;
      const canvas_id = $(`input[name="item[${itemId}][iiif_canvas_id]"]`, this.panel)[0].value;
      let href = `${exhibit_path}/select_image_area/${resourceId}?form_id=${this.panel[0].id}&item_id=${itemId}`
      if (canvas_id != "undefined") href += `&canvas_id=${canvas_id}`
      if (iiif_initial_viewer_config && iiif_initial_viewer_config != "undefined") href += `&iiif_initial_viewer_config=${encodeURIComponent(iiif_initial_viewer_config)}`
      const selectImageAreaHtml = $(`<a id="select-image-area" data-blacklight-modal="trigger" href="${href}">Select image area</a>`);
      const image_url = this.panel[0].querySelector('img');
      if (image_url.src.includes('!33')) {
        image_url.insertAdjacentHTML('afterend', '<span id="page-2-placeholder">This section spans two pages, we can not display the thumbnail for page 2.</span>');
      }

      target.before(selectImageAreaHtml);
    }
  };

  global.SelectImageArea = SelectImageArea;
}(this));

Blacklight.onLoad(function () {
  'use strict';

  $('[data-type="solr_documents_embed"] .panels li').each(function (i, element) {
    SelectImageArea.init(element);
  });

  // for if another embed widget is added after page load
  const callback = function(mutationsList, observer) {
    for (let mutation of mutationsList) {
      if (mutation.type === 'childList') {
        mutation.addedNodes.forEach(node => {
          if (node.nodeType === 1 && node.tagName === 'LI') {
            const isEmbed = node.closest('[data-type]').dataset.type == 'solr_documents_embed';
            if (isEmbed) SelectImageArea.init(node);
          }
        });
      }
    }
  };

  document.querySelectorAll('#page-content').forEach(function(element, i) {
    const observer = new MutationObserver(callback);
    observer.observe(element, {childList: true, subtree: true});
  })
});

