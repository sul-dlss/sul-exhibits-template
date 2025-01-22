# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spotlight::Exhibit do
  describe 'exhibit extensions' do
    context 'when an exhibit is published' do
      let(:exhibit) { FactoryBot.create(:exhibit, published: false) }

      it 'kicks off a SendPublishStateChangeNotificationJob sending published = true' do
        allow(SendPublishStateChangeNotificationJob).to receive(:perform_later)

        exhibit.published = true
        exhibit.save!

        expect(SendPublishStateChangeNotificationJob).to have_received(:perform_later).with(
          a_hash_including(published: true)
        )
      end
    end

    context 'when an exhibit is un-published' do
      let(:exhibit) { FactoryBot.create(:exhibit, published: true) }

      it 'kicks off a SendPublishStateChangeNotificationJob sending published = false' do
        allow(SendPublishStateChangeNotificationJob).to receive(:perform_later)

        exhibit.published = false
        exhibit.save!

        expect(SendPublishStateChangeNotificationJob).to have_received(:perform_later).with(
          a_hash_including(published: false)
        )
      end
    end

    context 'when an the published state of an exhibit has not changed' do
      let(:exhibit) { FactoryBot.create(:exhibit, published: false) }

      it 'does not kick off a SendPublishStateChangeNotificationJob' do
        allow(SendPublishStateChangeNotificationJob).to receive(:perform_later)

        exhibit.subtitle = 'The sub-title of the exhibit'
        exhibit.save!

        expect(SendPublishStateChangeNotificationJob).not_to have_received(:perform_later)
      end
    end

    describe 'discoverable scope' do
      it 'blacklists exhibits based on their slug via config' do
        exhibit1 = create(:exhibit)
        exhibit2 = create(:exhibit)

        expect(described_class.discoverable.pluck(:slug)).to eq([exhibit1.slug, exhibit2.slug])
        allow(Settings).to receive(:nondiscoverable_exhibit_slugs).and_return([exhibit2.slug])

        expect(described_class.discoverable.pluck(:slug)).to eq([exhibit1.slug])
      end
    end
  end

  describe 'Indexing Exhibit Content' do
    context 'when an exhibit is published' do
      let(:exhibit) { FactoryBot.create(:exhibit, published: false) }

      it 'enqueues the IndexExhibitMetadataJob for adding a document' do
        exhibit.published = true

        expect do
          exhibit.save
        end.to have_enqueued_job(IndexExhibitMetadataJob).with(exhibit: exhibit, action: 'add')
      end
    end

    context 'when a published exhibit is saved' do
      let(:exhibit) { FactoryBot.create(:exhibit, published: true) }

      it 'enqueues the IndexExhibitMetadataJob for adding a document' do
        expect do
          exhibit.save
        end.to have_enqueued_job(IndexExhibitMetadataJob).with(exhibit: exhibit, action: 'add')
      end
    end

    context 'when an exhibit is unpublished' do
      let(:exhibit) { FactoryBot.create(:exhibit, published: true) }

      it 'enqueues the IndexExhibitMetadataJob for deleting a document' do
        exhibit.published = false

        expect do
          exhibit.save
        end.to have_enqueued_job(IndexExhibitMetadataJob).with(exhibit: exhibit, action: 'delete')
      end
    end

    context 'when an unpublished exhibit is saved' do
      let(:exhibit) { FactoryBot.create(:exhibit, published: false) }

      it 'enqueues the IndexExhibitMetadataJob for adding a document' do
        expect do
          exhibit.save
        end.not_to have_enqueued_job(IndexExhibitMetadataJob)
      end
    end
  end
end
