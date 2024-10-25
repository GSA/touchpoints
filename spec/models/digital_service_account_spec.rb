# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DigitalServiceAccount, type: :model do
    let(:organization) { FactoryBot.create(:organization) }
    let(:digital_service_account) { FactoryBot.create(:digital_service_account) }

    describe "#name" do
      before do
        @new_digital_service_account = DigitalServiceAccount.create({
          account: "Twitter",
          service_url: "https://lvh.me/test"
        })
      end

      it "ensures a name is specified" do
        expect(@new_digital_service_account.errors.messages).to eq({:name=>["can't be blank"]})
      end
    end

    describe "#service_url" do
      context "without a service_url" do
        before do
          @new_digital_service_account = DigitalServiceAccount.create({
            name: "Testing",
            account: "Twitter",
          })
        end

        it "ensures a service_url is specified" do
          expect(@new_digital_service_account.errors.messages).to eq({:service_url=>["can't be blank"]})
        end
      end

      context "with a duplicate service_url" do
        before do

          @new_digital_service_account = DigitalServiceAccount.create({
            name: "Testing",
            account: "Twitter",
            service_url: digital_service_account.service_url
          })
        end

        it "ensures a unique service_url" do
          expect(@new_digital_service_account.errors.messages).to eq({:service_url=>["has already been taken"]})
        end
      end
    end

    describe "#account" do
      context "without an account" do
        before do
          @new_digital_service_account = DigitalServiceAccount.create({
            name: "Testing",
            service_url: "https://lvh.me/test"
          })
        end

        it "ensures an account is specified" do
          expect(@new_digital_service_account.errors.messages).to eq({service: ["can't be blank", "Invalid service platform ''"]})
        end
      end

      context "with a non-whitelisted account" do
        before do

          @new_digital_service_account = DigitalServiceAccount.create({
            name: "Testing",
            account: "Something Else",
            service_url: "https://lvh.me/test1234"
          })
        end

        it "ensures a unique service_url" do
          expect(@new_digital_service_account.errors.messages).to eq({service: ["Invalid service platform 'Something Else'"]})
        end
      end
    end


end
