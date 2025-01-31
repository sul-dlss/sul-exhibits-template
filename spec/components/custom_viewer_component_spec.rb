# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CustomViewerComponent, type: :component do
  let(:component) { described_class.new(document:, presenter:, block_context:) }
  let(:presenter) { double }
  let(:block_context) { nil }
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
      expect(page).to have_css "iframe[src='https://embed.stanford.edu/iiif?#{{ url: manifest_url }.to_query}']"
    end
  end

  describe '#choose_canvas_id' do
    subject(:choose_canvas_id) { component.choose_canvas_id }

    let(:document) do
      SolrDocument.new(id: 'abc')
    end
    let(:component) { described_class.new(document:, presenter:, block_context:) }

    context 'with a valid SirTrevor Block' do
      let(:canvas_index) { 4 }
      let(:block_context) do
        instance_double(
          SirTrevorRails::Blocks::SolrDocumentsEmbedBlock,
          items: [{ 'iiif_canvas_id' => "http://example.com/ab123cd4567_#{canvas_index}" }]
        )
      end

      it 'returns the selected iiif_canvas_id from the block' do
        expect(choose_canvas_id).to eq "http://example.com/ab123cd4567_#{canvas_index}"
      end
    end

    context 'with SirTrevorBlock that is missing things' do
      let(:block_context) do
        instance_double(SirTrevorRails::Blocks::SolrDocumentsEmbedBlock)
      end

      it 'defaults to nil' do
        expect(choose_canvas_id).to be_nil
      end
    end
  end
end
