# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SendPublishStateChangeNotificationJob do
  let(:job) { described_class.perform_now(exhibit: exhibit, published: published) }
  let(:exhibit) { FactoryBot.create(:exhibit) }

  context 'when publishing' do
    let(:published) { true }

    it 'sends a message indicating the exhbiti has been pusblshed' do
      allow(ExhibitBot).to receive(:message)

      job

      expect(ExhibitBot).to have_received(:message).with(
        a_hash_including(
          text: a_string_including("Spotlight exhibit published: #{exhibit.title}")
        )
      )
    end
  end

  context 'when un-publishing' do
    let(:published) { false }

    it 'indicates an item is un-published' do
      allow(ExhibitBot).to receive(:message)

      job

      expect(ExhibitBot).to have_received(:message).with(
        a_hash_including(
          text: a_string_including("Spotlight exhibit un-published: #{exhibit.title}")
        )
      )
    end
  end
end
