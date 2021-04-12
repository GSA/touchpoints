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
      expect(@website.errors.full_messages).to eq(["Domain can't be blank"])
    end
  end
end
