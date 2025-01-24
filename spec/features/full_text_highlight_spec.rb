# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Full text highlighting' do
  let(:exhibit) { create(:exhibit) }
  let(:dor_harvester) { DorHarvester.new(druid_list: druid, exhibit: exhibit) }
  let(:user) { create(:exhibit_admin, exhibit: exhibit) }

  before do
    allow(Spotlight::Engine.config).to receive(:filter_resources_by_exhibit).and_return(false)

    # Enable the full text field for display
    sign_in user
    visit spotlight.edit_exhibit_metadata_configuration_path(exhibit)
    page.find('#blacklight_configuration_index_fields_full_text_tesimv_list').click
    click_button 'Save changes'
    page.find_button('Save changes', disabled: false) # Wait for the changes to be saved/that we're on the next page.
    sign_out user
  end

  context 'when a document has a full text highlight hit', js: true do
    it 'shows the full-text hightlight field and provides a toggle' do
      visit spotlight.search_exhibit_catalog_path(exhibit, q: 'structure')

      expect(page).to have_css('dt', text: 'Sample matches in document text')

      expect(page).not_to have_css('dd p', text: 'about need for data structures capable of storing', visible: :visible)
      page.find('dt', text: 'Sample matches in document text').click
      expect(page).to have_css('dd p', text: 'about need for data structures capable of storing', visible: :visible)
    end

    it 'pulls the prepared-search-link link from the full text snippet section to a new dt' do
      visit spotlight.search_exhibit_catalog_path(exhibit, q: 'structure')

      expect(page).to have_css('dt a', text: 'Search for "structure" in document text', visible: :visible)
      expect(page).not_to have_css('dd a', text: 'Search for "structure" in document text') # Original link location
      page.find('dt', text: 'Sample matches in document text').click
      expect(page).not_to have_css('dd a', text: 'Search for "structure" in document text') # Original link location
    end
  end

  context 'when a document has full text but there is no highlight', js: true do
    it 'still offers a link to open up the document with a search prepared (and does not have a highlight section)' do
      visit spotlight.search_exhibit_catalog_path(exhibit, q: 'zy575vf8599')

      expect(page).to have_css('dt a', text: 'Search for "zy575vf8599" in document text', visible: :visible)
      expect(page).not_to have_css('dt', text: 'Sample matches in document text')
    end
  end

  context 'when a document has non-english full text' do
    it 'stems Portuguese properly', js: true do
      visit spotlight.search_exhibit_catalog_path(exhibit, q: 'homens')

      expect(page).not_to have_css('dd p', text: 'em conta o homem normal suposto', visible: :visible)
      page.find('dt', text: 'Sample matches in document text').click
      expect(page).to have_css('dd p', text: 'em conta o homem normal suposto', visible: :visible)
    end
  end

  context 'when a document does not have a full text highlight hit' do
    it 'does not include full-text highlight', js: true do
      visit spotlight.search_exhibit_catalog_path(exhibit, q: 'Maps')

      expect(page).to have_css('.documents-list .document') # there are results

      expect(page).not_to have_css('dt', text: 'Sample matches in document text')
    end
  end
end
