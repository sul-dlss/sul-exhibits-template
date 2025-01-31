/* global Blacklight */

const IndexStatusTypeahead = {
  itemStatusRemoteUrl: null,

  indexStatusTable: function() {
    return $('[data-behavior="index-status-typeahead-table"]');
  },

  init: function (el) {
    var _this = this;
    const completer = el.closest('auto-complete');
    _this.itemStatusRemoteUrl = completer.dataset.typeaheadRemoteUrl;

    completer.addEventListener('submit', function(e) {
      e.preventDefault();
    });

    completer.addEventListener('auto-complete-change', function(e) {
      const option = completer.querySelector(`[data-autocomplete-value="${e.relatedTarget.value}"][role="option"]`);
      if (option) {
        _this.addIndexStatusRow(option.dataset.autocompleteValue);
      }
    });
  },

  addIndexStatusRow: function(druid) {
    if(this.indexStatusRow(druid).length > 0) {
      return; // Return if there is already an index status row present
    }

    this.indexStatusTable().show(); // Ensure the table is shown
    this.indexStatusTable().find('tbody').append(
      [
        '<tr data-index-status-id="' + druid + '">',
          '<td>' + druid + '</td>',
          '<td data-behavior="index-item-status"></td>',
        '</tr>'
      ].join('\n')
    );

    this.updateItemIndexStatus(druid);
  },

  // Getter for an index status row given a druid
  indexStatusRow: function(druid) {
    return $('tr[data-index-status-id="' + druid + '"]');
  },

  updateItemIndexStatus: function(druid) {
    var _this = this;
    $.ajax({ url: _this.itemStatusRemoteUrl + '/' + druid })
      .done(function(data) {
        var row = _this.indexStatusRow(druid);

        if (!data.status.ok) {
          row.addClass('danger');
        }

        var itemStatusCell = row.find('td[data-behavior="index-item-status"]');
        itemStatusCell.text(
          data.status.ok ? 'Published' : data.status.message
        );
    });
  },

  druids: function() {
    return $('[data-index-status-content]').data('index-status-content');
  },
};

Blacklight.onLoad(function () {
  'use strict';

  document.querySelectorAll('[data-behavior="index-status-typeahead"]').forEach((element) => {
    IndexStatusTypeahead.init(element); // eslint-disable-line no-undef
  });
});
