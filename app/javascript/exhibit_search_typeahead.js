/* global Blacklight */

const ExhibitSearchTypeahead = {
  form: null,
  typeaheadElement: null,
  typeaheadElementInput: null,

  init: function (el) {
    var _this = this;
    _this.typeaheadElement = el.closest('auto-complete');
    _this.typeaheadElementInput = el;
    _this.form = el.closest('form');
    _this.preventFormSubmitOnTypeahead();

    _this.typeaheadElement.addEventListener('auto-complete-change', function(e) {
      const slug = e.relatedTarget.value;

      if (!slug) return;

      e.relatedTarget.value = _this.getTitleFromSlug(slug);
      window.location = '/' + slug;
    });
  },

  preventFormSubmitOnTypeahead: function() {
    this.form.addEventListener('submit', (e) => {
      if (document.activeElement === this.typeaheadElementInput) {
        e.preventDefault();
      }
    });
  },

  getTitleFromSlug: function(slug) {
    const option = this.typeaheadElement.querySelector(`[data-autocomplete-value="${slug}"][role="option"]`);
    return option.dataset.autocompleteTitle;
  }
};

Blacklight.onLoad(function () {
  'use strict';

  document.querySelectorAll('[data-behavior="exhibit-search-typeahead"]').forEach((element) => {
    ExhibitSearchTypeahead.init(element);
  });
});
