# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Organization, type: :model do

  context 'new org' do
    describe 'basic validations' do
      before do
        @org = Organization.create
      end

      it 'requires a name, domain, and abbreviation' do
        expect(@org.errors.messages[:name]).to eq(["can't be blank"])
        expect(@org.errors.messages[:domain]).to eq(["can't be blank"])
        expect(@org.errors.messages[:abbreviation]).to eq(["can't be blank"])
      end
    end

    describe 'new org with an abbreviation that includes special characters' do
      before do
        @org = Organization.create({
          abbreviation: "H.R."
        })
      end

      it 'does not allow special characters for an abbreviation' do
        expect(@org.errors.messages[:abbreviation]).to include("only allows letters and numbers")
      end
    end

    describe 'new org with an abbreviation that includes more than 10 characters' do
      before do
        @org = Organization.create({
          abbreviation: "TENPLUSLETTERS"
        })
      end

      it 'does not allow more than 10 characters for an abbreviation' do
        expect(@org.errors.messages[:abbreviation]).to include("is too long (maximum is 10 characters)")
      end
    end

    describe 'minimal valid Organization' do
      before do
        @org = Organization.create({
          name: "Example",
          domain: "example.gov",
          abbreviation: "EX"
        })
      end

      it 'is a valid org' do
        expect(@org.save!).to be (true)
      end
    end
  end

end
