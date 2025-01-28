# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spotlight::Resources::IiifManifest do
  let(:manifest) do
    {
      'thumbnail' => {
        '@id' => 'www.example.com/iiif/full/!400,400/0/default.jpg',
        'service' => {
          'profile' => 'http://iiif.io/api/image/2/level2.json',
          '@id' => 'www.example.com/iiif'
        }
      }
    }
  end

  let(:iiif_manifest_resource) { described_class.new }

  describe '#add_thumbnail_url' do
    it 'adds in the exhibits custom field thumbnail_square_url_ssm' do
      expect(iiif_manifest_resource).to receive_messages(
        thumbnail_field: 'thumbnail_field',
        manifest: manifest
      )
      iiif_manifest_resource.add_thumbnail_url

      expect(iiif_manifest_resource.send(:solr_hash)).to include(
        'thumbnail_field' => 'www.example.com/iiif/full/!400,400/0/default.jpg',
        large_image_url_ssm: 'www.example.com/iiif/full/!1000,1000/0/default.jpg',
        thumbnail_square_url_ssm: 'www.example.com/iiif/full/100,100/0/default.jpg'
      )
    end

    context 'no thumbnail manifest' do
      let(:manifest) do
        IIIF::Service.from_ordered_hash(
          '@type' => 'sc:Manifest',
          'sequences' => [
            {
              '@type' => 'sc:Sequence',
              'canvases' => [
                {
                  '@type' => 'sc:Canvas',
                  'images' => [
                    {
                      'resource' => {
                        'service' => {
                          'profile' => 'http://iiif.io/api/image/2/level2.json',
                          '@id' => 'www.example.com/iiif/1v'
                        }
                      }
                    }
                  ]
                }
              ]
            }
          ]
        )
      end

      it 'uses the first canvas as a thumbnail' do
        expect(iiif_manifest_resource).to receive_messages(
          thumbnail_field: 'thumbnail_field',
          manifest: manifest
        )
        iiif_manifest_resource.add_thumbnail_url

        expect(iiif_manifest_resource.send(:solr_hash)).to include(
          'thumbnail_field' => 'www.example.com/iiif/1v/full/!400,400/0/default.jpg',
          thumbnail_square_url_ssm: 'www.example.com/iiif/1v/full/100,100/0/default.jpg'
        )
      end
    end
  end
end
