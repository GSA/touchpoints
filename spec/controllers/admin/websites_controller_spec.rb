# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::WebsitesController, type: :controller do
  let(:valid_session) { {} }

  let(:admin) { FactoryBot.create(:user, :admin) }
  let(:website) { FactoryBot.create(:website, organization: admin.organization) }

  context 'not logged in' do
    describe 'GET #index' do
      it 'redirects to homepage' do
        get :index
        expect(response).to have_http_status(:redirect)
      end
    end
  end

  context 'logged in' do
    before do
      sign_in(admin)
    end

    describe 'GET #index' do
      it 'returns http success' do
        get :index
        expect(response).to have_http_status(:success)
      end
    end

    describe 'GET #show' do
      it 'returns a success response' do
        get :show, params: { id: website.to_param }, session: valid_session
        expect(response).to be_successful
      end
    end

    describe 'GET #versions' do
      it 'returns http success' do
        get :versions, params: { id: website.to_param }, session: valid_session
        expect(response).to be_successful
      end
    end
  end
end
