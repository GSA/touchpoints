 require 'rails_helper'

feature "Data Collections", js: true do
  let!(:organization) { FactoryBot.create(:organization) }
  let(:another_organization) { FactoryBot.create(:organization, :another) }
  let(:admin) { FactoryBot.create(:user, :admin, organization: organization) }
  let(:user) { FactoryBot.create(:user, organization: another_organization) }
  let!(:collection) { FactoryBot.create(:collection, organization: another_organization, user: user) }
  let!(:admin_collection) { FactoryBot.create(:collection, organization: organization, user: admin) }

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
      let(:collection) { FactoryBot.create(:collection, organization: another_organization, user: user) }

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
        expect(page.all("select option").count).to eq(1)
      end
    end
  end

end
