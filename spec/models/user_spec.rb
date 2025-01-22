# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User do
  subject { create(:user) }

  describe '#shibboleth_groups=' do
    it 'splits groups on the pipe character' do
      subject.shibboleth_groups = 'a;b;c'
      expect(subject.groups).to match_array %w(a b c)
    end
  end

  describe '#add_default_roles' do
    it 'does not inject the administrative role' do
      expect(subject).not_to be_a_superadmin
    end
  end

  describe '#to_s' do
    it 'returns #email' do
      expect(subject.to_s).to eq subject.email
    end
  end
end
