# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Exhibit Finder API' do
  let(:exhibit) { create(:exhibit) }

  describe '#show' do
    before do
      # rubocop:disable RSpec/AnyInstance
      allow_any_instance_of(ExhibitFinder).to receive_messages(
        documents: [
          SolrDocument.new(
            id: 'abc123',
            spotlight_exhibit_slugs_ssim: [exhibit.slug],
            "exhibit_#{exhibit.slug}_public_bsi": [true]
          )
        ]
      )
      # rubocop:enable RSpec/AnyInstance
    end

    it 'returns JSON exhibit representations' do
      get '/exhibit_finder/abc123'

      json_response = JSON.parse(response.body)
      expect(json_response.length).to eq 1
      expect(json_response.first['slug']).to eq exhibit.slug
    end

    it 'has the appropriate CORS headers to be available to JS clients' do
      get '/exhibit_finder/abc123'

      expect(response.headers['Access-Control-Allow-Origin']).to eq '*'
    end
  end

  describe '#index' do
    let(:solr_connection) { double(RSolr::Client) } # rubocop:disable RSpec/VerifiedDoubles

    before do
      allow(Blacklight.default_index).to receive_messages(connection: solr_connection)

      allow(solr_connection).to receive(:select).and_return(
        'response' => { 'docs' => [{ 'exhibit_slug_ssi' => exhibit.slug }] }
      )
    end

    it 'returns JSON exhibit representations' do
      get '/exhibit_finder?q=Exhib'

      json_response = JSON.parse(response.body)
      expect(json_response.length).to eq 1
      expect(json_response.first['slug']).to eq exhibit.slug
    end

    it 'has the appropriate CORS headers to be available to JS clients' do
      get '/exhibit_finder?q=Exhib'

      expect(response.headers['Access-Control-Allow-Origin']).to eq '*'
    end
  end
end
