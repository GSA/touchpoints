 require 'rails_helper'

feature "Data Collections", js: true do
  let(:organization) { FactoryBot.create(:organization) }
  let!(:service) { FactoryBot.create(:service, organization: organization, hisp: false) }
  let(:another_organization) { FactoryBot.create(:organization, :another) }
  let!(:another_service) { FactoryBot.create(:service, organization: another_organization, hisp: true) }
  let(:admin) { FactoryBot.create(:user, :admin, organization: organization) }
  let(:user) { FactoryBot.create(:user, organization: another_organization) }
  let!(:collection) { FactoryBot.create(:collection, organization: another_organization, user: user, service: another_service) }
  let!(:admin_collection) { FactoryBot.create(:collection, organization: organization, user: admin, service: service) }

  context "as an Admin" do
    before do
      login_as(admin)
    end

    describe "GET /index" do
      before do
        visit admin_collections_path
      end

      it "renders the index page" do
        expect(page).to have_content("Data Collections")
        expect(page).to have_css("table.usa-table")
      end
    end

    describe "GET /show" do
      before do
        visit admin_collection_path(collection)
      end

      it "renders a successful response" do
        expect(page).to have_content("Data Collection")
        expect(page).to have_content(collection.name)
        expect(page).to have_content("Reflection text")
      end
    end

    describe "GET /new" do
      before do
        visit new_admin_collection_path
      end

      it "renders a successful response" do
        expect(page).to have_content("New Data Collection")
        expect(page).to have_button("Create Collection")
      end

      context "with valid parameters" do
        before do
          select(organization.name, from: "collection_organization_id")
          select(service.name, from: "collection_service_id")
          click_on "Create Collection"
        end

        it "creates a new Collection" do
          expect(page).to have_content("Collection was successfully created.")
        end
      end
    end

    describe "/collections/:id/edit" do
      context "with valid parameters" do
        before do
          visit edit_admin_collection_path(collection)
          click_on "Update Collection"
        end

        it "update the requested collection" do
          expect(page).to have_content("Collection was successfully updated.")
        end

        it "redirect to /admin/collections/:id/" do
          expect(page.current_path).to eq(admin_collection_path(collection))
        end
      end

      context "with invalid parameters" do
        xit "" do
        end
      end
    end

    describe "DELETE /destroy" do
      before do
        visit edit_admin_collection_path(collection)
        expect(page).to have_content("Editing Data Collection")
        click_on "Delete"
        page.driver.browser.switch_to.alert.accept
      end

      it "destroys the requested collection" do
        expect(page).to have_content("Data Collections")
        expect(page).to have_content("Collection was successfully destroyed.")
      end
    end


    describe "with HISP forms" do
      let!(:form) { FactoryBot.create(:form, kind: "a11", organization: organization, user: admin) }

      before do
        visit admin_collections_path
      end

      it "display Customer Feedback Analysis" do
        expect(page).to have_css("#customer-feedback-summary")
        within "#customer-feedback-summary" do
          expect(find_all("tbody tr").size).to eq(1)
          expect(page).to have_content form.organization.name
          expect(page).to have_content form.name
        end
      end
    end
  end

  context "as a non-admin User" do
    let(:user2) { FactoryBot.create(:user, organization: another_organization) }

    before do
      login_as(user)
    end

    describe "GET /index" do
      before do
        visit admin_collections_path
      end

      it "renders the index page" do
        expect(page).to have_content("Data Collections")
        expect(page).to have_css("table.usa-table")
      end
    end

    describe "GET /show" do
      let(:collection) { FactoryBot.create(:collection, organization: another_organization, user: user, service: another_service) }

      it "renders a successful response" do
        visit admin_collection_path(collection)
        expect(page).to have_content("Data Collections")
      end
    end

    describe "GET /edit" do
      before do
        visit edit_admin_collection_path(collection)
      end

      it "renders a successful response" do
        expect(page).to have_content("Editing Data Collection")
      end

      it "renders Collection dropdown with 1 organization's collections" do
        expect(page.all("select#collection_name option").count).to eq(1)
      end

      context "#copy" do
        before do
          click_on "Copy this collection"
          page.driver.browser.switch_to.alert.accept
        end

        it "renders a successful response" do
          expect(page).to have_content("Collection was successfully copied.")
          expect(page).to have_content("Copy of #{collection.name}")
        end
      end

    end
  end

end
