require 'rails_helper'

RSpec.describe User, type: :model do
  before do
    @user = User.new
  end

  describe "validate User.email" do
    context "without an email" do
      before do
        @user.save
      end

      it "fails tld_check" do
        expect(@user.errors.messages[:email].first).to eq("is not from a valid TLD - .gov and .mil domains only")
      end
    end

    context "without a non .gov or .mil email address" do
      before do
        @user.email = "user@example.com"
        @user.save
      end

      it "fails tld_check" do
        expect(@user.errors.messages[:email].first).to eq("is not from a valid TLD - .gov and .mil domains only")
      end
    end

    context "with a valid .gov email address for an Organization that has not been created" do
      before do
        @user.email = "user@example.gov"
        @user.save
      end

      it "fails organization check" do
        expect(@user.errors.messages[:organization].first).to include("'example.gov' has not yet been configured for Touchpoints")
      end
    end

    context "with a valid .gov email address for an Organization that has been created" do
      before do
        FactoryBot.create(:organization)
        @user.email = "user@example.gov"
        @user.save
      end

      it "is valid" do
        expect(@user.valid?).to eq(true)
        expect(@user.persisted?).to eq(true)
      end
    end

    context "with a valid .gov email address (under 1 subdomain) for an Organization that has been created" do
      before do
        FactoryBot.create(:organization)
        @user.email = "user@associates.subdomain.example.gov"
        @user.save
      end

      it "is valid" do
        expect(@user.valid?).to eq(true)
        expect(@user.persisted?).to eq(true)
      end
    end

    context "with a valid .gov email address (under 2 subdomains) for an Organization that has been created" do
      before do
        FactoryBot.create(:organization)
        @user.email = "user@associates.subdomain.example.gov"
        @user.save
      end

      it "is valid" do
        expect(@user.valid?).to eq(true)
        expect(@user.persisted?).to eq(true)
      end
    end

    context "with a valid .gov email address (under 3 subdomains) for an Organization that has been created" do
      before do
        FactoryBot.create(:organization)
        @user.email = "user@toomany.associates.subdomain.example.gov"
        @user.save
      end

      it "fails tld_check" do
        expect(@user.valid?).to eq(false)
        expect(@user.persisted?).to eq(false)
        expect(@user.errors.messages[:organization].first).to include("'toomany.associates.subdomain.example.gov' has not yet been configured for Touchpoints")
      end
    end

    context "api key" do
      before do
        FactoryBot.create(:organization)
        @user.email = "user@example.gov"
        @user.save
      end

      it "api_key is nil" do
        expect(@user.api_key).to be_nil
        expect(@user.api_key_updated_at).to be_nil
      end

      it "api_key must be 40 characters long, to match api.data.gov" do
        @user.update(api_key: "key too short")
        expect(@user.errors.full_messages.first).to eq("Api key is not 40 characters, as expected from api.data.gov.")
      end

      it "api_key_updated_at is updated when the API Key is updated" do
        expect(@user.api_key_updated_at).to be_nil
        @user.update(api_key: TEST_API_KEY)

        expect(@user.api_key_updated_at).to_not be_nil
      end
    end
  end

end
