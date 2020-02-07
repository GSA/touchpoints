require 'rails_helper'

RSpec.describe Touchpoint, type: :model do
  let(:organization) { FactoryBot.create(:organization) }
  let(:admin) { FactoryBot.create(:user, :admin, organization: organization) }
  let(:form) { FactoryBot.create(:form, organization: organization, user: admin)}
  let(:touchpoint) { FactoryBot.create(:touchpoint, organization: organization, form: form) }

  describe "validate state transitions" do

    context "initial state" do
      it "sets initial state" do
        tp = Touchpoint.new
        expect(tp.in_development?).to eq(true)
      end
    end

    context "transitionable touchpoint" do
      it "transitions state" do
        touchpoint.develop
        expect(touchpoint.in_development?).to eq(true)
        expect(touchpoint.live?).to eq(false)
        touchpoint.publish
        expect(touchpoint.in_development?).to eq(false)
        expect(touchpoint.live?).to eq(true)
      end
    end

    context "expired touchpoint" do
      it "archives expired touchpoint" do
        touchpoint.publish
        expect(touchpoint.live?).to eq(true)
        touchpoint.expiration_date = Date.today - 1
        touchpoint.check_expired
        expect(touchpoint.live?).to eq(false)
        expect(touchpoint.archived?).to eq(true)
      end
    end
  end
end
