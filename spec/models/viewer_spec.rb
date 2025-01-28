# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Viewer do
  let(:viewer) { create(:viewer) }

  it 'belongs to an exhibit' do
    expect(described_class.reflect_on_association(:exhibit).macro).to eq :belongs_to
  end

  it 'has the correct partial path based on viewer_type' do
    viewer.viewer_type = 'sul-embed'
    expect(viewer.to_partial_path).to eq 'oembed_default'
    viewer.viewer_type = 'mirador'
    expect(viewer.to_partial_path).to eq '/viewers/mirador3'
    viewer.viewer_type = nil
    expect(viewer.to_partial_path).to eq 'oembed_default'
  end
end
