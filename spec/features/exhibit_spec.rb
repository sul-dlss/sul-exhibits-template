# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'an exhibit' do
  let!(:exhibit) { create(:exhibit) }

  it 'loads the home page' do
    visit '/'
  end

  it 'can open a search tips modal' do
    visit spotlight.url_for(exhibit)
    click_on 'Search tips'
    expect(page).to have_css('.modal-title', text: 'Search tips')
  end

  it 'can enable full text fielded search' do
    exhibit.blacklight_configuration.search_fields['full_text'] = { enabled: true }
    exhibit.blacklight_configuration.save
    visit spotlight.url_for(exhibit)
    fill_in 'q', with: 'cobbler'
    select 'Full text', from: 'search_field'
    click_button 'search'
    expect(page.status_code).to eq 200
  end

  describe 'search results' do
    let(:exhibit) { create(:exhibit, slug: 'default-exhibit') }

    it 'can run a search' do
      visit spotlight.url_for(exhibit)
      fill_in 'q', with: 'Africa'
      click_button 'search'
      expect(page).to have_content '1 - 12 of 16'
      expect(page).to have_content 'Title: Africa'
    end

    it 'can run an advanced search' do
      visit spotlight.url_for(exhibit)
      fill_in 'q', with: 'Bartholomew OR Bevan'
      click_button 'search'
      expect(page).to have_content '1 - 2 of 2'
      expect(page).to have_content 'Title: Africa'
    end

    describe 'search results views' do
      before do
        visit spotlight.url_for(exhibit)
        click_button 'search'
      end

      it 'has the list search results view' do
        click_on 'List'
        expect(page.status_code).to eq 200
      end

      it 'has the gallery search results view' do
        click_on 'Gallery'
        expect(page.status_code).to eq 200
      end

      it 'has the masonry search results view' do
        click_on 'Masonry'
        expect(page.status_code).to eq 200
      end

      it 'has the slideshow search results view' do
        click_on 'Slideshow'
        expect(page.status_code).to eq 200
      end
    end
  end
end
