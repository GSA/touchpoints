require 'rails_helper'

feature "Login Flow", js: true do

  describe "homepage" do
    before do
      visit root_path
    end

    it "has content" do
      expect(page).to have_content "Touchpoints"
    end
  end
end
