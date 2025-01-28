# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LoginController do
  let(:user) { create(:curator) }

  before do
    allow(controller).to receive_messages(current_user: user)
  end

  context 'with an explicit referrer parameter' do
    it 'accepts the user invitation on login and redirects to the referrer' do
      allow(user).to receive(:accept_invitation!)
      get :login, params: { referrer: '/home' }
      expect(response).to redirect_to '/home'
      expect(user).to have_received(:accept_invitation!)
    end
  end

  context 'with a referrer header' do
    before do
      request.env['HTTP_REFERER'] = 'http://test.host/foo'
    end

    it 'redirects to the referrer' do
      get :login
      expect(response).to redirect_to 'http://test.host/foo'
    end
  end

  context 'without any referrer information' do
    it 'redirects to the home page' do
      get :login
      expect(response).to redirect_to '/'
    end
  end
end
