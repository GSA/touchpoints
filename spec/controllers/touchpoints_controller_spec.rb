# frozen_string_literal: true

require 'rails_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.
#
# Also compared to earlier versions of this generator, there are no longer any
# expectations of assigns and templates rendered. These features have been
# removed from Rails core in Rails 5, but can be added back in via the
# `rails-controller-testing` gem.

describe TouchpointsController, type: :controller do
  # This should return the minimal set of attributes required to create a valid
  # Touchpoint. As you add validations to Touchpoint, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {}

  let(:invalid_attributes) do
    skip('Add a hash of attributes invalid for your model')
  end

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # TouchpointsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  let(:organization) { FactoryBot.create(:organization) }
  let(:user) { FactoryBot.create(:user, organization:) }
  let(:form) { FactoryBot.create(:form, :open_ended_form, organization:) }

  describe 'GET #show with ID' do
    it 'returns a success response' do
      get :show, params: { id: form.legacy_touchpoint_id }, session: valid_session
      expect(response).to redirect_to(submit_touchpoint_path(form))
    end
  end

  describe 'GET #js with ID' do
    render_views

    it 'returns a success response' do
      get :js, params: { id: form.short_uuid }, session: valid_session
      expect(response.body).to include('use strict')
      expect(response.body).to include('Create unique Touchpoints form object')
    end
  end

  describe 'GET #show with UUID' do
    it 'returns a success response' do
      get :show, params: { id: form.short_uuid }, session: valid_session
      expect(response).to redirect_to(submit_touchpoint_path(form))
    end
  end

  describe 'GET #show (.js) with UUID' do
    render_views

    it 'returns a success response' do
      get :show, params: { id: form.short_uuid }, session: valid_session, format: :js
      expect(response.body).to include('use strict')
      expect(response.body).to include('Create unique Touchpoints form object')
    end
  end

  describe 'GET #show with invalid ID' do
    it 'throws an ActiveRecord error for an invalid string ID' do
      expect do
        get :show, params: { id: 'invalid_id' }, session: valid_session
      end.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'throws an ActiveRecord error for too few characters in the UUID' do
      expect do
        get :show, params: { id: form.uuid[0..6] }, session: valid_session
      end.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'throws an ActiveRecord error for too many characters in the UUID' do
      expect do
        get :show, params: { id: form.uuid[0..9] }, session: valid_session
      end.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
