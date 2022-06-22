# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Role, type: :model do
  let(:organization) { FactoryBot.create(:organization) }
  let(:user) { FactoryBot.create(:user, organization:) }
  let(:user2) { FactoryBot.create(:user, organization:) }
  let!(:service_provider) { FactoryBot.create(:service_provider, organization:) }
  let!(:service) { FactoryBot.create(:service, organization:, service_provider:, service_owner_id: user.id) }

  it 'sets service owner to a manager of the service on create' do
    expect(service.service_owner.has_role?(:service_manager, service)).to be_truthy
  end

  it 'can add another user as a service manager' do
    user2.add_role :service_manager, service
    expect(user2.has_role?(:service_manager, service)).to be_truthy
    expect(User.with_role(:service_manager, service).size).to eq(2)
  end
end
