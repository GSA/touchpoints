require 'rails_helper'

feature 'Record Retention', js: true do
  context 'as Admin' do
    let(:organization) { FactoryBot.create(:organization) }
    let(:admin) { FactoryBot.create(:user, :admin, organization:) }

    describe '#index' do
      before do
        login_as admin
      end

      it 'is accessible' do
        visit admin_record_retention_path
        expect_page_axe_clean
      end
    end
  end
end
