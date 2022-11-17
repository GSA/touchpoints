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
      expect(new_website.errors.full_messages).to eq(['Domain has already been taken'])
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
      expect(new_website.errors.full_messages).to eq(['Domain has already been taken'])
    end
  end

  describe 'tags' do
    it 'does not include other models in tag_counts' do
      tag_name = 'tag1'
      tag_name_2 = 'tag2'
      website = FactoryBot.create(:website, organization: organization)
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
end
