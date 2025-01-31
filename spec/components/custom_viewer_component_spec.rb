# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CustomViewerComponent, type: :component do
  let(:component) { described_class.new(document:, presenter:) }
  let(:presenter) { double }
  let(:exhibit) { create(:exhibit) }
  let(:manifest_url) { 'http://example.com/iiif/manifest' }

  before do
    exhibit.required_viewer.viewer_type = 'mirador3'
    exhibit.required_viewer.save
    with_request_url "/#{exhibit.slug}/catalog/cf101bh9631" do
      render_inline(component)
    end
  end

  context 'with external_iiif resource' do
    let(:document) do
      SolrDocument.new(id: 'abc', iiif_manifest_url_ssi: manifest_url,
                       spotlight_resource_type_ssim: ['spotlight/resources/iiif_harvesters'])
    end

    it 'renders the component' do
      expect(page).to have_css "iframe[src='https://embed.stanford.edu/iiif?#{{ url: manifest_url,
                                                                                iiif_initial_viewer_config: '',
                                                                                canvas_id: '' }.to_query}']"
    end
  end
end
