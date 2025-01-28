# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExhibitBot do
  let(:bot) { described_class.new }

  context 'when notifications are configured' do
    let(:stub_client) { instance_spy('Slack::Web::Client') }

    before do
      allow(bot).to receive_messages(client: stub_client)
    end

    describe '#message' do
      subject(:message) { bot.message(text: 'Test text') }

      it 'sends text through to the client' do
        message
        expect(stub_client).to have_received(:chat_postMessage).with(hash_including(text: 'Test text'))
      end

      it 'allows defaults to be overridden' do
        bot.message(text: 'Test text', channel: '#new-channel', as_user: false)

        expect(stub_client).to have_received(:chat_postMessage).with(
          hash_including(channel: '#new-channel', as_user: false)
        )
      end

      it 'has a default channel and as_user option' do
        message
        expect(stub_client).to have_received(:chat_postMessage).with(
          hash_including(channel: '#spotlight-service-team', as_user: true)
        )
      end
    end
  end

  describe 'ExhibitBot::NullClient' do
    it 'is returned when slack notification are not configured' do
      expect(bot.send(:client)).to be_a ExhibitBot::NullClient
    end
  end
end
