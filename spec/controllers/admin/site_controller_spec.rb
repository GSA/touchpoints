require 'rails_helper'

RSpec.describe Admin::SiteController, type: :controller do

  context "not logged in" do
    describe "GET #index" do
      it "returns http success" do
        get :index
        expect(response).to have_http_status(:redirect)
      end
    end
  end

  context "not logged in" do
    let(:admin) { FactoryBot.create(:user, :admin)}

    before do
      sign_in(admin)
    end

    describe "GET #index" do
      it "returns http success" do
        get :index
        expect(response).to have_http_status(:success)
      end
    end
  end

end
