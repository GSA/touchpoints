require 'rails_helper'

describe SiteController, type: :controller do
  it "should get index" do
    get :index
    expect(response).to be_successful
  end
end
