# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Canvas Display' do
  let(:exhibit) { create(:exhibit, slug: 'default-exhibit') }

  let(:canvas_data) { JSON.parse(File.read('spec/fixtures/iiif/fh878gz0315-canvas-521.json')) }
  let(:annolist_file) { File.read('spec/fixtures/iiif/fh878g0315-text-f254r.json') }
  let(:annolist_url) { canvas_data['otherContent'].first['@id'] }
  let(:document_id) { "canvas-#{Digest::MD5.hexdigest(canvas_data['@id'].to_s)}" }

  before :all do
    ActiveJob::Base.queue_adapter = :inline # block until indexing has committed
  end

  before do
    allow(Faraday).to receive(:get).with(annolist_url).and_return(
      instance_double(Faraday::Response, body: annolist_file)
    )

    canvas = CanvasResource.new(data: canvas_data, exhibit: exhibit)
    canvas.save_and_index

    visit spotlight.exhibit_solr_document_path(exhibit_id: exhibit.slug, id: document_id)
  end

  after :all do
    ActiveJob::Base.queue_adapter = :test # restore
  end

  it 'renders the page details section' do
    within('.record-metadata-section') do
      expect(page).to have_css('h3', text: 'Page details')

      expect(page).to have_css('ul li', count: '26') # there are 26 valid annotations in the fixture
      expect(page).to have_css('ul li', text: 'mid mycelre arweor')
    end
  end
end
