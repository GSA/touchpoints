# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Collection, type: :model do
  describe 'required attributes' do
    context 'newly created Collection' do
      before do
        @collection = Collection.create({})
      end

      it 'requires user' do
        expect(@collection.errors.messages).to have_key(:user)
        expect(@collection.errors.messages[:user]).to eq(['must exist'])
      end

      it 'requires organization' do
        expect(@collection.errors.messages).to have_key(:organization)
        expect(@collection.errors.messages[:organization]).to eq(['must exist'])
      end

      it 'requires service_provider' do
        expect(@collection.errors.messages).to have_key(:service_provider)
        expect(@collection.errors.messages[:service_provider]).to eq(['must exist'])
      end

      it 'requires name' do
        expect(@collection.errors.messages).to have_key(:name)
        expect(@collection.errors.messages[:name]).to eq(["can't be blank"])
      end

      it 'requires year' do
        expect(@collection.errors.messages).to have_key(:year)
        expect(@collection.errors.messages[:year]).to eq(["can't be blank"])
      end

      it 'requires quarter' do
        expect(@collection.errors.messages).to have_key(:quarter)
        expect(@collection.errors.messages[:quarter]).to eq(["can't be blank"])
      end
    end
  end

  let(:organization) { FactoryBot.create(:organization) }
  let(:user) { FactoryBot.create(:user, organization:) }
  let(:service_provider) { FactoryBot.create(:service_provider, organization:) }

  describe 'a minimally valid Collection' do
    before do
      @collection = Collection.create(name: 'Test Collection', organization:, user:, service_provider:, year: 2022, quarter: 2)
    end

    it 'requires user' do
      expect(@collection.valid?).to eq(true)
    end
  end

  describe 'reflection text that is too long' do
    context do
      before do
        reflection_text = 'longstring' * 600 # 6,000 char string
        @collection = Collection.create(name: 'Test Collection', organization:, user:, service_provider:, year: 2022, quarter: 2, reflection: reflection_text)
      end

      it 'adds error, indicating 5000 character limit' do
        expect(@collection.valid?).to eq(false)
        expect(@collection.errors.messages[:reflection].first).to eq('is too long (maximum is 5000 characters)')
      end
    end
  end
end
