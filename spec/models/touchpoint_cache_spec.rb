require 'rails_helper'

RSpec.describe TouchpointCache, type: :model do

  let(:organization) { FactoryBot.create(:organization) }
  let(:user) { FactoryBot.create(:user, organization: organization) }
  let(:form) { FactoryBot.create(:form, organization: organization, user: user)}
  let!(:touchpoint) { FactoryBot.create(:touchpoint, organization: organization, form: form) }

  describe "validate cache fetch" do
    context "Store and Fetch Touchpoint" do
      it "caches a touchpoint" do
        @tpc = TouchpointCache.fetch(touchpoint.short_uuid)
        expect(touchpoint.id).to eq(@tpc.id)
      end
    end

    context "Invalidate Cache" do
      before do
        @tpc = TouchpointCache.fetch(touchpoint.short_uuid)
        expect(touchpoint.id).to eq(@tpc.id)
        TouchpointCache.invalidate(touchpoint.short_uuid)
      end

      it "removes a touchpoint from cache" do
        expect(Rails.cache.read("namespace:touchpoint-" + touchpoint.short_uuid)).to eq(nil)
      end
    end
  end
end
