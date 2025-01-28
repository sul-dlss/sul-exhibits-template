# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FeatureFlags do
  subject(:feature_flags) { described_class.new(settings).for(exhibit) }

  let(:exhibit) { create(:exhibit) }
  let(:settings) do
    OpenStruct.new.tap do |os|
      os.true_thing = true
      os.false_thing = false
      os.other_thing = false
      os.exhibit_slug = OpenStruct.new(other_thing: true)
    end
  end

  describe 'setting accessors' do
    it 'has accessors for settings that add a "?"' do
      expect(feature_flags.true_thing?).to be true
      expect(feature_flags.false_thing?).to be false
      expect(feature_flags.other_thing?).to be false
    end

    it 'throws a NoMethodError if a non-existing flag is requested' do
      expect { feature_flags.utter_nonsense? }.to raise_error(NoMethodError)
    end
  end

  describe 'exhibit-specific accessors' do
    before { exhibit.slug = 'exhibit_slug' }

    it 'responds to missing settings with the base setting' do
      expect(feature_flags.true_thing?).to be true
      expect(feature_flags.false_thing?).to be false
    end

    it 'overrides settings when defined within an exhibit context' do
      expect(feature_flags.other_thing?).to be true
    end
  end

  describe '#for' do
    it 'sets flags if exhibit specific flags are avilable' do
      flags = described_class.new(settings).flags
      expect(flags).to respond_to(:true_thing)

      exhibit.slug = 'exhibit_slug'
      flags = described_class.new(settings).for(exhibit).flags
      expect(flags).not_to respond_to(:true_thing)
    end

    it 'returns an instance self' do
      expect(described_class.for).to be_a described_class
    end

    it 'throws an ArgumentError when the exhibit is not a nil, a string, or an exhibit like object' do
      expect { described_class.for(['foo']) }.to raise_error(ArgumentError)
    end
  end
end
