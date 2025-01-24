/* global Blacklight */

const CitedDocuments = {
  init: function (el) {
    var $el = $(el);
    const citedDocList = $el.find('.cited-documents-list');
    // Prevent repeat script run on page back
    if (citedDocList[0].innerHTML != '') return;

    var data = $el.data();
    var queryIds = data.documentids.join(' ');


    $.post(data.path, {
      ids: queryIds,
      format: 'json',
    }, function (response) {
      response.forEach(function(citedDocEntry) {
        var html = '<li class="cited-documents-body">' +
              ' <a href="' + citedDocEntry['id'] + '">' +
              citedDocEntry['title_display'] +
              '</a>' +
              '</li>';
        citedDocList.append(html);
      });
    });
  }
};

Blacklight.onLoad(function () {
  'use strict';

  $('[data-behavior="cited-documents-contents"]').each(function (i, element) {
    CitedDocuments.init(element); // eslint-disable-line no-undef
  });
});
