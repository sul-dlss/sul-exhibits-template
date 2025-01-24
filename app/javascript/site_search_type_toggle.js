/* global Blacklight */

const SiteSearchTypeToggle = {
  menuOptions: [],
  init: function (el) {
    var _this = this;
    var button = el.find('button.dropdown-toggle');
    var menuItems = el.find('.dropdown-menu .dropdown-item');
    _this.menuOptions = $('[data-behavior="site-search-type"]');
    _this.hideAllMenuOptions();
    el.show();

    $(el.data('enabled')).show();

    menuItems.each(function() {
      $(this).on('click', function(e) {
        e.preventDefault();

        _this.hideAllMenuOptions();
        $($(this).data('bs-target')).show();

        button.text($(this).data('buttonText'));
      });
    });
  },

  hideAllMenuOptions: function() {
    this.menuOptions.each(function() {
      $(this).hide();
    });
  }
};

Blacklight.onLoad(function () {
  'use strict';

  $('[data-behavior="site-search-type-toggle"]').each(function (i, element) {
    SiteSearchTypeToggle.init($(element)); // eslint-disable-line no-undef
  });
});
