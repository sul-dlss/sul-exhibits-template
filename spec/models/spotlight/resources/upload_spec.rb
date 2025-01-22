# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spotlight::Resources::Upload do
  subject(:resource) { described_class.create! exhibit: exhibit, upload: upload }

  let(:exhibit) { create(:exhibit) }
  let(:upload_id) { 123 }
  let(:upload) { Spotlight::FeaturedImage.new(id: upload_id) }
  let(:riiif_image) do
    instance_double(Riiif::Image, info: instance_double(Riiif::ImageInformation, width: 5, height: 5))
  end
  let(:solr_doc) { indexed_documents(resource).first&.with_indifferent_access }

  before do
    allow(Riiif::Image).to receive(:new).with(upload_id).and_return(riiif_image)
    allow(upload).to receive(:file_present?).and_return(true) if upload
  end

  describe '#to_solr' do
    it 'adds a square thumbnail field' do
      expect(solr_doc).to include thumbnail_square_url_ssm: "/images/#{upload_id}/square/100,100/0/default.jpg"
    end

    it 'adds a large image field' do
      expect(solr_doc).to include large_image_url_ssm: "/images/#{upload_id}/full/!1000,1000/0/default.jpg"
    end

    it 'copies over the uploaded date field to pub_year fields' do
      resource.sidecar.update data: {
        'configured_fields' => { 'spotlight_upload_date_tesim' => 'this is a year: 2014' }
      }

      expect(solr_doc).to include pub_year_tisim: 2014, pub_year_w_approx_isi: 2014, pub_year_isi: 2014
    end
  end

  context 'upload item with no thumbnail' do
    let(:upload) { nil }

    describe '#to_solr' do
      it 'does not have custom thumbnail fields' do
        expect(solr_doc).not_to include :thumbnail_square_url_ssm, :large_image_url_ssm
      end
    end
  end
end
