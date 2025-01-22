# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Purl do
  subject(:purl) { described_class.new(druid) }

  before do
    stub_request(:get, "https://purl.stanford.edu/#{druid}.xml").to_return(
      body: File.new(File.join(FIXTURES_PATH, "#{druid}.xml")), status: 200
    )
  end

  let(:druid) { 'kj040zn0537' }

  describe '#display_names_with_roles' do
    it 'returns an array of names with role labels' do
      expect(purl.display_names_with_roles).to contain_exactly(
        { name: 'Lasinio, Carlo, 1759-1838', roles: ['Engraver'] },
        { name: 'Pellegrini, Domenico, 1759-1840', roles: ['Artist', 'Bibliographic antecedent'] },
        { name: 'Vinck, Carl de, 1859-19', roles: ['Collector'] }
      )
    end
  end
end
