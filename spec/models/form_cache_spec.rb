# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FormCache, type: :model do
  let(:organization) { FactoryBot.create(:organization) }
  let(:user) { FactoryBot.create(:user, organization:) }
  let(:form) { FactoryBot.create(:form, organization:, user:) }

  describe 'validate cache fetch' do
    context 'Store and Fetch Touchpoint' do
      it 'caches a touchpoint' do
        @cache = FormCache.fetch(form.short_uuid)
        expect(form.id).to eq(@cache.id)
      end
    end

    context 'Invalidate Cache' do
      before do
        @cache = FormCache.fetch(form.short_uuid)
        expect(form.id).to eq(@cache.id)
        FormCache.invalidate(form.short_uuid)
      end

      it 'removes a form from cache' do
        expect(Rails.cache.read("namespace:form-#{form.short_uuid}")).to eq(nil)
      end
    end
  end
end
