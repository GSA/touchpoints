# frozen_string_literal: true

require 'rails_helper'

describe ApplicationController, type: :controller do
  describe ProfileController, type: :controller do
    let(:organization) { FactoryBot.create(:organization) }
    let(:admin) { FactoryBot.create(:user, :admin, organization:) }

    context 'save url intent' do
      it 'should save redirect when not logged in' do
        get :show
        expect(controller.stored_location_for(:user)).to eq '/profile'
        expect(response).to redirect_to '/index'
      end

      it 'should not save redirect when logged in' do
        sign_in(admin)
        get :show
        expect(controller.stored_location_for(:user)).to eq nil
      end
    end
  end
end
