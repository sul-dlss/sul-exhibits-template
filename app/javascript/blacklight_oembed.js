import oembed from 'blacklight-oembed'

Blacklight.onLoad(function() {
  oembed(document.querySelectorAll('[data-embed-url]'));
});