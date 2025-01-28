# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Index Statuses' do
  let(:exhibit) { create(:exhibit) }
  let(:user) { nil }
  let(:resource) { DorHarvester.create(exhibit: exhibit) }

  before do
    sign_in user

    5.times do |i|
      Spotlight::SolrDocumentSidecar.create(
        exhibit: exhibit,
        resource: resource,
        document: SolrDocument.new(id: "abc#{i}"),
        index_status: { ok: true }
      )
    end
  end

  context 'for an exhibit admin' do
    let(:user) { create(:exhibit_admin, exhibit: exhibit) }

    describe '#show' do
      it "renders json including details about the item's indexing status" do
        get "/#{exhibit.slug}/dor_harvester/index_statuses/abc1"

        response_json = JSON.parse(response.body)
        expect(response_json['id']).to eq 'abc1'
        expect(response_json['status']).to eq('ok' => true)
      end

      it 'raises a not found error when the document id does not exist' do
        get "/#{exhibit.slug}/dor_harvester/index_statuses/not-a-real-id"
        expect(response).to have_http_status :not_found
      end
    end

    describe '#index' do
      it 'renders a json artray of all the document ids, filtered by a q parameter' do
        get "/#{exhibit.slug}/dor_harvester/index_statuses?q=abc"

        response_json = JSON.parse(response.body)
        expect(response_json.length).to eq 5
        expect(response_json.first).to eq 'abc0'
        expect(response_json.last).to eq 'abc4'

        get "/#{exhibit.slug}/dor_harvester/index_statuses?q=3"

        response_json = JSON.parse(response.body)
        expect(response_json).to eq(['abc3'])
      end
    end
  end

  context 'for an anonymous user' do
    let(:user) { create(:user) }

    describe '#show' do
      it do
        expect do
          get "/#{exhibit.slug}/dor_harvester/index_statuses/abc1"
        end.to raise_error(CanCan::AccessDenied)
      end
    end

    describe '#index' do
      it do
        expect do
          get "/#{exhibit.slug}/dor_harvester/index_statuses?q=abc"
        end.to raise_error(CanCan::AccessDenied)
      end
    end
  end
end
