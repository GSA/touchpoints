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

    describe 'domain validation' do
      it 'accepts a valid bare domain' do
        @org = Organization.create({
          name: "Example",
          domain: "example.gov",
          abbreviation: "EX"
        })
        expect(@org).to be_valid
      end

      it 'accepts a valid multi-level domain' do
        @org = Organization.create({
          name: "FEMA",
          domain: "fema.dhs.gov",
          abbreviation: "FEMA"
        })
        expect(@org).to be_valid
      end

      it 'rejects a domain with http:// protocol' do
        @org = Organization.create({
          name: "Example",
          domain: "http://example.gov",
          abbreviation: "EX"
        })
        expect(@org).not_to be_valid
        expect(@org.errors.messages[:domain]).to include("must be a bare domain name (e.g., 'example.gov') without protocol, path, or trailing slash")
      end

      it 'rejects a domain with https:// protocol' do
        @org = Organization.create({
          name: "Example",
          domain: "https://example.gov",
          abbreviation: "EX"
        })
        expect(@org).not_to be_valid
        expect(@org.errors.messages[:domain]).to include("must be a bare domain name (e.g., 'example.gov') without protocol, path, or trailing slash")
      end

      it 'rejects a domain with a path' do
        @org = Organization.create({
          name: "Example",
          domain: "example.gov/path",
          abbreviation: "EX"
        })
        expect(@org).not_to be_valid
        expect(@org.errors.messages[:domain]).to include("must be a bare domain name (e.g., 'example.gov') without protocol, path, or trailing slash")
      end

      it 'rejects a domain with a trailing slash' do
        @org = Organization.create({
          name: "Example",
          domain: "example.gov/",
          abbreviation: "EX"
        })
        expect(@org).not_to be_valid
        expect(@org.errors.messages[:domain]).to include("must be a bare domain name (e.g., 'example.gov') without protocol, path, or trailing slash")
      end

      it 'rejects a full URL' do
        @org = Organization.create({
          name: "Example",
          domain: "https://www.example.gov/",
          abbreviation: "EX"
        })
        expect(@org).not_to be_valid
        expect(@org.errors.messages[:domain]).to include("must be a bare domain name (e.g., 'example.gov') without protocol, path, or trailing slash")
      end

      it 'accepts a domain with 5 parts' do
        @org = Organization.create({
          name: "Example",
          domain: "a.b.c.example.gov",
          abbreviation: "EX"
        })
        expect(@org).to be_valid
      end

      it 'rejects a domain with more than 5 parts' do
        @org = Organization.create({
          name: "Example",
          domain: "a.b.c.d.e.example.gov",
          abbreviation: "EX"
        })
        expect(@org).not_to be_valid
        expect(@org.errors.messages[:domain]).to include("cannot have more than 5 parts (e.g., 'sub1.sub2.sub3.example.gov')")
      end
    end
  end

end
