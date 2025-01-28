# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Viewer Configuration' do
  let(:exhibit) { create(:exhibit) }
  let(:user) { nil }
  let(:viewer) { Viewer.create(exhibit_id: exhibit.id) }

  before do
    sign_in user
  end

  describe '#edit' do
    context 'an anonymous user' do
      it 'redirects to the login page' do
        get "/#{exhibit.slug}/viewers/edit"

        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'an exhibit curator' do
      let(:user) { create(:curator) }

      it 'redirects to the home page with an alert indicating they do not have access' do
        get "/#{exhibit.slug}/viewers/edit"

        expect(flash[:alert]).to eq 'You are not authorized to access this page.'
        expect(response).to redirect_to root_url
      end
    end

    context 'an exhibit admin' do
      let(:user) { create(:exhibit_admin, exhibit: exhibit) }

      it 'is allowed' do
        get "/#{exhibit.slug}/viewers/edit"

        expect(response).to be_successful
      end
    end
  end

  describe '#update' do
    context 'an anonymous user' do
      it 'redirects to the login page' do
        patch "/#{exhibit.slug}/viewers", params: { id: viewer }

        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'an exhibit admin' do
      let(:user) { create(:exhibit_admin, exhibit: exhibit) }
      let(:viewer_params) { { viewer_type: 'mirador' } }

      before do
        patch "/#{exhibit.slug}/viewers/", params: {
          id: viewer.id,
          viewer: viewer_params
        }
      end

      it 'updates the viewer and redirects to the edit form' do
        object = assigns(:viewer)
        expect(object.viewer_type).to eq 'mirador'
        expect(response).to redirect_to "/#{exhibit.slug}/viewers/edit"
      end

      it 'sets a flash notice indicating that the settings have been updated' do
        expect(flash[:notice]).to eq 'The viewer settings have been updated.'
      end
    end
  end
end
