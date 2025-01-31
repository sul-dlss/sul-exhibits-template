/* global Blacklight */

const NestedRelatedItems = {
  options: { itemSelector: 'li.mods_display_nested_related_item' },
  init: function (el) {
    var _this = this;
    var listItems = _this.listItems(el);
    listItems.each(function() {
      $(this).removeClass('open');
      _this.addToggleLink($(this));
    });

    if (listItems.has('dl').length > 0) {
      _this.addToggleAll(el);
    }
  },

  listItems: function(list) {
    return list.find(this.options.itemSelector);
  },

  addToggleAll: function(content) {
    // find the preceding <dt>
    var title = $(content).parents('dd').prev();
    var el = $('<a href="javascript:;" class="toggleAll mods_display_related_item_label">Expand all</a>');
    this.toggleAll(el, content);
    title.append(el);
  },

  addToggleLink: function(content) {
    var dl = content.find('dl');

    if(dl.length > 0) {
      // Hide and remove the dl (so we can deal with just the text below)
      dl.hide();
      dl.detach();
      // Replace the content of the list item
      // with the current text wrapped in a link
      content.html(this.linkElement(content));
      // Add the dl back in
      content.append(dl);
    }
  },

  linkElement: function(content) {
    var _this = this;
    var link = $('<a href="javascript:;">' + content.text() + '</a>');
    link.on('click', function() {
      _this.toggleMetadata($(this));
    });

    return link;
  },

  toggleAll: function(el, content) {
    var _this = this;
    el.on('click', function(){
      var toggleLink  = $(this);
      toggleLink.toggleClass('open');
      toggleLink.text((toggleLink.text() == 'Collapse all') ? 'Expand all' : 'Collapse all');
      var links =  _this.listItems(content);

      // Handle mixed lists of open / closed items
      if (toggleLink.hasClass('open')){
        links = links.not('.open').find('a');
      } else {
        links = links.filter($('.open')).find('a');
      }
      links.each(function(){
        _this.toggleMetadata($(this));
      });
    });
  },

  toggleMetadata: function(item) {
    var listItem = item.parent('li');
    listItem.toggleClass('open');
    listItem.find('dl').toggle();
  }
};

Blacklight.onLoad(function () {
  'use strict';

  // Load JS in Bootstrap modal
  document.querySelector('#blacklight-modal').addEventListener('loaded.blacklight.blacklight-modal', function (e) {
    $('.mods_display_nested_related_items').each(function (i, element) {
      NestedRelatedItems.init($(element)); // eslint-disable-line no-undef
    });
  });

  // Metadata page
  $('.mods_display_nested_related_items').each(function (i, element) {
    NestedRelatedItems.init($(element)); // eslint-disable-line no-undef
  });
});
