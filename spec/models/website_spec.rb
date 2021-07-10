require 'rails_helper'

RSpec.describe Website, type: :model do
  before do
    @website = Website.new
  end

  describe "try to create a new website" do
    before do
      @website.save
    end

    it "does not save and adds an error indicating domain is required" do
      expect(@website.valid?).to eq(false)
      expect(@website.errors.full_messages).to eq(["Domain can't be blank", "Type of site can't be blank"])
    end
  end

  describe "try to create a new website" do
    let!(:existing_website) { FactoryBot.create(:website) }
    let(:new_website) { FactoryBot.build(:website) }

    before do
      new_website
    end

    it "does not save and adds an error indicating type_of_site is required" do
      expect(new_website.valid?).to eq(false)
      expect(new_website.errors.full_messages).to eq(["Domain has already been taken"])
    end
  end
end
