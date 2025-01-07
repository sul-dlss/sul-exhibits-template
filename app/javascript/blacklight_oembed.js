//= require 'blacklight_oembed/jquery.oembed.js'

Blacklight.onLoad(function() {
  $('[data-embed-url]').oEmbed();
});