# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Website, type: :model do
  let(:organization) { FactoryBot.create(:organization)}

  before do
    @website = Website.new
  end

  describe 'try to create a new website' do
    before do
      @website.save
    end

    it 'does not save and adds an error indicating domain is required' do
      expect(@website.valid?).to eq(false)
      expect(@website.errors.full_messages).to eq(["Domain can't be blank", "Domain must be formatted as a domain", "Domain domain must have a valid suffix, like .gov or .mil", "Type of site can't be blank", "Organization must exist"])
    end
  end

  describe 'try to create a new website without domain' do
    let!(:existing_website) { FactoryBot.create(:website, organization: organization) }
    let(:new_website) { FactoryBot.build(:website, organization: organization, domain: existing_website.domain) }

    before do
      new_website
    end

    it 'does not save and adds an error indicating type_of_site is required' do
      expect(new_website.valid?).to eq(false)
      expect(new_website.errors.full_messages).to include('Domain has already been taken')
    end
  end

  describe 'ensuring uniqueness between example.gov and www.' do
    let!(:website) { FactoryBot.create(:website, organization: organization, domain: "example.gov") }
    let!(:www_website) { FactoryBot.create(:website, organization: organization, domain: "www.dubdub.gov") }

    it 'is not valid with a duplicate domain' do
      website = Website.new(domain: 'example.gov', organization: organization)
      expect(website).not_to be_valid
      expect(website.errors[:domain]).to include('has already been taken')
    end

    it 'is not valid with a duplicate domain including www' do
      website = Website.new(domain: 'www.example.gov')
      expect(website).not_to be_valid
      expect(website.errors[:domain]).to include('must be unique, including the www')
    end

    it 'is not valid with a duplicate domain without www' do
      website = Website.new(domain: 'dubdub.gov')
      expect(website).not_to be_valid
      expect(website.errors[:domain]).to include('must be unique, including the www')
    end
  end

  describe 'try to create a new website without type of site' do
    let!(:existing_website) { FactoryBot.create(:website, organization: organization) }
    let(:new_website) { FactoryBot.build(:website, organization: organization, domain: existing_website.domain) }

    before do
      new_website
    end

    it 'does not save and adds an error indicating type_of_site is required' do
      expect(new_website.valid?).to eq(false)
      expect(new_website.errors.full_messages).to include('Domain has already been taken')
    end
  end

  describe 'tags' do
    let!(:website) { FactoryBot.create(:website, organization: organization) }

    it 'does not include other models in tag_counts' do
      tag_name = 'tag1'
      tag_name_2 = 'tag2'
      website.tag_list.add(tag_name)
      website.save!
      organization.tag_list.add(tag_name)
      organization.tag_list.add(tag_name_2)
      organization.save!
      expect(Website.tag_counts_by_name.first.name).to eq(tag_name)
      expect(Website.tag_counts_by_name.first.taggings_count).to eq(1)
      expect(Organization.tag_counts_by_name.length).to eq(2)
      expect(Organization.tag_counts_by_name.first.name).to eq(tag_name)
      expect(Organization.tag_counts_by_name.last.name).to eq(tag_name_2)
      expect(Organization.tag_counts_by_name.first.taggings_count).to eq(1)
    end
  end

  describe '#tld?' do
    let!(:existing_website) { FactoryBot.create(:website, organization: organization) }

    before do
      existing_website.tld?
    end

    it 'a domain of 3 parts is not TLD' do
      expect(existing_website.tld?).to eq false
    end

    context '2 part domain' do
      before do
        existing_website.update(domain: 'example.gov')
      end

      it 'a domain of 2 parts is a TLD' do
        expect(existing_website.tld?).to eq true
      end
    end

    context '4 part domain' do
      before do
        existing_website.update(domain: 'dos.uno.example.gov')
      end

      it 'a domain of 4 parts is a TLD' do
        expect(existing_website.tld?).to eq false
      end
    end
  end

  describe '#login_supported' do
    let!(:existing_website) { FactoryBot.create(:website, organization: organization) }

    context "with no auth tool defined" do
      before do
        # default existing_website
      end

      it 'returns false' do
        expect(existing_website.authentication_tool).to eq nil
        expect(existing_website.login_supported).to eq false
      end
    end

    context "with auth tool defined as ``" do
      before do
        existing_website.update(authentication_tool: "")
      end

      it 'returns false' do
        expect(existing_website.login_supported).to eq false
      end
    end

    context "with auth tool defined as `None`" do
      before do
        existing_website.update(authentication_tool: "None")
      end

      it 'returns false' do
        expect(existing_website.login_supported).to eq false
      end
    end

    context "with an auth tool defined" do
      before do
        existing_website.update(authentication_tool: "Login.gov")
      end

      it 'returns false' do
        expect(existing_website.login_supported).to eq true
      end
    end
  end
end
