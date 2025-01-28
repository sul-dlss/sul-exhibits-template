# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spotlight::CatalogController do
  include ActiveJob::TestHelper
  routes { Spotlight::Engine.routes }

  let(:exhibit) { create(:exhibit) }
  let(:user) { create(:exhibit_admin, exhibit: exhibit) }
  let(:document) { SolrDocument.new(id: '1') }
  let(:search_service) { instance_double(Blacklight::SearchService, fetch: [document]) }

  before do
    sign_in user
    allow(Blacklight::SearchService).to receive(:new).and_return(search_service)
  end

  describe '#manifest' do
    it 'sets appropriate CORS headers' do
      get :manifest, params: { id: document.id, exhibit_id: exhibit.id, locale: 'en' }

      expect(response.headers.to_h).to include 'access-control-allow-origin' => '*'
    end
  end
end
