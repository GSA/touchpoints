require 'rails_helper'

RSpec.describe TouchpointCache, type: :model do

  let!(:touchpoint) { FactoryBot.create(:touchpoint, :with_form) }

  describe "validate cache fetch" do
    context "Store and Fetch Touchpoint" do
      it "caches a touchpoint" do
        @tpc = TouchpointCache.fetch(touchpoint.id)
        expect(touchpoint.id).to eq(@tpc.id)
      end
    end

    context "Invalidate Cache" do
      before do
        @tpc = TouchpointCache.fetch(touchpoint.id)
        expect(touchpoint.id).to eq(@tpc.id)
        TouchpointCache.invalidate(touchpoint.id)
      end

      it "removes a touchpoint from cache" do
        expect(Rails.cache.read("namespace:touchpoint-" + touchpoint.id.to_s)).to eq(nil)
      end
    end
  end
end
