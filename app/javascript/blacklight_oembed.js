import oembed from 'blacklight-oembed/app/assets/javascripts/blacklight_oembed/oembed.esm'

Blacklight.onLoad(function() {
  oembed(document.querySelectorAll('[data-embed-url]'));
});