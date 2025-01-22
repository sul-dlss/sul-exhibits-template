# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationController do
  describe '#feature_flags' do
    before do
      allow(controller).to receive(:current_exhibit)
        .and_return(FactoryBot.create(:exhibit, slug: 'test-flag-exhibit-slug'))
    end

    it 'initializes a FeatureFlags object' do
      expect(controller.feature_flags).to be_a FeatureFlags
    end

    it 'sets current_exhibit context in the FeatureFlags object' do
      expect(controller.feature_flags.test_thing?).to be true
    end
  end
end
