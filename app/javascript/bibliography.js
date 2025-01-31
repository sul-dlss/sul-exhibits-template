/* eslint-disable camelcase */

const Bibliography = {
  options: { toggleThreshold: 5, toggleIndex: 2 },

  init: function (el) {
    var _this = this;
    var $el = $(el);
    var data = $el.data();

    if (el.dataset.initialized) {
      const toggleButton = $el.find('.bibliography-button');
      if (toggleButton.length > 0) {
        this.bindToggleButtonHandler(toggleButton);
      }
      return;
    }

    $.getJSON(data.path, {
        'f[related_document_id_ssim][]': data.parentid,
        'f[format_main_ssim][]': 'Reference',
        sort: data.sort,
        format: 'json',
        rows: '1000'
      }, function (response) {
        var docTotal = response.data.length;
        if (docTotal > 0) {
          el.dataset.initialized = true;
          $el.show();
          var bibliographyList = $el.find('.bibliography-list');

          for (var i = 0; i < docTotal; i++) {
            var bibEntry = response.data[i];
            var html = _this.bibliographyItemTemplate(
              bibEntry, data.path, i, docTotal
            );
            bibliographyList.append(html);
          }

          if (docTotal > _this.options.toggleThreshold) {
            bibliographyList.append(_this.toggleButton());
          }
        }
    });
  },

  bibliographyItemTemplate: function(bibEntry, path, index, total) {
    var elClass = 'bibliography-body';
    var toggleIndex = this.options.toggleIndex;
    var toggleThreshold = this.options.toggleThreshold;

    if (index > toggleIndex && total > toggleThreshold) {
      elClass += ' hide-bibliography';
    }

    // This string contains the formatted bibliography for this item.
    // This string can contain HTML elements as well which should be displayed correctly.
    var formatted_bibliography = bibEntry.attributes.formatted_bibliography_ts.attributes.value;

    return '<p class="' + elClass + '">' +
              formatted_bibliography +
            ' <a href="' + bibEntry.links.self + '">' +
              '[View full reference]' +
            '</a>' +
            '</p>';
  },

  bindToggleButtonHandler: function(button) {
    button.on('click', function() {
      var bibliosToToggle = button.parent().find('.hide-bibliography');
      var hidden = bibliosToToggle.first().is(':hidden');
      bibliosToToggle.toggle();

      if(hidden) {
        button.find('[data-behavior="text"]').text('Collapse bibliography');
        button.addClass('bibliography-expanded');
      } else {
        button.find('[data-behavior="text"]').text('Expand bibliography');
        button.removeClass('bibliography-expanded');
      }
    });
  },

  toggleButton: function() {
    var button = $(
      '<button class="btn btn-primary bibliography-button">' +
        '<span data-behavior="text">Expand bibliography</span> ' +
        '<span class="bibliography-icon">»</span>' +
      '</button>'
    );

    this.bindToggleButtonHandler(button);
    return button;
  }
};

Blacklight.onLoad(function () {
  'use strict';

  $('[data-behavior="bibliography-contents"]').each(function (i, element) {
    Bibliography.init(element); // eslint-disable-line no-undef
  });
});
