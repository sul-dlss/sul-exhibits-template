# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Browse category adminstration', :js do
  let(:exhibit) { create(:exhibit) }
  let(:exhibit_curator) { create(:exhibit_curator, exhibit: exhibit) }
  let(:title) { 'New category title' }

  before do
    login_as exhibit_curator
    visit spotlight.exhibit_searches_path(exhibit, anchor: 'browse-categories')
    click_link('Edit')
    find('#search_title').set(title)
    click_button('Save changes')
  end

  it 'updates the browse category title' do
    expect(page).to have_content('The browse category was successfully updated.')
  end

  context 'when a reserved word is used to title a browse category' do
    let(:title) { 'images' }

    it 'displays an error message' do
      expect(page).to have_content('The title "images" is reserved and cannot be used.')
    end
  end
end
