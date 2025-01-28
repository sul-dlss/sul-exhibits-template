# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'catalog/_embedded_mirador3' do
  let(:document) { SolrDocument.new(id: 'abc', iiif_manifest_url_ssi: manifest_url) }
  let(:manifest_url) { 'http://example.com/iiif/manifest' }

  before do
    without_partial_double_verification do
      allow(view).to receive_messages(
        document: document
      )
    end
  end

  it 'renders an iframe' do
    render

    expect(rendered).to have_css "iframe[src='https://embed.stanford.edu/iiif?#{{ url: manifest_url }.to_query}']"
  end

  context 'with a local IIIF manifest' do
    let(:manifest_url) { '/iiif/manifest' }

    it 'uses the full url to the manifest' do
      expected_url = 'http://test.host/iiif/manifest'

      render

      expect(rendered).to have_css "iframe[src='https://embed.stanford.edu/iiif?#{{ url: expected_url }.to_query}']"
    end
  end
end
