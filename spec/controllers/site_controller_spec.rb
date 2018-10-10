require 'rails_helper'

describe SiteController, type: :controller do
  it "should get index" do
    get :index
    expect(response).to be_successful
  end

  it "should get example" do
    get :example
    expect(response).to be_successful
  end

  describe "get status" do
    before do
      get :status
    end

    it "should be successful" do
      expect(response).to be_successful
    end

    it "should be a Hash" do
      expect(JSON.parse(response.body)).to be_kind_of(Hash)
    end
  end
end
