# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'catalog/_bibliography_buttons_default' do
  let(:document) { SolrDocument.new(format_main_ssim: 'Reference', bibtex_key_ss: url) }

  before do
    assign(:document, document)
    render
  end

  context 'with a valid Zotero URL' do
    let(:url) { 'http://Zotero.ORG/groups/1051392/items/QTWBAWKX' }

    it 'renders a View on Zotero site button' do
      expect(rendered).to have_css("a.btn-view-on-zotero[href=\"#{url}\"]", text: 'View on Zotero site')
    end
  end

  context 'with a regular BibTeX key' do
    let(:url) { 'smith_2010' }

    it 'skips button' do
      expect(rendered).not_to have_css('a.btn-view-on-zotero')
    end
  end

  context 'without a URL' do
    let(:url) { nil }

    it 'skips button' do
      expect(rendered).not_to have_css('a.btn-view-on-zotero')
    end
  end
end
