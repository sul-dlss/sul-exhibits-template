# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EmbeddedMiradorComponent, type: :component do
  let(:component) { described_class.new(document:, block:) }
  let(:document) { SolrDocument.new(id: 'abc', iiif_manifest_url_ssi: manifest_url) }
  let(:sir_trevor_block) { Struct.new(:maxheight, :item) }
  let(:block) { sir_trevor_block.new(item:) }
  let(:manifest_url) { 'http://example.com/iiif/manifest' }

  before do
    render_inline(component)
  end

  context 'does not have a sir trevor block' do
    let(:item) { nil }

    it 'renders an iframe' do
      expect(page).to have_css "iframe[src='https://embed.stanford.edu/iiif?#{{ url: manifest_url,
                                                                                iiif_initial_viewer_config: '',
                                                                                canvas_id: '' }.to_query}']"
    end

    context 'with a local IIIF manifest' do
      let(:manifest_url) { '/iiif/manifest' }

      it 'uses the full url to the manifest' do
        expected_url = 'http://test.host/iiif/manifest'

        expect(page).to have_css "iframe[src='https://embed.stanford.edu/iiif?#{{ url: expected_url,
                                                                                  iiif_initial_viewer_config: '',
                                                                                  canvas_id: '' }.to_query}']"
      end
    end
  end

  context 'has a sir trevor block' do
    let(:canvas_id) { 'canvas_id' }
    let(:iiif_initial_viewer_config) { { x: 0, y: 100 } }
    let(:item) { [{ 'iiif_canvas_id' => canvas_id, 'iiif_initial_viewer_config' => iiif_initial_viewer_config }] }

    it 'renders an iframe' do
      expect(page).to have_css "iframe[src='https://embed.stanford.edu/iiif?#{{ url: manifest_url,
                                                                                iiif_initial_viewer_config:,
                                                                                canvas_id: }.to_query}']"
    end

    context 'with a local IIIF manifest' do
      let(:manifest_url) { '/iiif/manifest' }

      it 'uses the full url to the manifest' do
        expected_url = 'http://test.host/iiif/manifest'

        expect(page).to have_css "iframe[src='https://embed.stanford.edu/iiif?#{{ url: expected_url,
                                                                                  iiif_initial_viewer_config:,
                                                                                  canvas_id: }.to_query}']"
      end
    end
  end
end
