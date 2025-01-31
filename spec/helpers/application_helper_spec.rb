# frozen_string_literal: true

require 'rails_helper'

describe ApplicationHelper do
  describe '#collection_title' do
    it 'unmangles the collection title from the compound field' do
      expect(helper.collection_title('foo-|-bar')).to eq 'bar'
    end
  end

  describe '#collection_title_for_index_field' do
    it 'unmangles the collection title from the compound field' do
      expect(helper.document_collection_title(value: 'foo-|-bar')).to eq 'bar'
    end

    it 'handles multivalued fields' do
      expect(helper.document_collection_title(value: ['foo-|-bar', 'baz-|-bop'])).to eq 'bar and bop'
    end
  end

  describe '#split_on_white_space' do
    let(:mods_values) do
      ModsDisplay::Values.new(
        label: 'Abstract:',
        values: ["Tariffs and Trade.\r\n\r\nThe purpose ofGATT secretariat.\r\n\r\nThe Bibliography"]
      )
    end

    it 'splits values on embedded whitespace (based off of bc777tp9978)' do
      expect(helper.split_on_white_space(mods_values.values).length).to eq 5
    end
  end
end
