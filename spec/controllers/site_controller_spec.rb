require 'spec_helper'

class SiteControllerSpec < ActionDispatch::IntegrationTest
  describe "should get index" do
    get :index
    expect(response).to be_successful
  end
end
