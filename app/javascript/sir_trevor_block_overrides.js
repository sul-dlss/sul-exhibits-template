SirTrevor.Blocks.SolrDocumentsEmbed = (function(){
  return SirTrevor.Blocks.SolrDocumentsEmbed.extend({
    item_options: function() {
      const formId = this.formId("maxheight");
      return [
        `<label for="${formId}">Maximum height of viewer (in pixels)</label>`,
        `<input id="${formId}" type="number" class="form-control" placeholder="600" name="maxheight" />`
      ].join(' ');
    }
  });
})();

// work around for https://bugs.chromium.org/p/chromium/issues/detail?id=1262589&q=contenteditable&can=1
if (navigator.userAgentData && navigator.userAgentData.brands &&
    Boolean(navigator.userAgentData.brands.find(function(b) { return b.brand === 'Chromium' && parseFloat(b.version, 10) >= 95 && parseFloat(b.version, 10) < 97; }))) {
  SirTrevor.Blocks.Text.prototype.editorHTML = "<div class=\"st-text-block\" spellcheck=\"false\" contenteditable=\"true\"></div>";
}

// Override the alt text link url so it goes to Stanford's guidelines
SirTrevor.Locales.en.blocks.alt_text_guidelines = $.extend(SirTrevor.Locales.en.blocks.alt_text_guidelines, {
  link_url: 'https://uit.stanford.edu/accessibility/concepts/images' 
});
