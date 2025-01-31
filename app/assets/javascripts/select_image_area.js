/* eslint-disable camelcase */
/* global Blacklight */

(function (global) {
  const SelectImageArea = {
    init: function(el) {
      this.panel = el;
      this.addSelectImageAreaLink();
    },

    addSelectImageAreaLink: function() {
      const target = this.panel.querySelector('[data-panel-image-pagination]');
      const resourceId = this.panel.dataset['resourceId'];
      const itemId = this.panel.dataset['id'];
      const exhibitPath = this.panel.closest('form').dataset.exhibitPath;
      const imageUrl = this.panel.querySelector('img');

      // for uploaded images, we don't want to display the select image area link
      const fullImageUrl = this.panel.querySelector(`input[name="item[${itemId}][full_image_url]"]`);
      if (!fullImageUrl.value || !fullImageUrl.value.includes('http')) return;

      const iiifInitialViewerConfig = this.panel.querySelector(`input[name="item[${itemId}][iiif_initial_viewer_config]"]`).value;
      const canvasId = this.panel.querySelector(`input[name="item[${itemId}][iiif_canvas_id]"]`).value;
      let href = `${exhibitPath}/select_image_area/${resourceId}?form_id=${this.panel.id}&item_id=${itemId}`
      if (canvasId != "undefined") href += `&canvas_id=${canvasId}`
      if (iiifInitialViewerConfig && iiifInitialViewerConfig != "undefined") href += `&iiif_initial_viewer_config=${iiifInitialViewerConfig}`
      const selectImageAreaHtml = document.createElement('a')
      selectImageAreaHtml.id = "select-image-area"
      selectImageAreaHtml.setAttribute('data-blacklight-modal', 'trigger')
      selectImageAreaHtml.href = href
      selectImageAreaHtml.innerHTML = 'Select image area'
      if (imageUrl.src.includes('!33')) {
        imageUrl.insertAdjacentHTML('afterend', '<span id="page-2-placeholder">This section spans two pages, we can not display the thumbnail for page 2.</span>');
      }

      target.parentNode.insertBefore(selectImageAreaHtml, target);
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

  const editPageElement = document.getElementById('page-content');
  if (editPageElement) {
    const observer = new MutationObserver(callback);
    observer.observe(editPageElement, {childList: true, subtree: true});
  }
});

