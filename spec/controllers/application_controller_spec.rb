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

  # Simulates what happens when Postgres cancels a query for exceeding
  # `statement_timeout` (config/database.yml).
  describe '#render_query_timeout' do
    controller do
      def index
        raise ActiveRecord::QueryCanceled, 'canceling statement due to statement timeout'
      end
    end

    before do
      routes.draw { get 'index' => 'anonymous#index' }
    end

    it 'responds 503 with a structured error for JSON requests' do
      get :index, format: :json

      expect(response).to have_http_status(:service_unavailable)
      body = JSON.parse(response.body)
      expect(body['error']['message']).to eq(I18n.t('errors.request.canceled'))
      expect(body['error']['status']).to eq(503)
    end

    it 'renders the service_unavailable error page for HTML requests' do
      get :index, format: :html

      expect(response).to have_http_status(:service_unavailable)
      expect(response).to render_template('errors/service_unavailable')
    end

    it 'responds 503 with a console.warn for JS requests' do
      get :index, format: :js

      expect(response).to have_http_status(:service_unavailable)
      expect(response.media_type).to eq('text/javascript')
      expect(response.body).to include('console.warn')
      expect(response.body).to include(I18n.t('errors.request.canceled'))
    end
  end
end
