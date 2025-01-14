# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExhibitsAttachmentUploader do
  it 'extends a class that uses CarrierWave' do
    expect(described_class.ancestors).to include(CarrierWave::Uploader::Base)
  end
end
