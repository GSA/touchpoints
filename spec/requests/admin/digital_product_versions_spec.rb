require 'rails_helper'

RSpec.describe "Admin::DigitalProductVersions", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/admin/digital_product_versions/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/admin/digital_product_versions/show"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /create" do
    it "returns http success" do
      get "/admin/digital_product_versions/create"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /edit" do
    it "returns http success" do
      get "/admin/digital_product_versions/edit"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /new" do
    it "returns http success" do
      get "/admin/digital_product_versions/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /destroy" do
    it "returns http success" do
      get "/admin/digital_product_versions/destroy"
      expect(response).to have_http_status(:success)
    end
  end

end
