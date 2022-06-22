# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::SiteController, type: :controller do
  context 'not logged in' do
    describe 'GET #index' do
      it 'redirects to homepage' do
        get :index
        expect(response).to have_http_status(:redirect)
      end
    end
  end

  context 'logged in' do
    let(:admin) { FactoryBot.create(:user, :admin) }

    before do
      sign_in(admin)
    end

    describe 'GET #index' do
      xit 'returns http success' do
        get :index
        expect(response).to have_http_status(:success)
      end
    end
  end
end
