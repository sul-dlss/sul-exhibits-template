# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OembedDefaultComponent, type: :component do
  let(:component) { described_class.new(document:, canvas:, block:) }
  let(:canvas) { 3 }
  let(:block) { nil }
  let(:uat_embed) { false }
  let(:search_context) { nil }

  let(:rendered) do
    with_controller_class CatalogController do
      allow(vc_test_controller.feature_flags).to receive(:uat_embed?).and_return(uat_embed)
      vc_test_controller.params[:search_context] = search_context
      render_inline(component)
    end
  end

  describe '#custom_render_oembed_tag_async' do
    let(:document) { SolrDocument.new(url_fulltext: ['http://example.com/stuff'], druid: 'abc123') }
    let(:data_embed_url) { rendered.css('[data-embed-url]').attribute('data-embed-url').value }

    it 'renders a div with embed attribute and canvas index param' do
      expect(data_embed_url).to eq 'http://test.host/oembed/embed?canvas_id=3&maxheight=600&url=http%3A%2F%2Fexample.com%2Fstuff'
    end

    context 'with current_search_session' do
      let(:search_context) { JSON.dump({ q: 'The Query' }) }

      it 'uses the q from the current_search_session to populate the suggested_search param' do
        expect(data_embed_url).to include('&suggested_search=The+Query&')
      end
    end

    context 'with a SirTrevor block' do
      let(:block) { instance_double('SirTrevor::Block', maxheight: 300) } # rubocop:disable RSpec/VerifiedDoubleReference

      it 'passes the maxheight from the block parameter' do
        expect(data_embed_url).to eq 'http://test.host/oembed/embed?canvas_id=3&maxheight=300&url=http%3A%2F%2Fexample.com%2Fstuff'
      end
    end

    context 'with an exhibit that is configured (via feature flag) to point to UAT' do
      let(:uat_embed) { true }

      it 'renders a div with the correct embed end-point in the data attribute' do
        expect(data_embed_url).to eq 'http://test.host/oembed/embed?canvas_id=3&maxheight=600&url=https%3A%2F%2Fsul-purl-uat.stanford.edu%2Fabc123'
      end
    end
  end
end
