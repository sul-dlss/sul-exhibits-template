# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'viewers/edit' do
  let(:exhibit) { create(:exhibit) }
  let(:viewer) { Viewer.create(exhibit_id: exhibit.id) }

  before do
    assign(:viewer, viewer)
    assign(:exhibit, exhibit)
    expect(view).to receive_messages(configuration_page_title: 'Viewers')
    stub_template 'spotlight/shared/_exhibit_sidebar.html.erb' => 'ignore'
    render
  end

  it 'contains instructions' do
    expect(rendered).to have_css('p.instructions')
  end
end
