require 'rails_helper'

RSpec.describe 'Rack::Attack throttling', type: :request do
  before do
    Rack::Attack.reset! # Reset throttle counters before each test
  end

  let(:ip) { '1.2.3.4' }
  let(:headers) { { 'REMOTE_ADDR' => ip } }
  let(:valid_submission_path) { "/submissions/1234abcd.json" }

  it 'allows up to 10 requests per minute' do
    10.times do
      post valid_submission_path, headers: headers
      expect(response).not_to have_http_status(:too_many_requests)
    end
  end

  it 'blocks the 11th request within a minute' do
    10.times { post valid_submission_path, headers: headers }

    post valid_submission_path, headers: headers
    expect(response).to have_http_status(:too_many_requests)
  end

  it 'does not throttle requests from different IPs' do
    10.times do |i|
      post valid_submission_path, headers: { 'REMOTE_ADDR' => "192.168.1.#{i}" }
      expect(response).not_to have_http_status(:too_many_requests)
    end
  end

  it 'does not throttle non-matching routes' do
    20.times do
      post "/other_path", headers: headers
      expect(response).not_to have_http_status(:too_many_requests)
    end
  end

  it 'recognizes both numeric and short UUID paths' do
    valid_paths = ["/submissions/123.json", "/submissions/abc123de.json"]
    valid_paths.each do |path|
      post path, headers: headers
      expect(response).not_to have_http_status(:too_many_requests)
    end
  end

  it 'does not throttle invalid submission paths' do
    invalid_paths = ["/submissions/too_long_uuid_1234.json", "/submissions/.json"]
    invalid_paths.each do |path|
      post path, headers: headers
      expect(response).not_to have_http_status(:too_many_requests)
    end
  end
end
